# AWS Billing Alarm Module

This module creates a CloudWatch alarm on estimated AWS charges for each threshold provided, all notifying a shared SNS topic with optional email subscriptions.

`AWS/Billing` metric data is only published in `us-east-1` and requires the "Receive CloudWatch Billing Alerts" account preference to be enabled once via the Billing console, this module cannot enable it.
