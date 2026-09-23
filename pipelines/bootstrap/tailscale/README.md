{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Tailscale Bootstrap

EKS Forge deploys internal tooling (ArgoCD, Prometheus, etc.) that your team needs as private endpoints inside your VPC. These endpoints are not accessible from the public internet.

In this guide, you'll set up [Tailscale](https://tailscale.com/docs/concepts/what-is-tailscale) as a VPN to reach these tools, and let CI authenticate to Tailscale to provision it.

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).
:::

First, [log in to Tailscale](https://login.tailscale.com/admin/welcome).

Then, download and install the [Tailscale client](https://tailscale.com/download).

Next, set up `GITHUB_TOKEN` in the [environment variables guide](/docs/reference/environment_variable/#github_token).

To authenticate Terraform with Tailscale, create an OAuth client and fill the [`TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`](/docs/reference/environment_variable/#tailscale_oauth_client_id-and-tailscale_oauth_client_secret) environment variables in your `.env` file.

You'll deploy two pipelines into your [tailnet](https://tailscale.com/docs/concepts/tailnet), your private Tailscale network:
- the [Access Control (ACL)](https://tailscale.com/docs/features/access-control/acls), the tailnet's permission policy
- [Workload Identity Federation](https://tailscale.com/docs/features/workload-identity-federation) (WIF), which lets CI authenticate to Tailscale without a stored secret

Deploy the ACL first, since WIF relies on the `tag:ci` the ACL defines. From the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), run:

```bash
source .env
cd pipelines/bootstrap/tailscale/acl
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Then, deploy the WIF pipeline:
```bash
cd ../wif
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Now, explore the resources you have created using the Tailscale admin console. Launch the Tailscale client that you have installed (or run `tailscale up` in your terminal) and go to [My Machines](https://console.tailscale.com/admin/machines). Here, you should see your local machine connected to the tailnet.

In the [ACL JSON Editor](https://console.tailscale.com/admin/acls/file), your ACL file should contain `autoApprovers` and `tagOwners`.

Finally, list the GitHub Actions secrets of your fork:
```bash
gh secret list
```

You should see `TS_OAUTH_CLIENT_ID`, `TS_AUDIENCE`, and `TS_TAGS`. These are the secrets GitHub Actions uses to authenticate with Tailscale.

For more information, read:
- [how Tailscale has been implemented](/docs/security/tailscale/) in EKS Forge
- the [`tailscale/acl`](/docs/reference/bootstrap/tailscale_acl/) reference documentation
- the [`tailscale/wif`](/docs/reference/bootstrap/tailscale_wif/) reference documentation
- the [Infrastructure as Code](/docs/iac/) documentation
