## Streaming with Event Hubs

### Metadata
- Add a source with `type: eventhub` in the product YAML:
```yaml
- name: events_orders
  type: eventhub
  namespace: ehns-prod
  eventhub: orders
  consumer_group: sales-orders-bronze
  schedule: streaming
```

### Infra
- The `event_hub_consumer_group` module creates the consumer group per event source.
- Provision the Event Hubs namespace/hubs separately or add modules as needed.

### Databricks streaming
- Use Structured Streaming to read from the Kafka-compatible endpoint and write Delta to bronze.
```python
kafka_df = (spark.readStream.format("kafka")
  .option("kafka.bootstrap.servers", "<ns>.servicebus.windows.net:9093")
  .option("subscribe", "orders")
  .option("kafka.security.protocol", "SASL_SSL")
  .option("kafka.sasl.mechanism", "PLAIN")
  .option("kafka.sasl.jaas.config", f'kafkashaded.org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="{conn_str}";')
  .load())
``` 