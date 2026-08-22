# Working Against Live Infrastructure

When a goal must actually take effect on live AWS infra, use this loop instead of touching resources directly.

## Apply infra through Terragrunt only

Never create, modify, or delete a resource with the `aws` CLI or the console. Terragrunt is the only path from a file to a live resource here. A live edit outside Terraform state drifts or gets reverted on the next apply.

Read-only `aws` CLI calls (`describe-*`, `get-*`, `list-*`) are fine, they don't touch state.

## Authenticate first

Check first with `aws sts get-caller-identity`. If it resolves, skip this step.

Otherwise, ask the user to authenticate. Don't run [Authenticate with AWS](../../README.md#authenticate-with-aws) yourself, `aws configure` and any SSO login are interactive and may touch credentials you shouldn't handle.

## The loop

1. Run `source .env` from the repo root. Stack generation reads required vars (e.g. `SLACK_BOT_TOKEN`) via `get_env`, and fails without them.
2. Edit the source file(s) under `units/` or `pipelines/`. Never edit, copy over, or otherwise hand-patch a file under `.terragrunt-stack/`, that directory is generated output, not a place to fix things by hand even as a shortcut. `terragrunt stack generate` is the only way to refresh it from source, run it, don't work around it.
   Prefer plain `terragrunt stack generate` over `terragrunt stack clean`. `stack generate` alone picks up source changes and is usually enough, check its output confirms the unit as up to date before reaching for `clean`. `clean` also wipes `.terragrunt-cache`, so the next apply re-downloads and re-inits every module in the stack, slow across the whole infra. Reach for it only when `generate` isn't picking up a change, not as a first move. Same rule against hand-editing applies here too, `rm -rf` on the cache yourself instead of `clean` is still working around Terragrunt.
3. Commit and push. Match the existing style, a single-line `type(scope): summary` subject, no body.
4. If `prek`'s hook fails for a reason unrelated to the change (missing local tooling, not a real lint or validation failure), commit with `-n` and tell the user about the gap.
5. Apply, picking the branch that matches the goal:
   - **Testing a specific unit**: from the stack directory, `terragrunt stack generate`, then apply that unit's dependencies first (in dependency-graph order, upstream to downstream), and only then `cd` into its `.terragrunt-stack/<unit>` directory and run `terragrunt apply -auto-approve`. A unit applied on its own without its dependencies already applied fails or plans against stale/mock state.
   - **End-to-end goal**: follow the documented flow instead, from the stack directory: `terragrunt stack generate` then `terragrunt run --all apply --non-interactive --no-stack-generate` (see [Deploy a Dev EKS Cluster](../../README.md#deploy-a-dev-eks-cluster)). Terragrunt sequences the whole graph itself.
6. Verify against the live AWS state (`aws ... describe`/`get`, or the console), not against the plan output.
7. If verification fails, fix the source file and repeat from step 1.

## Don't validate unit source directly

`terragrunt hcl validate --working-dir units/<...>` (or any other terragrunt command run straight against a unit under `units/`) fails with a misleading `must specify a 'path' parameter` error even when the config is correct. `include "root"` and stack-provided values only resolve inside a generated stack. Validate through the normal flow instead: `terragrunt stack generate`, then `terragrunt run --all plan` (or the targeted-unit apply flow above) from `.terragrunt-stack/<unit>`.

## Tearing down

Only destroy when the user asks for it.

- **Testing a specific unit**: `cd` into its `.terragrunt-stack/<unit>` directory and run `terragrunt destroy -auto-approve`. Destroy in reverse dependency order if you're tearing down more than one unit, downstream before upstream, or a downstream unit will fail against a dependency that's already gone.
- **End-to-end goal**: follow the documented flow instead, from the stack directory: read the caution notes in [Destroy the Infrastructure](../../README.md#destroy-the-infrastructure) first (public endpoint and Tailscale ordering matter there), then `terragrunt run --all destroy --non-interactive --no-stack-generate`.
