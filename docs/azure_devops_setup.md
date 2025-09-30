## Azure DevOps Setup Guide

### 1. Service Connection
- ✅ You've created the service connection with SPN token
- Name it something like `azure-data-platform-connection` (or whatever you prefer)

### 2. Variable Groups
Create a variable group named `platform-infra-vars` in Azure DevOps:

#### Required Variables:
```
AZURE_SERVICE_CONNECTION_NAME = azure-data-platform-connection
TF_STATE_RG = <your-terraform-state-rg>
TF_STATE_SA = <your-terraform-state-storage-account>
TF_STATE_CONTAINER = tfstate
```

#### Optional Variables (if you want to override defaults):
```
TF_VERSION = 1.7.5
```

### 3. Link Variable Group to Pipelines
- Go to your pipeline `.azure-pipelines/infra.yml`
- Click "Edit" → "Variables"
- Link the `platform-infra-vars` variable group
- Ensure the variables are available

### 4. Terraform State Storage
You need an Azure Storage Account for Terraform state:

```bash
# Create resource group for Terraform state
az group create --name tfstate-rg --location eastus

# Create storage account
az storage account create \
  --name tfstate<unique-suffix> \
  --resource-group tfstate-rg \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name tfstate \
  --account-name tfstate<unique-suffix>

# Get the storage account name and resource group
az storage account list --resource-group tfstate-rg --query "[].name" -o tsv
```

### 5. Test the Setup
1. Push your code to Azure DevOps
2. The infra pipeline should trigger automatically
3. Check that it can authenticate and access your Azure subscription
4. Verify the Terraform state backend can be initialized

### 6. First Run
On first run, you'll need to:
1. Create the Terraform state backend manually (first time only)
2. Ensure your service principal has these roles:
   - Contributor on target resource groups
   - Storage Blob Data Contributor on the tfstate storage account
   - Data Factory Contributor
   - Databricks Workspace Contributor

### Troubleshooting
- **Authentication errors**: Check SPN token expiration and permissions
- **State backend errors**: Verify storage account exists and SPN has access
- **Permission errors**: Ensure SPN has required roles on target resources 