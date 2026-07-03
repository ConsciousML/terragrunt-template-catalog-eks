# Troubleshooting

## Manually Removing a Terragrunt State

Sometimes you need to fully remove a module's state.

For example, when the state references resources that no longer exist.

This requires deleting the state file in S3 **and** the corresponding digest entry in DynamoDB. Doing only one will cause Tofu to error on the next run.

### Steps

**1. Delete the state file in S3:**

Go to the S3 bucket and delete the `.tfstate` file for the module, or use the CLI:

```bash
aws s3 rm s3://<bucket>/<path/to/module>/tofu.tfstate
```

**2. Find the stale DynamoDB entry:**

```bash
aws dynamodb scan \
  --table-name terragrunt_lock_table \
  --filter-expression "contains(LockID, :fragment)" \
  --expression-attribute-values '{":fragment": {"S": "<path/to/module>"}}' \
  --query "Items[*].LockID.S" \
  --output text
```

**3. Delete the digest entry** (the one ending in `-md5`):

```bash
aws dynamodb delete-item \
  --table-name terragrunt_lock_table \
  --key '{"LockID": {"S": "<bucket>/<path/to/module>/tofu.tfstate-md5"}}'
```

**4. Verify the state is gone:**

```bash
terragrunt init
terragrunt plan  # should show resources as "to be created"
```

## Destroying a Cluster When the Kubernetes Provider Is Stuck

Sometimes the `kubernetes`/`helm` provider can't complete an apply or destroy, e.g.:

```
Error: Plugin error
The plugin returned an unexpected error from
plugin6.(*GRPCProvider).PlanResourceChange: rpc error: code = Unknown desc
= failed to determine resource type ID: cannot get OpenAPI foundry: failed
get OpenAPI spec: context deadline exceeded
```

This happens when the EKS API server is slow/unresponsive, or when a stack was regenerated against a different branch/ref than what's actually deployed. Any unit using `kubectl_manifest` or `helm_release` (SecretStore, StorageClass, ArgoCD, ExternalDNS, etc.) will hang, and `terragrunt run --all destroy` can't proceed past those units.

If `kubectl` still responds even though the provider doesn't, work around Terragrunt entirely instead of fighting it.

### 0. Set up the variables used below

```bash
REGION=eu-west-3
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ENVIRONMENT=dev
BUCKET="tofu-state-${ACCOUNT_ID}-${ENVIRONMENT}"
CLUSTER_NAME="${ENVIRONMENT}-<cluster_name>"
```

### 1. Delete Ingress/Gateway/HTTPRoute objects via kubectl

This lets AWS Load Balancer Controller and ExternalDNS clean up their ALBs, target groups, security groups, and Route53 records gracefully, avoiding orphaned resources outside the cluster:

```bash
kubectl delete httproute -A --all
kubectl delete gateway -A --all
kubectl delete ingress -A --all
```

Confirm the ALBs and DNS records are actually gone before moving on:

```bash
aws elbv2 describe-load-balancers --region "$REGION" \
  --query "LoadBalancers[?contains(LoadBalancerName,'k8s')].LoadBalancerName"

ZONE_ID=<hosted-zone-id>
aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
  --query "ResourceRecordSets[?Type!='NS' && Type!='SOA']"
```

### 2. Delete the remaining namespaces
Delete the namespaces containing external k8s resources:
```bash
kubectl delete ns argocd monitoring tailscale
```

### 3. Destroy the cluster unit

`units/eks/cluster` only uses the `aws` provider (via `terraform-aws-modules/eks/aws`), so it's unaffected by a stuck `kubernetes` provider and can be destroyed on its own once the workarounds above have cleared everything running inside the cluster:

```bash
cd pipelines/dev/eks/stack/.terragrunt-stack/eks/cluster
terragrunt destroy
```

### 4. Run the full stack destroy

Addon units are excluded automatically once the cluster is gone (see `provider_k8s_base.hcl`'s `exclude` block), so the rest of the stack (VPC, Route53 zones, ACM certificate, IAM) destroys cleanly:

```bash
cd pipelines/dev/eks/stack
terragrunt run --all destroy --no-stack-generate
```

### 5. Wipe the addon units' state

Excluded units keep their state file, which now points to resources that no longer exist. Remove it wholesale rather than per-resource (see [Manually Removing a Terragrunt State](#manually-removing-a-terragrunt-state) for the single-module version):

```bash
STACK_PATH=dev/eks/stack/.terragrunt-stack
aws s3 rm "s3://${BUCKET}/${STACK_PATH}/eks/addons/" --recursive
```

### 6. Verify manually in the AWS console

- **VPC**: no orphaned VPC/subnets/security groups
- **NAT Gateways / Elastic IPs**: billed hourly even if idle — the most expensive thing to miss
- **Load Balancers**: no ALB/NLB left over (would respawn if an Ingress/Service survived)
- **EBS volumes**: no orphaned volumes from PVCs (`reclaimPolicy: Retain` or a node that didn't clean up)
- **Secrets Manager**: no secrets left over
- **IAM**: no roles/policies left over from the cluster's addons
- **EC2**: no leftover instances/ENIs (e.g. from Karpenter-provisioned nodes)
- **EKS**: no cluster/node group left in a stuck state

## Can't Connect with Tailscale to Internal Endpoints on MacOS
MacOs doesn't automatically re-push DNS config.

First confirm ExternalDNS has written the record:
```bash
dig <hostname>  # wait until it returns the expected private IP
```

Then force Tailscale to re-apply DNS:
```bash
tailscale set --accept-dns=false && tailscale set --accept-dns=true
```

Or flush the DNS cache:
```bash
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```