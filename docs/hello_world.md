## Hello World: SQL → ADF → Bronze → DLT Silver → GX Validation

This walkthrough uses the existing `sales_orders` product config. It ingests from Azure SQL to ADLS (bronze) with ADF, transforms to silver with a DLT pipeline, and validates with Great Expectations.

### Prerequisites
- Azure subscription and resource group
- Azure SQL Server/DB reachable from ADF
- Databricks workspace with Unity Catalog enabled
- ADLS Gen2 account
- ADF factory
- Service connection and variables configured for Azure DevOps (or run Terraform locally)

### 0) Prepare dev variables
Edit `platform-infra/envs/dev/dev.tfvars` with real values:
- `databricks_workspace_id`, `data_factory_id`, `storage_account_name`, `access_connector_id`
- Ensure ADF linked services exist: `ls_sql_src` (Azure SQL) and `ls_adls` (ADLS)
- Set `eventhub_rg_name` if streaming is used (not required for this tutorial)

### 1) Provision (dev)
Run locally or use the ADO infra pipeline.
```bash
# From repo root
cd platform-infra/envs/dev
terraform init \
  -backend-config="resource_group_name=$TF_STATE_RG" \
  -backend-config="storage_account_name=$TF_STATE_SA" \
  -backend-config="container_name=$TF_STATE_CONTAINER" \
  -backend-config="key=platform-dev.tfstate"
terraform plan -var-file="dev.tfvars" -out tfplan
terraform apply -auto-approve tfplan
```

### 2) Seed Azure SQL with a demo table
Connect to your Azure SQL (`sqlcmd`, SSMS, or Azure Portal Query Editor) and run:
```sql
CREATE TABLE dbo.Orders (
  id            INT PRIMARY KEY,
  status        VARCHAR(20) NOT NULL,
  updated_at    DATETIME2   NOT NULL DEFAULT SYSUTCDATETIME()
);
INSERT INTO dbo.Orders (id, status) VALUES
(1,'NEW'),(2,'COMPLETE'),(3,'CANCELLED');
```
Ensure `ls_sql_src` in ADF points to this database using AAD auth (Managed Identity) or a secret.

### 3) Trigger ADF incremental copy to bronze
Use Azure CLI to trigger the generated pipeline for `sales_orders` (name pattern: `pl_<product>_<source>_incremental`).
```bash
az login
az account set --subscription <SUB_ID>
az datafactory pipeline create-run \
  --resource-group <RG_NAME> \
  --factory-name <ADF_NAME> \
  --name pl_sales_orders_sql_orders_incremental \
  --parameters '{"schema":"dbo","table":"Orders","watermarkColumn":"UpdatedAt","basePath":"/bronze/sales_orders"}'
```
Verify files in ADLS under `/bronze/sales_orders/sql_orders/`.

### 4) Deploy and run the DLT pipeline (silver)
Use Databricks CLI Bundles.
```bash
# Install latest Databricks CLI
curl -fsSL https://raw.githubusercontent.com/databricks/cli/main/install.sh | sh

# Azure CLI auth to Databricks (workspace must be set in bundle target)
export DATABRICKS_CONFIG_PROFILE=azure-cli

# From repo root
databricks bundle validate -t dev
databricks bundle deploy -t dev

# Run the DLT pipeline defined in bundle.yml (resource key: sales_orders_silver)
databricks bundle run sales_orders_silver -t dev
```
After success, check Unity Catalog catalog `sales_orders.silver` for tables created/updated.

### 5) Run Great Expectations validation
```bash
# Runs the GX job defined in bundle.yml
databricks bundle run sales_orders_gx_validate -t dev
```
Results are appended to the Delta table `sales_orders.gold.dq_results`.

### 6) Inspect results
In a Databricks SQL query or notebook:
```sql
SELECT timestamp, table, success, statistics
FROM sales_orders.gold.dq_results
ORDER BY timestamp DESC
LIMIT 50;
```

### 7) Make a change and re-run
- Insert a bad record to test DQ:
```sql
INSERT INTO dbo.Orders (id, status) VALUES (4,'BAD_STATUS');
```
- Re-trigger ADF (step 3), then re-run DLT (step 4) and GX (step 5). The GX job should flag the invalid status.

### 8) Clean up (optional)
```bash
# Remove dev resources managed by Terraform (irreversible)
cd platform-infra/envs/dev
terraform destroy -var-file=dev.tfvars
```

Tips
- Adjust schedules by editing the product YAML and reapplying Terraform.
- Add new sources/tables by extending the product YAML and adding corresponding DLT logic and DQ rules. 