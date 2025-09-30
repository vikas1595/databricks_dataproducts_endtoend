## Governance and RBAC

### Model
- One Unity Catalog catalog per data product
- Schemas: `bronze`, `silver`, `gold`
- External location on ADLS per product base path

### Groups
- Azure AD groups per product:
  - Admins: full control
  - Producers: write to external location, create/modify tables
  - Consumers: read-only

### Grants (enforced via Terraform)
- Catalog grants: admins (ALL_PRIVILEGES), producers (CREATE/SELECT/MODIFY), consumers (SELECT)
- External location: producers get READ_FILES/WRITE_FILES/CREATE_TABLE

### Optional masking
- Use views for column masking or row filters. Maintain these as code in `data-products/` and grant consumers on the views. 