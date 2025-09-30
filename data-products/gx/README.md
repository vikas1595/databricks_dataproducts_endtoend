Great Expectations (GX) integration

- validate_orders.py: Databricks-compatible script to validate the silver orders Delta dataset and write results to a Delta table, failing the job on critical errors.
- orders_suite.yaml: Optional declarative suite; you can load and apply it instead of code-defined checks.

How to run
- As a Databricks job task (Python script) after DLT Silver finishes.
- Pass env vars (or job params) for paths and results table:
  - SILVER_PATH: abfss://.../silver/sales_orders
  - TABLE_NAME: orders
  - RESULTS_TABLE: sales_orders.gold.dq_results

Promotion & config
- Keep suites in version control per data product, e.g., data-products/gx/<product>_suite.yaml.
- Add more GX expectations as needed (nulls, ranges, regex, foreign keys using joins in Spark before validation). 