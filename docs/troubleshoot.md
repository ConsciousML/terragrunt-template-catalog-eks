# Troubleshooting

## Manually Removing a Terragrunt State

Sometimes you need to fully remove a module's state.

For example, when the state references resources that no longer exist.

This requires deleting the state file in S3 **and** the corresponding digest entry in DynamoDB. Doing only one will cause Tofu to error on the next run.

### Steps

**Delete the state file in S3:**

Go to the S3 bucket and delete the `.tfstate` file for the module, or use the CLI:

```bash
aws s3 rm s3://<bucket>/<path/to/module>/tofu.tfstate
```

**Find the stale DynamoDB entry:**

```bash
aws dynamodb scan \
  --table-name terragrunt_lock_table \
  --filter-expression "contains(LockID, :fragment)" \
  --expression-attribute-values '{":fragment": {"S": "<path/to/module>"}}' \
  --query "Items[*].LockID.S" \
  --output text
```

**Delete the digest entry** (the one ending in `-md5`):

```bash
aws dynamodb delete-item \
  --table-name terragrunt_lock_table \
  --key '{"LockID": {"S": "<bucket>/<path/to/module>/tofu.tfstate-md5"}}'
```

**Verify the state is gone:**

```bash
terragrunt init
terragrunt plan  # should show resources as "to be created"
```

## Manually Removing a Directory of Terragrunt States

Sometimes you need to remove state for an entire subtree at once (e.g. all units under an addon group), not just a single module.

This still requires deleting the state files in S3 **and** the corresponding digest entries in DynamoDB. Leaving stale digest entries behind causes every affected unit to fail `tofu init` with:

```
Error refreshing state: state data in S3 does not have the expected content.
```

### Steps

Set these once, scoped to the exact bucket (environment) and path you're clearing. Other environments share the same DynamoDB table, and a too-broad prefix will match them too:

```bash
export BUCKET="<bucket>"
export PREFIX="<path/to/directory>"  # no leading/trailing slash
```

**Delete the state files in S3:**

```bash
aws s3 rm "s3://${BUCKET}/${PREFIX}/" --recursive --exclude "*" --include "*/tofu.tfstate"
```

**Find the stale DynamoDB entries under that prefix:**

```bash
aws dynamodb scan \
  --table-name terragrunt_lock_table \
  --filter-expression "contains(LockID, :fragment)" \
  --expression-attribute-values "{\":fragment\": {\"S\": \"${BUCKET}/${PREFIX}/\"}}" \
  --query "Items[*].LockID.S" \
  --output text
```

**Delete each digest entry** (the ones ending in `-md5`):

```bash
aws dynamodb scan \
  --table-name terragrunt_lock_table \
  --filter-expression "contains(LockID, :fragment)" \
  --expression-attribute-values "{\":fragment\": {\"S\": \"${BUCKET}/${PREFIX}/\"}}" \
  --query "Items[*].LockID.S" \
  --output text | tr '\t' '\n' | while read -r id; do
    [ -z "$id" ] && continue
    aws dynamodb delete-item \
      --table-name terragrunt_lock_table \
      --key "{\"LockID\": {\"S\": \"$id\"}}"
    echo "deleted: $id"
  done
```

**Verify the state is gone:**

