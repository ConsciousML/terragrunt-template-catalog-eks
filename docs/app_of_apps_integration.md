# Adding an App to App of Apps

GitOps application delivery is split across two repositories:

- **[argocd-app-of-apps-template](https://github.com/ConsciousML/argocd-app-of-apps-template)**: owns the chart/manifests for each app and the `apps/values.yaml` list of ArgoCD `Application` entries. See its [README "Adding an App" section](https://github.com/ConsciousML/argocd-app-of-apps-template#adding-an-app) for those steps — this doc does not repeat them.
- **This repo**: owns any AWS-side Terraform an app needs (IAM/Pod Identity, Secrets Manager secrets, ACM certs, ...) and threads those values into the app-of-apps `Application` CR so the app-of-apps repo never hardcodes environment-specific values.

This doc covers only the catalog-side plumbing: how a value produced by Terraform ends up as a Helm value on a child `Application` in the app-of-apps repo.

## How values flow into a child app

The root `Application` resource is created by `units/eks/addons/argocd/app_of_apps`, wrapping [`modules/argocd_app_of_apps`](../modules/argocd_app_of_apps/). Its `helm_values.appParams` map is injected as `spec.source.helm.values` on the root `Application` (see [`app-of-apps.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/app-of-apps.yaml) in the template repo for the resulting shape). The app-of-apps repo's `apps/templates/applications.yaml` then looks up `appParams.<app-name>` for each entry in `apps/values.yaml` and passes it as `spec.source.helm.values` on that child `Application` — so whatever you put under a given app's key in `appParams` becomes that app's Helm values at sync time.

The key in `appParams` must match the app's `name` in `apps/values.yaml`, not its `path` (they can differ — see the generic-chart case below).

## Steps

### 1. Decide if the app needs any Terraform-sourced values at all

Some apps need nothing dynamic (e.g. `helm-external-secrets-operator` has no `appParams` entry at all — its `values.yaml` defaults are sufficient). If that's your case, skip straight to the app-of-apps repo's "Adding an App" steps and stop reading here.

### 2. Add any AWS-side Terraform the app needs

If the app needs an IAM role, Pod Identity association, or a Secrets Manager secret, add/uncomment the relevant unit(s) in [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](../pipelines/dev/eks/stack/terragrunt.stack.hcl), following the existing IAM-role-only units (e.g. `iam_role_aws_lbc`, `iam_role_eso`) as a template. Only the AWS-side resource belongs in Terraform — the Kubernetes Deployment/manifests for the app itself belong in the app-of-apps repo.

### 3. Wire a `dependency` block in `argocd_app_of_apps`

In `units/eks/addons/argocd/app_of_apps/terragrunt.hcl`, add a `dependency` block for whatever unit produces the value(s) you need. Use `skip_outputs = true` if you only need Terragrunt's apply ordering and don't actually reference an output; otherwise supply `mock_outputs` so `plan`/`validate` still work before the dependency has been applied:

```hcl
dependency "argocd_password" {
  config_path = "../aws_password_secret"
  mock_outputs = {
    secret_name = "mock-argocd-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}
```

### 4. Add the app's entry to `appParams`

In the same file's `inputs.helm_values.appParams`, add a key matching the app's `name` from `apps/values.yaml`, with whatever shape that app's chart `values.yaml` expects:

```hcl
"argocd-secrets" = {
  secretStoreName = "${include.root.locals.environment}-aws-secrets-manager"
  awsRegion       = include.root.locals.aws_region
  externalSecrets = [
    {
      name                 = "argocd-admin-password"
      targetSecretName     = "argocd-secret"
      targetCreationPolicy = "Merge"
      refreshPolicy        = "CreatedOnce"
      data = [
        {
          secretKey      = "admin.password"
          remoteKey      = dependency.argocd_password.outputs.secret_name
          remoteProperty = "bcrypt_hash"
        }
      ]
    }
  ]
}
```

If the app wraps an upstream Helm chart with a subchart alias (e.g. `helm-aws-lbc` depending on the `aws-load-balancer-controller` chart), nest the values one level under that subchart's name, same as the existing `helm-aws-lbc`/`helm-external-dns-*` entries.

### 5. Reuse a generic chart instead of authoring a new one, when possible

Some apps in the app-of-apps repo are generic and meant to back multiple `Application` entries (e.g. `helm-eso-secret-sync`, which renders an ESO `SecretStore` + a list of `ExternalSecret`s from plain values — used today by the `argocd-secrets` entry). If the app you're adding is "another instance of a pattern that already exists" rather than something new, check whether an existing chart already covers it before writing a new one.

To reuse a generic chart, give the `apps/values.yaml` entry a distinct `name` (this is both the `Application` name and the `appParams` key) and a `path` pointing at the shared chart directory:

```yaml
  - name: argocd-secrets
    path: helm-eso-secret-sync
    destination:
      namespace: argocd
    syncWave: 1
```

Then supply that instance's values under its own `appParams` key, as in step 4 — no new chart or template files needed.

## Verifying end to end

- **app-of-apps repo**: `helm lint <app-dir>` and `helm template <app-dir>` (with representative `--set`/`-f` values matching what Terraform will send) to confirm the chart renders as expected. The repo's own CI (`prek run`, or `scripts/validate-helm.sh`/`scripts/validate-manifests.sh`) runs the same checks on every PR.
- **This repo**: `cd pipelines/dev/eks/stack && terragrunt stack generate && terragrunt run --all validate` to confirm the new `dependency` block and `appParams` entry resolve without dangling references.
