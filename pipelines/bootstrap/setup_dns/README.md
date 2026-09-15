{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# DNS Bootstrap

In this guide, you'll set up your domain to be able to expose your cluster apps through it during the [deployment](/docs/quickstart/deployment/).

:::note
This guide needs to be performed only once per repository fork before running the [deployment](/docs/quickstart/deployment/).
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) creates a public [Route 53](https://aws.amazon.com/route53/) [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html), a container for the DNS records that route traffic to your domain. It's what exposes your internet-facing apps, and what [ACM](https://aws.amazon.com/certificate-manager/) uses to validate their [TLS certificate](https://aws.amazon.com/what-is/ssl-certificate/), so they can be reached over [HTTPS](https://en.wikipedia.org/wiki/HTTPS).

First, we'll update the [`pipelines/dns.hcl`](../../dns.hcl) configuration file in your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```hcl
locals {
  base_domain = "yourdomain.com"
}
```
Replace `yourdomain.com` with your base domain url.

:::info
Each subdirectory provisions its own hosted zone, giving that environment its own subdomain (e.g. `dev.yourdomain.com`):
```
setup_dns/
├── dev/
└── ci/
```
:::

Next, run the following for each environment (replacing `<environment>` with `dev` and then `ci`), from the root directory of [your fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
cd pipelines/bootstrap/setup_dns/<environment>
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Read the [Infrastructure as Code documentation](/docs/iac) for a high-level overview of TG.

:::note
On the first run, `--backend-bootstrap` automatically creates the [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) holding the [Terraform state](https://developer.hashicorp.com/terraform/language/state). More information in the [Terragrunt state backend documentation](https://docs.terragrunt.com/features/units/state-backend/).
:::

Then, retrieve the 4 nameservers from this pipeline output:
```bash
terragrunt stack output --json setup_dns.route53_hosted_zone.name_servers
```

You should see something similar to:
```txt
{
  "setup_dns": {
    "route53_hosted_zone": {
      "name_servers": [
        "<nameserver_1>",
        "<nameserver_2>",
        "<nameserver_3>",
        "<nameserver_4>",
      ]
    }
  }
}
```

In your domain registrar, add 4 NS records for the environment subdomain using the nameservers from the output above.

| Type | Host | Value |
|------|------|-------|
| NS | `<environment>` | `ns-123.awsdns-12.com` |
| NS | `<environment>` | `ns-456.awsdns-34.net` |
| NS | `<environment>` | `ns-789.awsdns-56.org` |
| NS | `<environment>` | `ns-012.awsdns-78.co.uk` |

The NS record type delegates management of `<environment>.yourdomain.com` to Route 53's nameservers.

Finally, verify that the NS records are propagated:
```bash
dig NS <environment>.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`.

You can also confirm this visually in the [Route 53 console](https://console.aws.amazon.com/route53/v2/hostedzones). You should see your newly created hosted zone listed. Click it to see its records.

For more information about this bootstrap, read the [reference documentation](/docs/reference/bootstrap/setup_dns/).
