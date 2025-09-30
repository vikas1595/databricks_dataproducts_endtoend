## Data quality

### DLT expectations (inline)
- Define expectations in your DLT tables:
```python
@dlt.expect_or_drop("id_not_null", "id IS NOT NULL")
@dlt.expect_or_fail("valid_status", "status IN ('NEW','COMPLETE','CANCELLED')")
@dlt.table
def sil_table():
    return dlt.read("brz_table")
```
- Use `expect`, `expect_or_drop`, `expect_or_fail` appropriately.
- Metrics visible in DLT UI and event logs.

### Rules-as-config
- Keep rules in YAML (`data-products/dq/*.yaml`) and apply in code.

### Great Expectations (GX)
- Script: `data-products/gx/validate_orders.py` reads Delta from silver and validates using GX.
- Results saved to a Delta table (e.g., `<catalog>.gold.dq_results`).
- Configure as a job in `bundle.yml` and schedule after the DLT pipeline.

### Quarantine and triage
- For failed rows in bronze/silver, write to a `quarantine/` path and alert if threshold exceeded.

### Governance
- Surface DQ metrics in dashboards; gate promotions if critical checks fail. 