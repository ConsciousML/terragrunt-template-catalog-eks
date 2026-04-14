# AWS Route53 Hosted Zone Module

This module creates a Route53 public hosted zone for a given domain name.

After applying, retrieve the `name_servers` output and add all 4 NS records to your domain registrar before running any stack that depends on DNS validation (e.g. ACM certificate issuance).
