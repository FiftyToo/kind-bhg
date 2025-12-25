# Sealed Secrets Resources

This directory contains Sealed Secrets configurations and examples.

## What is Sealed Secrets?

Sealed Secrets allows you to encrypt Kubernetes secrets so they can be safely stored in Git repositories. The controller running in the cluster can decrypt them, but the encrypted files are safe to commit.

## Installation

```bash
# Install Sealed Secrets controller
./scripts/install-sealed-secrets.sh

# Install kubeseal CLI
# macOS
brew install kubeseal

# Linux
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz
tar xfz kubeseal-0.24.0-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

## Creating Sealed Secrets

### Method 1: From Literals

```bash
# Create a regular secret (don't apply it)
kubectl create secret generic mysecret \
  --dry-run=client \
  --from-literal=username=admin \
  --from-literal=password=secretpass \
  -n default \
  -o yaml > mysecret.yaml

# Seal it
kubeseal --format yaml < mysecret.yaml > mysealedsecret.yaml

# Apply the sealed secret (safe to commit!)
kubectl apply -f mysealedsecret.yaml

# Delete the plaintext secret file
rm mysecret.yaml
```

### Method 2: From Files

```bash
# Create secret from file
kubectl create secret generic tls-secret \
  --dry-run=client \
  --from-file=tls.crt=./cert.pem \
  --from-file=tls.key=./key.pem \
  -n default \
  -o yaml | kubeseal --format yaml > sealed-tls-secret.yaml

# Apply it
kubectl apply -f sealed-tls-secret.yaml
```

## Example: Sealing Cloudflare Secrets

```bash
# Create Cloudflare API credentials sealed secret
kubectl create secret generic cloudflare-api \
  --dry-run=client \
  --from-literal=api-token="${CLOUDFLARE_API_TOKEN}" \
  --from-literal=cloudflare-account-id="${CLOUDFLARE_ACCOUNT_ID}" \
  --from-literal=cloudflare-tunnel-name="${CLOUDFLARE_TUNNEL_NAME}" \
  -n cloudflare-tunnel-ingress-controller \
  -o yaml | kubeseal --format yaml > sealed-cloudflare-api.yaml

# Commit the sealed secret to Git
git add sealed-cloudflare-api.yaml
git commit -m "feat: add sealed Cloudflare credentials"
git push
```

## Example: Sealing OpenAI API Key

```bash
# Create OpenAI API key sealed secret for KAgent
kubectl create secret generic openai-api-key \
  --dry-run=client \
  --from-literal=api-key="${OPENAI_API_KEY}" \
  -n kagent \
  -o yaml | kubeseal --format yaml > sealed-openai-api-key.yaml

# Apply it
kubectl apply -f sealed-openai-api-key.yaml
```

## Security Best Practices

1. **Never commit plaintext secrets** - Always delete `mysecret.yaml` after sealing
2. **Backup the sealing key** - Store it securely outside the cluster
3. **Use namespace scoping** - Sealed secrets are namespace-specific by default
4. **Rotate regularly** - Update and reseal secrets periodically
5. **Limit access** - Use RBAC to control who can read/write sealed secrets

## References

- [Sealed Secrets GitHub](https://github.com/bitnami-labs/sealed-secrets)
- [Sealed Secrets Documentation](https://github.com/bitnami-labs/sealed-secrets#overview)
