# Working Against Live Infrastructure

When a goal must actually take effect on live AWS infra, use this loop instead of touching resources directly.

## Apply infra through Terragrunt only

Never create, modify, or delete a resource with the `aws` CLI or the console. Terragrunt is the only path from a file to a live resource here. A live edit outside Terraform state drifts or gets reverted on the next apply.

Read-only `aws` CLI calls (`describe-*`, `get-*`, `list-*`) are fine, they don't touch state.

## Authenticate first

Check first with `aws sts get-caller-identity`. If it resolves, skip this step.

Otherwise, ask the user to authenticate. Don't run [Authenticate with AWS](../../README.md#authenticate-with-aws) yourself, `aws configure` and any SSO login are interactive and may touch credentials you shouldn't handle.

## The loop

1. Edit the source file(s) under `units/` or `pipelines/`. Never edit, copy over, or otherwise hand-patch a file under `.terragrunt-stack/`, that directory is generated output, not a place to fix things by hand even as a shortcut. `terragrunt stack generate` is the only way to refresh it from source, run it, don't work around it.
2. Commit and push. Match the existing style, a single-line `type(scope): summary` subject, no body.
3. If `prek`'s hook fails for a reason unrelated to the change (missing local tooling, not a real lint or validation failure), commit with `-n` and tell the user about the gap.
4. Apply, picking the branch that matches the goal:
   - **Testing a specific unit**: from the stack directory, `terragrunt stack generate`, then apply that unit's dependencies first (in dependency-graph order, upstream to downstream), and only then `cd` into its `.terragrunt-stack/<unit>` directory and run `terragrunt apply`. A unit applied on its own without its dependencies already applied fails or plans against stale/mock state.
   - **End-to-end goal**: follow the documented flow instead, from the stack directory: `terragrunt stack generate` then `terragrunt run --all apply --non-interactive --no-stack-generate` (see [Deploy a Dev EKS Cluster](../../README.md#deploy-a-dev-eks-cluster)). Terragrunt sequences the whole graph itself.
5. Verify against the live AWS state (`aws ... describe`/`get`, or the console), not against the plan output.
6. If verification fails, fix the source file and repeat from step 1.

## Tearing down

Only destroy when the user asks for it.

- **Testing a specific unit**: `cd` into its `.terragrunt-stack/<unit>` directory and run `terragrunt destroy`. Destroy in reverse dependency order if you're tearing down more than one unit, downstream before upstream, or a downstream unit will fail against a dependency that's already gone.
- **End-to-end goal**: follow the documented flow instead, from the stack directory: read the caution notes in [Destroy the Infrastructure](../../README.md#destroy-the-infrastructure) first (public endpoint and Tailscale ordering matter there), then `terragrunt run --all destroy --non-interactive --no-stack-generate`.
