# Tailscale Bootstrap

EKS Forge deploys internal tooling (ArgoCD, Prometheus, etc.) that your team needs as private endpoints inside your VPC. These endpoints are not accessible from the public internet.

In this guide, you'll set up [Tailscale](https://tailscale.com/docs/concepts/what-is-tailscale) as a VPN to access internal tools without exposing them to the internet, as well as allow CI to authenticate to Tailscale to create the resources required to bring up the VPN.

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).

Only instantiate the `acl` unit in the [catalog repository](https://github.com/ConsciousML/terragrunt-template-catalog-eks). It's a single tailnet-wide policy, not scoped to an environment.
:::

First, create an account and [login to Tailscale](https://login.tailscale.com/admin/welcome).

Then, download and install the [Tailscale client](https://tailscale.com/download).

Next, set up `GITHUB_TOKEN` in the [environment variables guide](/docs/reference/environment_variable/#github_token).

To authenticate Terraform with Tailscale, create an [OAuth client and fill the `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`](/docs/reference/environment_variable/#tailscale_oauth_client_id-and-tailscale_oauth_client_secret) environment variable in your `.env` file.

A [tailnet](https://tailscale.com/docs/concepts/tailnet) is your private Tailscale network. This is what will allow you to reach the internal tools inside the cluster.

Tailscale needs two things set up to work this way: 
- The [Access Control (ACL)](https://tailscale.com/docs/features/access-control/acls) is the tailnet's central policy defining the resources' permission.
- [Workload Identity Federation](https://tailscale.com/docs/features/workload-identity-federation) is a per-repository credential that lets CI prove its identity to Tailscale without a stored secret.

The ACL must exist first, since WIF's credential is scoped to a tag (`tag:ci`) only the ACL defines. Deploy the two pipelines in the right order, from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):

```bash
source .env
cd pipelines/bootstrap/tailscale/acl
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

```bash
cd ../wif
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Now let's explore the resources you have created using the Tailscale admin console. Launch the Tailscale client that you have installed (or run `tailscale up` in your terminal) and go to [My Machines](https://console.tailscale.com/admin/machines). Here, you should see your local machine connected to the tailnet.

In the [ACL JSON Editor](https://console.tailscale.com/admin/acls/file), your ACL file should contain `autoApprovers` and `tagOwners`.

On your repository's GitHub page, go to `Settings > Secrets and variables > Actions`. Under `Repository secrets`, you should see `TS_OAUTH_CLIENT_ID`, `TS_AUDIENCE`, and `TS_TAGS` (values stay hidden, only the names are shown). These are the secrets GitHub Actions uses to authenticate with Tailscale.

For more information, read:
- [how Tailscale has been implemented](/docs/security/tailscale/) in EKS Forge
- the [`tailscale/acl`](/docs/reference/bootstrap/tailscale_acl/) reference documentation
- the [`tailscale/wif`](/docs/reference/bootstrap/tailscale_wif/) reference documentation
- the [Infrastructure as Code](/docs/iac/) documentation
