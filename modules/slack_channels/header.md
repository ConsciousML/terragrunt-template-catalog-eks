# Slack Channels Module

This module creates Slack channels from a list of base names, prefixing each with the environment name (e.g. `k8s-critical` becomes `dev-k8s-critical`). Use it to provision the channels Alertmanager's routing config sends to.
