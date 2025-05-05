# Telegraf

## Configuration

`/etc/telegraf/telegraf/conf`

```toml
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

# Configuration for sending metrics to InfluxDB
[[outputs.influxdb_v2]]
  urls = ["http://192.168.1.XX:8086"]
  token = "API TOKEN"
  organization = "my-org"
  bucket = "proxmox"

[[outputs.prometheus_client]]
  listen = ":9273"
  metric_version = 2
  path = "/metrics"

# Gather metrics from proxmox based on what is in /etc/pve/setup.cfg
[[inputs.socket_listener]]
  service_address = "udp://:8089"

[[inputs.sensors]]
```
