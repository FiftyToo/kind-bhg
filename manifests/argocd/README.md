# ArgoCD Applications

This directory contains ArgoCD Application manifests for GitOps deployments.

## Example Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/FiftyToo/kagent-bhg
    targetRevision: main
    path: agents
  destination:
    server: https://kubernetes.default.svc
    namespace: kagent
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Connecting kagent-bhg Repository

Create an Application that watches the kagent-bhg repository:

```bash
kubectl apply -f kagent-bhg-app.yaml
```

This enables automatic deployment of KAgent agents and MCP servers when changes are pushed to the kagent-bhg repository.
