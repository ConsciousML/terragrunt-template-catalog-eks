{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
import DocCards from '@site/src/components/DocCards';
import {DollarSign, KeyRound, Gauge, Globe, MessageSquare, Network} from 'lucide-react';

# Bootstrap Pipelines

EKS Forge's [advanced features](/docs/overview/#features) rely on several tools (AWS, [Tailscale](https://tailscale.com/), [Slack](https://slack.com/intl/en-gb/), etc.) that need to be configured before you deploy the infrastructure. **Bootstrap pipelines** automate these configurations.

They're [Terragrunt stacks](/docs/architecture/#catalog-architecture) that deploy account-level and repository-level resources, independent of any IaC environment (`dev`, `staging`, etc.). Each environment depends on these resources to function, so bootstrap pipelines need to run first.

Complete each of these one-time setup guides:

<DocCards columns={2} items={[
  {
    icon: <Globe size={36} color="var(--ifm-color-primary-dark)" />,
    title: 'Setup DNS',
    description: 'Gives your apps a real domain name and HTTPS, so they can be reached securely from the internet',
    link: '/docs/quickstart/bootstrap/setup_dns',
  },
  {
    icon: <KeyRound size={36} color="var(--ifm-color-primary-dark)" />,
    title: 'AWS GitHub Actions Authentication',
    description: 'Lets GitHub Actions deploy your infrastructure and apps to AWS, without storing long-lived AWS keys',
    link: '/docs/quickstart/bootstrap/aws_gh_actions_auth',
  },
  {
    icon: <Network size={36} color="var(--ifm-color-primary-dark)" />,
    title: 'Tailscale',
    description: 'Lets you securely reach internal tools (ArgoCD, Grafana, etc.) over VPN, without exposing them to the public internet',
    link: '/docs/quickstart/bootstrap/tailscale',
  },
  {
    icon: <MessageSquare size={36} color="var(--ifm-color-primary-dark)" />,
    title: 'Slack',
    description: 'Sends your cluster and infrastructure alerts to a Slack channel',
    link: '/docs/quickstart/bootstrap/slack',
  },
  {
    icon: <Gauge size={36} color="var(--ifm-color-primary-dark)" />,
    title: 'AWS Service Quotas',
    description: 'Raises your AWS account limits so it can actually launch enough servers for your cluster',
    link: '/docs/quickstart/bootstrap/aws_service_quotas',
  },
  {
    icon: <DollarSign size={36} color="var(--ifm-color-primary-dark)" />,
    title: 'AWS Billing Alerts',
    description: 'Emails you before cloud spend gets out of hand, whether it crosses a budget or spikes unexpectedly',
    link: '/docs/quickstart/bootstrap/aws_billing_alerts',
  },
]} />

**Caution**: if you want to change the code of these pipelines, read the [For Developers section](../../stacks/README.md#for-developers).