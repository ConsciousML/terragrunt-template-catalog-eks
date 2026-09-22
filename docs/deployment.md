{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Deployment

Now that you've reviewed the [prerequisites](/docs/quickstart/prerequisites/), and performed the [installation](/docs/quickstart/installation/), [configuration](/docs/quickstart/configuration/), and [bootstrap](/docs/quickstart/bootstrap), you're ready to deploy the EKS stack in the [`dev` environment](/docs/iac/#dev).

## Create the spot service-linked role

EKS Forge uses [spot EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) for non-critical workloads to reduce cloud costs.
This creates the EC2 Spot [service-linked role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create-service-linked-role.html) required to provision spot instances:
```bash
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

## Run the Terragrunt stack
In your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), run the following [Terragrunt commands](/docs/iac) from the root to deploy the `dev` environment:

```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

The deployment of this [Terragrunt stack](/docs/iac/#stacks) should take around 20 mins.

When it's done, connect `kubectl` to your `dev` EKS cluster by creating a [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) (replace `<region-code>` by the region you used when you [configured the catalog](/docs/quickstart/configuration/#catalog-configuration)):
```bash
aws eks update-kubeconfig --region <region-code> --name dev-cluster
```

Next, verify `kubectl` is connected:
```
kubectl get pods -n kube-system
```

You should see the pods in your cluster:
```text
NAME                           READY   STATUS    RESTARTS   AGE
aws-node-59ld8                 2/2     Running   0          41m
coredns-845b86cddf-pg8hk       1/1     Running   0          40m
eks-pod-identity-agent-9pq6k   1/1     Running   0          41m
...
```

## Deploy applications with ArgoCD

This stack spins up [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) to deploy [Kubernetes](https://kubernetes.io/) resources with [GitOps](https://about.gitlab.com/topics/gitops/). Once you've run the Terragrunt stack, ArgoCD will take some time deploying these resources. You can monitor the progress by running:
```bash
kubectl get app -n argocd
```

You should see an output similar to:
```text
NAME                          SYNC STATUS   HEALTH STATUS
aws-lbc                       Synced        Healthy
external-secrets-operator     Synced        Healthy
podinfo                       Synced        Healthy
...
```

When every application shows `Synced` and `Healthy`, the deployment succeeded.

## Log in to ArgoCD

For security reasons, internal tools (ArgoCD, Prometheus, etc.) are not exposed to the internet. ArgoCD's API and UI are only reachable using Tailscale. Run the [Tailscale Client](https://tailscale.com/download) and click on `Log In...`. Then click on the button in the top-right to connect or run `tailscale up` in your terminal.

The ArgoCD host is `argocd.private.dev.<base_domain>` (replace `<base_domain>` with the [value from `pipelines/dns.hcl`](/docs/quickstart/bootstrap/setup_dns/), e.g. `argocd.private.dev.axelmendoza.com`).
There are two ways to interact with your ArgoCD instance:
- Open `https://argocd.private.dev.<base_domain>` in your browser and log in with username `admin`. Retrieve the password with:
```bash
aws secretsmanager get-secret-value \
  --secret-id dev-argocd-password \
  --query SecretString \
  --output text | jq -r .plaintext
```
- Authenticate using the ArgoCD CLI by running this command:
```bash
argocd login argocd.private.dev.<base_domain> \
  --username admin \
  --password $(aws secretsmanager get-secret-value \
    --secret-id dev-argocd-password \
    --query SecretString \
    --output text | jq -r .plaintext) \
    --grpc-web
```

## Access the Podinfo app

This stack exposes `podinfo` to the public internet. Open `https://podinfo.public.dev.<base_domain>` in your browser to check that it deployed succesfully. 
`podinfo` is a sample app meant to be swapped for a real one in your fork.

## Destroy the infrastructure

Destroying the infrastructure removes the [Tailscale Connector](/docs/security/tailscale/#4-connector-and-split-dns): the component responsible for routing the Kubernetes API server traffic into the private endpoint. Once it's gone, you lose access to the cluster API.

Before destroying the stack, disconnect from Tailscale by running `tailscale down` or click on the top-right button in the Tailscale Client.

Finally, destroy the infrastructure by running the following command from the root of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):

```bash
source .env
cd pipelines/dev/eks/stack
terragrunt run --all destroy --non-interactive --no-stack-generate
```

## What's next
Continue with the [Deployment tutorial](/docs/deployment/) to deploy the `staging` and `prod` environments from the live repository.

Or, when you need them:
- interact with internal tools using the [monitoring guide](/docs/monitoring/)
- add an application to your cluster with the [applications guide](/docs/applications/)
- add infrastructure components with the [IaC development guide](/docs/iac/development/)