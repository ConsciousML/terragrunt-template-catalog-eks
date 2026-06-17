# ArgoCD App of Apps

Creates an ArgoCD [`Application`](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) resource that acts as the root of an app-of-apps pattern. ArgoCD syncs this Application, which in turn discovers and deploys all child Applications from the configured repository path.
