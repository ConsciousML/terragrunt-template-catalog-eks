# AWS Billing Budget Module

This module creates an AWS Budget that sends an email notification for each configured USD threshold whenever monthly spend crosses it. Set `notification_type` to `"ACTUAL"` or `"FORECASTED"` depending on whether thresholds should compare against actual or forecasted spend.
