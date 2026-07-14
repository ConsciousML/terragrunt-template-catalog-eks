# Adding an App to App of Apps

GitOps application delivery is split across two repositories:

- **[argocd-app-of-apps-template](https://github.com/ConsciousML/argocd-app-of-apps-template)**: owns the chart/manifests for each app and the `apps/values.yaml` list of ArgoCD `Application` entries. See its [README "Adding an App" section](https://github.com/ConsciousML/argocd-app-of-apps-template#adding-an-app) for those steps.
- **This repo**: owns any Terraform resource an app needs (IAM/Pod Identity, Secrets Manager secrets, ACM certs, ...) and threads those values into the app-of-apps `Application` CR so the app-of-apps repo never hardcodes environment-specific values.

This doc covers only the catalog-side plumbing: how a value produced by Terraform ends up as a Helm value on a child `Application` in the app-of-apps repo.

## Integration Flow

The root `Application` resource is created by [`units/eks/addons/argocd/app_of_apps`](../units/eks/addons/argocd/app_of_apps/), wrapping [`modules/argocd_app_of_apps`](../modules/argocd_app_of_apps/). Its `helm_values.appParams` map is injected as `spec.source.helm.values` on the root `Application`. See each app's `values.yaml` in the template repo for the shape it expects.

The app-of-apps repo's `apps/templates/applications.yaml` then looks up `appParams.<app-name>` for each entry in `apps/values.yaml`. It passes that value as `spec.source.helm.values` on the matching child `Application`. Whatever you put under an app's key in `appParams` becomes that app's Helm values at sync time.

The key in `appParams` must match the app's `name` in `apps/values.yaml`, not its `path` (they can differ. See the generic-chart case below).

## Steps

### Decide if the App Needs Any Terraform-Sourced Values at All

Some apps need nothing dynamic (e.g. `helm-external-secrets-operator` has no `appParams` entry at all: its `values.yaml` defaults are sufficient). If that's your case, skip straight to the app-of-apps repo's "Adding an App" steps and stop reading here.

### Add Any AWS-Side Terraform the App Needs

If the app needs an IAM role, Pod Identity association, or a Secrets Manager secret, create the required Terraform resources following the [development guide](development.md).

### Wire a `dependency` Block in `argocd_app_of_apps`

In `units/eks/addons/argocd/app_of_apps/terragrunt.hcl`, add a `dependency` block for whatever unit produces the value(s) you need. Use `skip_outputs = true` if you only need Terragrunt's apply ordering and don't actually reference an output. Otherwise supply `mock_outputs` so `plan`/`validate` still work before the dependency has been applied:

```hcl
dependency "argocd_password" {
  config_path = "../aws_secret_password"
  mock_outputs = {
    secret_name = "mock-argocd-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}
```

### Add the App's Entry to `appParams`

In the [app of apps unit](../units/eks/addons/argocd/app_of_apps/terragrunt.hcl), under `inputs.helm_values.appParams`, add a key matching the app's `name` from [`apps/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/apps/values.yaml), with whatever shape that app's chart `values.yaml` expects:

```hcl
"argocd-secrets" = {
  secretStoreName = "${include.root.locals.environment}-aws-secrets-manager"
  awsRegion       = include.root.locals.aws_region
  remoteKey       = dependency.argocd_password.outputs.secret_name
}
```

Only inject values that trace back to a `dependency` block or a genuine Terraform-owned fact (region, cluster name, ARNs, hostnames, secret names). Anything static or chart-known (`targetSecretName`, `targetCreationPolicy`, `data`, annotations, ports, and so on) belongs as a default in the app-of-apps repo instead, typically via a dedicated `extraValueFiles` entry (see `helm-eso-secret-sync/argocd-secrets-values.yaml` in that repo for this exact app).

The one exception is when composing a value requires string interpolation shared across multiple appParams entries (Helm/YAML values files can't do that, only HCL locals can). See `local.kube_prometheus_stack_release` in the same `terragrunt.hcl` for an example.

If the app wraps an upstream Helm chart with a subchart alias (e.g. `helm-aws-lbc` depending on the `aws-load-balancer-controller` chart), nest the values one level under that subchart's name, same as the existing `helm-aws-lbc` and `helm-external-dns-*` entries.

### Reuse a Generic Chart or Author a New One

Follow the [documentation to add an app](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/README.md#adding-an-app) in the App of Apps repository.

Ensure that the new app `name` you'll use in [`apps/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/apps/values.yaml) matches the one from the previous step.

### Deploy Your New App
1. Commit and push changes in both repositories
2. In the [EKS stack file](../pipelines/dev/eks/stack/terragrunt.stack.hcl), under the `argocd_app_of_apps` unit, change `target_revision` to match your branch name in the app of apps repository.
3. [Deploy the EKS stack](../README.md#deploy-a-dev-eks-cluster)
4. [Log into the ArgoCD UI](../README.md#log-in-to-argocd) and verify your app has been deployed.
