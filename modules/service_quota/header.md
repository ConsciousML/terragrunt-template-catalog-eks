# AWS Service Quota Module

This module requests an increase for a single AWS Service Quota via `aws_servicequotas_service_quota`. `service_code` and `quota_code` identify the quota (e.g. `ec2` / `L-1216C47A` for On-Demand Standard vCPUs); `desired_value` is the requested value.
