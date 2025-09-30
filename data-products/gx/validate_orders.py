# Databricks notebook source
# MAGIC %pip install --quiet great_expectations>=0.18.12

# COMMAND ----------
import os
import json
from datetime import datetime

import great_expectations as gx
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

# Inputs
SILVER_PATH = os.environ.get("SILVER_PATH", "abfss://lake@<storage>.dfs.core.windows.net/silver/sales_orders")
TABLE_NAME = os.environ.get("TABLE_NAME", "orders")
RESULTS_TABLE = os.environ.get("RESULTS_TABLE", "sales_orders.gold.dq_results")

# Load data
df = spark.read.format("delta").load(f"{SILVER_PATH}")

# Create ephemeral GX context and Spark datasource
context = gx.get_context(mode="ephemeral")
ds = context.sources.add_or_update_spark(name="spark")
asset = ds.add_dataframe_asset(name="orders_df")
batch_request = asset.build_batch_request(dataframe=df)

# Create expectation suite programmatically (or load from repo if preferred)
suite = context.suites.add_or_update("orders_suite")

validator = context.get_validator(batch_request=batch_request, expectation_suite=suite)
validator.expect_column_values_to_not_be_null("id")
validator.expect_column_values_to_be_in_set("status", ["NEW", "COMPLETE", "CANCELLED"]) 
# If present in data
try:
    validator.expect_column_values_to_not_be_null("updated_at")
except Exception:
    pass

# Validate
result = validator.validate()

# Prepare and persist results to a Delta table
summary = {
    "timestamp": datetime.utcnow().isoformat() + "Z",
    "table": TABLE_NAME,
    "success": result.success,
    "statistics": result.statistics,
    "expectations": [
        {
            "expectation_type": r.expectation_config.expectation_type,
            "success": r.success,
            "result": r.result,
        }
        for r in result.results
    ],
}

result_df = spark.createDataFrame([json.dumps(summary)])
result_df = spark.read.json(result_df.rdd.map(lambda x: x[0]))

# Create database/schema if needed and write results
catalog_schema, table = RESULTS_TABLE.rsplit(".", 1) if "." in RESULTS_TABLE else ("", RESULTS_TABLE)
result_df.write.mode("append").format("delta").saveAsTable(RESULTS_TABLE)

# Optionally fail the job if critical expectations failed
critical_fail = any(e["expectation_type"] in [
    "expect_column_values_to_not_be_null",
    "expect_column_values_to_be_in_set",
] and not e["success"] for e in summary["expectations"])

if critical_fail:
    raise Exception("Great Expectations validation failed for critical checks") 