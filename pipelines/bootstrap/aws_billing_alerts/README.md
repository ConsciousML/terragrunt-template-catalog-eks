{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS Billing Alerts Bootstrap

An EKS cluster's bill can ramp up quickly. In this guide, you'll set up cost alerting notifications for your AWS account, so you're notified before anomalies escalate.

:::warning
This bootstrap is scoped to the AWS account, not a repo or environment: only run it in your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), and only once per account.
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) sets up [Cost Anomaly Detection](https://docs.aws.amazon.com/cost-management/latest/userguide/getting-started-ad.html) (CAD), which flags unusual spend a fixed budget wouldn't catch, and emails you when it does.

First, find the ARN of your account's `SERVICE`-dimension CAD monitor, AWS auto-creates one for every account:
```bash
aws ce get-anomaly-monitors --output json \
  --query "AnomalyMonitors[?MonitorDimension=='SERVICE'].MonitorArn | [0]"
```

Add it to your `.env`, this pipeline reuses it rather than creating a new one, which would fail since one already exists for the `SERVICE` dimension:
```bash
export BILLING_ANOMALY_MONITOR_ARN=<your_arn>
```

This pipeline also creates two [AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html), which email you when spend crosses a threshold you set.

In this bootstrap's [stack file](terragrunt.stack.hcl), replace the placeholder `emails` with your own:
```hcl
locals {
  emails = ["you@example.com"] # notified by both budgets and the anomaly subscription
}
```

Now deploy the pipeline. From the root of your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog) run:
```bash
source .env
cd pipelines/bootstrap/aws_billing_alerts
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

You can confirm this visually in the AWS console. Your two budgets appear in the [Budgets console](https://console.aws.amazon.com/billing/home#/budgets).

In your [Cost Anomaly Detection console](https://console.aws.amazon.com/cost-management/home#/anomaly-detection/overview?activeTab=subscriptions), you should see the `anomaly-subscription` appear under `Alert subscriptions`. Click on it and your email should show in the subscribers.

:::info
For this quickstart, keep the threshold defaults already set in the stack file above. Once you've observed real costs, come back and align using the [`billing_budgets`](/docs/reference/bootstrap/aws_billing_budgets/) and [`billing_anomaly_detection`](/docs/reference/bootstrap/aws_billing_anomaly_detection/) reference documentation.
:::
