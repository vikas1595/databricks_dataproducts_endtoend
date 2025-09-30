## DIY: Create a new data product

### Prerequisites
- Azure DevOps access with PR permissions
- Azure service connection (OIDC) configured
- Databricks workspace per environment

### 1) Define product metadata
- Add a YAML under `platform-infra/metadata/products/<product>.yaml`.
- Example:
```yaml
product:
  name: inventory
  owners_ad_groups:
    - adg-inventory-admins
    - adg-inventory-producers
    - adg-inventory-consumers
storage:
  container: lake
  base_path: /products/inventory
governance:
  rbac:
    admin_group: adg-inventory-admins
    producer_group: adg-inventory-producers
    consumer_group: adg-inventory-consumers
sources:
  - name: sql_items
    type: sqlserver
    schema: dbo
    table: Items
    mode: incremental
    watermark_column: UpdatedAt
    schedule: "0 */2 * * *"
    dq_rules_ref: dq/items.yaml
medallion:
  bronze_path: /bronze/inventory
  silver_path: /silver/inventory
  gold_path: /gold/inventory
```

### 2) Open PR in `platform-infra`
- CI validates and shows Terraform plan creating:
  - Unity Catalog catalog + schemas + external location + grants
  - ADF datasets/pipelines/triggers for SQL sources

### 3) Add transformations and DQ in `data-products`
- Create DLT notebook under `data-products/dlt/` (copy `silver_orders.py`).
- Add DQ rules under `data-products/dq/` (copy `orders.yaml`).
- Update `data-products/bundle.yml` with a pipeline for your product.

### 4) Deploy via Azure DevOps
- On merge, infra pipeline applies to `dev`.
- App pipeline deploys the Bundle to `dev`.
- Promote to `test`/`prod` with environment approvals.

### 5) Validate
- Trigger ADF pipeline (or wait for schedule).
- Run DLT pipeline; confirm silver/gold tables.
- Check DQ results (DLT expectations and GX job if configured). 