{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS Billing Alerts Bootstrap

An EKS cluster's bill can ramp up quickly. In this guide, you'll set up cost alerting notifications for your AWS account, so you're notified before anomalies escalate.

:::warning
This guide needs to be performed only once per AWS account, from your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), before running the [deployment](/docs/quickstart/deployment/).
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) deploys two stacks:
- `billing_anomaly_detection`, which sets up [Cost Anomaly Detection](https://docs.aws.amazon.com/cost-management/latest/userguide/getting-started-ad.html) (CAD) to flag unusual spend a fixed budget wouldn't catch, and emails you when it does
- `billing_budgets`, which creates two [AWS Budgets](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html) that email you when spend crosses a threshold you set

First, find the ARN of your account's `SERVICE`-dimension CAD monitor. AWS auto-creates one for every account:
```bash
aws ce get-anomaly-monitors --output json \
  --query "AnomalyMonitors[?MonitorDimension=='SERVICE'].MonitorArn | [0]"
```

Add it to your `.env` so the pipeline reuses it:
```bash
export BILLING_ANOMALY_MONITOR_ARN=<your_arn>
```

In this bootstrap's [stack file](terragrunt.stack.hcl), replace the `emails` value with your own:
```hcl
locals {
  emails = ["you@example.com"] # notified by both budgets and the anomaly subscription
}
```

Next, run the following [Terragrunt commands](/docs/iac) from the root directory of your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/aws_billing_alerts
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Then, list your budgets:
```bash
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text) --query "Budgets[].BudgetName"
```

You should see `estimated-charges` and `estimated-charges-forecast`.

Finally, list your anomaly subscriptions and their subscribers:
```bash
aws ce get-anomaly-subscriptions --query "AnomalySubscriptions[].[SubscriptionName, Subscribers[].Address]"
```

You should see `anomaly-subscription` with your email as a subscriber.

:::info
For this quickstart, keep the threshold defaults already set in the stack file above. Once you've observed real costs, come back and adjust them using the [`billing_budgets`](/docs/reference/bootstrap/aws_billing_budgets/) and [`billing_anomaly_detection`](/docs/reference/bootstrap/aws_billing_anomaly_detection/) reference documentation.
:::