```bash
aws s3 ls "s3://${BUCKET}/${PREFIX}/" --recursive | grep tofu.tfstate | grep -v '\-md5\|\.tflock'
# should print nothing

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

This happens when the EKS API server is slow/unresponsive, or when a stack was regenerated against a different branch/ref than what's actually deployed, causing `terragrunt run --all destroy` to get stuck.

If we need to destroy by hand, work around Terragrunt entirely instead of fighting it:

### Set Up the Variables Used Below

```bash
REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ENVIRONMENT=dev
BUCKET="tofu-state-${ACCOUNT_ID}-${ENVIRONMENT}"
CLUSTER_NAME="${ENVIRONMENT}-<cluster_name>"
```

### Delete Ingress/Gateway/HTTPRoute Objects via kubectl

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

### Delete the Remaining Namespaces
Delete the namespaces containing external k8s resources:
```bash
kubectl delete ns argocd monitoring tailscale
```

### Destroy the Cluster Unit

`units/eks/cluster` only uses the `aws` provider (via `terraform-aws-modules/eks/aws`), so it's unaffected by a stuck `kubernetes` provider and can be destroyed on its own once the workarounds above have cleared everything running inside the cluster:

```bash
cd pipelines/dev/eks/stack/.terragrunt-stack/eks/cluster
terragrunt destroy
```

### Run the Full Stack Destroy

Addon units are excluded automatically once the cluster is gone (see `provider_k8s_base.hcl`'s `exclude` block), so the rest of the stack (VPC, Route53 zones, ACM certificate, IAM) destroys cleanly:

```bash
cd pipelines/dev/eks/stack
terragrunt run --all destroy --no-stack-generate
```

### Wipe the Addon Units' State

Excluded units keep their state file, which now points to resources that no longer exist. Remove it wholesale rather than per-resource by following [Manually Removing a Directory of Terragrunt States](#manually-removing-a-directory-of-terragrunt-states) with:

```bash
export BUCKET="tofu-state-${ACCOUNT_ID}-${ENVIRONMENT}"
export PREFIX="dev/eks/stack/.terragrunt-stack/eks/addons"
```

### Verify Manually in the AWS Console

- **VPC**: no orphaned VPC/subnets/security groups
- **NAT Gateways / Elastic IPs**: billed hourly even if idle. The most expensive thing to miss
- **Load Balancers**: no ALB/NLB left over (would respawn if an Ingress/Service survived)
- **EBS volumes**: no orphaned volumes from PVCs (`reclaimPolicy: Retain` or a node that didn't clean up)
- **Secrets Manager**: no secrets left over
- **IAM**: no roles/policies left over from the cluster's addons
- **EC2**: no leftover instances/ENIs (e.g. from Karpenter-provisioned nodes)
- **EKS**: no cluster/node group left in a stuck state

## Destroying App of Apps Fails

`terragrunt destroy` on `argocd_app_of_apps` (or a full stack destroy that reaches it) can fail with:

```
Error: Error uninstalling release

Unable to uninstall Helm release app-of-apps: uninstallation completed with
2 error(s): Get
"https://<cluster-endpoint>/apis/argoproj.io/v1alpha1/namespaces/argocd/applications/app-of-apps":
read tcp <local-ip>:<port>-><vpc-ip>:443: read: operation timed out;
uninstall: Failed to purge the release: get: failed to get
"sh.helm.release.v1.app-of-apps.v1": Get
"https://<cluster-endpoint>/api/v1/namespaces/argocd/secrets/sh.helm.release.v1.app-of-apps.v1":
dial tcp <vpc-ip>:443: i/o timeout
```

`helm-tailscale-connector` advertises the whole VPC CIDR as a subnet route (`advertiseRoutes` in `units/eks/addons/argocd/app_of_apps/terragrunt.hcl`), so with `tailscale up` active, API server traffic routes through it even against the public endpoint. The connector is part of the same release being uninstalled, so its pod gets deleted mid-uninstall, the route disappears, and whichever API call is in flight times out. Disconnect first:

```bash
tailscale down
```

The cluster itself is usually fine after this error. Confirm with `kubectl get ns` and retry the destroy.

## Can't Connect with Tailscale to Internal Endpoints on macOS
macOS doesn't automatically re-push DNS config.

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

As a last resort, delete cookies from your browser.

## Accessing ArgoCD When It Doesn't Resolve on the Private Hosted Zone

If `argocd-server`'s hostname isn't resolving yet (ExternalDNS hasn't written the record, Tailscale isn't set up, or you just need quick access), port-forward straight to the service instead:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Then open `http://localhost:8080`. `server.insecure` is set to `true` on the `argocd` unit's `helm_values` in the [dev stack file](../pipelines/dev/eks/stack/terragrunt.stack.hcl), so plain HTTP works and there's no TLS certificate mismatch.

## Getting the ArgoCD Admin Password When the ESO Sync Isn't Working

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

## Force-Deleting a Stuck ArgoCD Application

If an `Application` hangs on delete (`deletionTimestamp` set but never removed), its `resources-finalizer.argocd.argoproj.io` finalizer is stuck. Clear it directly:

```bash
kubectl patch application <name> -n argocd --type=merge -p '{"metadata":{"finalizers":null}}'
```

This skips ArgoCD's own cascade-prune, so check for orphaned resources it was still managing afterward.
```