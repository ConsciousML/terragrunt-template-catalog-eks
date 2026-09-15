{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Slack Channels Bootstrap

The [`slack_channels` stack](../../stacks/slack_channels/), deployed by the [`slack/channels` pipeline](../../pipelines/bootstrap/slack/channels/), creates that environment's Slack channels, prefixed with the environment name (e.g. `dev-k8s-critical`), so the same shared bot can post every environment's alerts without colliding on one channel. Run once per environment.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/slack).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `slack_channels` | [`units/slack/channels`](../../units/slack/channels/) | [`modules/slack_channels`](../../modules/slack_channels/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `bot_token` | Slack bot token with `channels:read`, `channels:manage`, `channels:join` scopes. | `string` | - | Yes |
| `environment` | Environment name (e.g. `dev`, `staging`, `prod`) used to prefix every channel name so environments don't collide in the same workspace. | `string` | - | Yes |
| `channel_names` | Base channel names (no environment prefix, no leading `#`) to create, one per Alertmanager receiver. Defined in [`channels.hcl`](../../pipelines/bootstrap/slack/channels.hcl). | `list(string)` | - | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `channel_names` | Environment-prefixed names of the channels that were created. |
