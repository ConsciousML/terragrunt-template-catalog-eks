---
name: app-of-apps-integration
description: Thread a Terraform-sourced value (IAM, Pod Identity, Secrets Manager, ACM, ...) into an app-of-apps Helm value, or add a new app to app-of-apps. Use when an app in argocd-app-of-apps-template needs a value only this repo's Terraform can produce.
---

Follow [`docs/app-of-apps-integration.md`](../../../docs/app-of-apps-integration.md) for the
steps (dependency block on `argocd_app_of_apps`, `appParams` entry, deploy).
