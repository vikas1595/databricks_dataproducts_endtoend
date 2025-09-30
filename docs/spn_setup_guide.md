## SPN Infrastructure Setup Guide

### 1. Get Your SPN Secret
You need to get the secret (password) for your Service Principal:

```bash
# Login with your SPN
az login --service-principal \
  --username 9009c416-7543-4667-aa0c-3e4d9c2dee91 \
  --password <YOUR_SPN_SECRET> \
  --tenant 17aac8e1-a2cc-43fb-bf31-c3bf14b941d0

# Set subscription
az account set --subscription a6250aad-fe4f-4ddd-a7c8-10793cfac5d6
```

**Where to get the secret:**
- Go to Azure Portal → Azure Active Directory → App registrations
- Find your app (client ID: 9009c416-7543-4667-aa0c-3e4d9c2dee91)
- Go to "Certificates & secrets" → "Client secrets"
- Copy the secret value (or create a new one if expired)

### 2. Update dev.tfvars
Edit `platform-infra/envs/dev/dev.tfvars` and replace:
- `<your-sql-server>` with your actual SQL Server FQDN
- `<your-sql-database>` with your database name
- `<your-sql-username>` with your SQL username
- `<your-spn-secret>` with the SPN secret from step 1

### 3. Grant SPN Permissions
Your SPN needs these roles:

```bash
# Get your resource group (will be created by Terraform)
RESOURCE_GROUP="rg-data-platform-dev"

# Grant Contributor role on the resource group
az role assignment create \
  --assignee 9009c416-7543-4667-aa0c-3e4d9c2dee91 \
  --role "Contributor" \
  --resource-group $RESOURCE_GROUP

# Grant Storage Blob Data Contributor on the storage account (for Terraform state)
az role assignment create \
  --assignee 9009c416-7543-4667-aa0c-3e4d9c2dee91 \
  --role "Storage Blob Data Contributor" \
  --resource-group $RESOURCE_GROUP \
  --scope "/subscriptions/a6250aad-fe4f-4ddd-a7c8-10793cfac5d6/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/stdataplatformdev"
```

### 4. Create Terraform State Backend
```bash
# Create resource group for Terraform state
az group create --name tfstate-rg --location eastus

# Create storage account (use a unique name)
az storage account create \
  --name tfstate$(date +%s) \
  --resource-group tfstate-rg \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name tfstate \
  --account-name <STORAGE_ACCOUNT_NAME_FROM_ABOVE>
```

### 5. Update Azure DevOps Variables
In Azure DevOps, update your variable group `platform-infra-vars`:
```
TF_STATE_RG = tfstate-rg
TF_STATE_SA = <STORAGE_ACCOUNT_NAME_FROM_ABOVE>
TF_STATE_CONTAINER = tfstate
AZURE_SERVICE_CONNECTION_NAME = azure-data-platform-connection
```

### 6. Run the Pipeline
1. Push your code to Azure DevOps
2. The infra pipeline will:
   - Create the resource group
   - Create storage account, key vault, event hubs, databricks, data factory
   - Create ADF linked services
   - Create Unity Catalog resources
   - Create ADF pipelines and triggers

### 7. Update Bundle.yml
After the infrastructure is created, update `data-products/bundle.yml` with the actual Databricks workspace URL from the outputs.

### 8. Test the Setup
Follow the `docs/hello_world.md` guide to test the end-to-end flow.

### Troubleshooting
- **Permission errors**: Ensure SPN has Contributor role on the resource group
- **Storage errors**: Check SPN has Storage Blob Data Contributor role
- **Authentication errors**: Verify SPN secret is correct and not expired 