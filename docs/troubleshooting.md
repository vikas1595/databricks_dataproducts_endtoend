## Troubleshooting

### Terraform
- ADF linked services missing: create or reference existing LS names in `dev.tfvars`.
- Permission errors: verify service connection roles and MI access to ADLS/SQL/EH.

### Databricks Bundles
- Auth failures: ensure Azure CLI auth in pipeline and correct workspace host.
- Path errors: ensure notebook paths in `bundle.yml` match repo paths.

### DQ
- DLT expectation failures: review DLT event logs and metrics.
- GX job failures: check `RESULTS_TABLE` exists and the cluster has network access to ADLS.

### Event Hubs
- Consumer group not found: ensure metadata names match and infra applied.
- Auth errors: validate connection string/secret scope or MI-based auth if used. 