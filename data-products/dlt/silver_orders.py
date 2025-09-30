import dlt, yaml
from pyspark.sql.functions import to_timestamp, col

# Load DQ rules (expectations)
with open("/Workspace/Repos/data-products/dq/orders.yaml") as f:
    dq = yaml.safe_load(f).get("checks", [])

@dlt.table(name="brz_sales_orders")
def brz_sales_orders():
    # Expect bronze ingestion from ADF landing to ADLS; path is provided via configuration if needed
    return (spark.read.format("cloudFiles")
            .option("cloudFiles.format", "csv")
            .load(spark.conf.get("bronze_path", "abfss://lake@<storage>.dfs.core.windows.net/bronze/sales_orders/sql_orders")))

def apply_expectations(df):
    # Apply DLT expectations from dq rules
    for rule in dq:
        name = rule.get("name")
        expr = rule.get("expr")
        action = rule.get("action", "warn")
        if not name or not expr:
            continue
        if action == "fail":
            df = dlt.expect_or_fail(name, expr)(lambda: df)()
        elif action == "drop":
            df = dlt.expect_or_drop(name, expr)(lambda: df)()
        else:
            df = dlt.expect(name, expr)(lambda: df)()
    return df

@dlt.table(name="sil_sales_orders")
def sil_sales_orders():
    df = dlt.read("brz_sales_orders").withColumn("updated_at_ts", to_timestamp(col("updated_at")))
    return apply_expectations(df) 