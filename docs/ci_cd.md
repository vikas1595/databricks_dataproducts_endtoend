## CI/CD with Azure DevOps

### Pipelines
- Infra: `.azure-pipelines/infra.yml` runs Terraform for `dev`, `test`, `prod`.
- Apps: `.azure-pipelines/apps.yml` deploys Databricks Asset Bundles per environment.

### Service connection
- Use OIDC-enabled Azure Service Connection (no secrets).
- Grant least privileges: Contributor on RGs, Storage Blob Data Contributor (state), ADF/Databricks/Purview roles as required.

### Terraform state
- Azure Storage backend; set `TF_STATE_RG`, `TF_STATE_SA`, `TF_STATE_CONTAINER` in a variable group.

### Variables to set
- Infra pipeline: backend vars, and per-env tfvars stored in repo (`envs/<env>/*.tfvars`).
- Apps pipeline: none mandatory; Bundles carry workspace/paths. Optionally set workspace hosts via variables.

### Promotion
- Use ADO Environments with approvals for `test` and `prod`.
- Require green infra before apps using pipeline dependencies. 