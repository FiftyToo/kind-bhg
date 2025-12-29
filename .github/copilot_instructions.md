


# Mandatory Rules for kubernetes secrets

All secrets manifests must be saved in a file that matches the pattern `*-secrets.yaml`. The secrets should have the following instructions:

```
# {{ name }} Credentials
# This should be sealed using sealed-secrets before committing
# 
# To create a sealed secret:
# 1. Fill in the credentials below (don't commit this file!)
# 2. Seal it: kubeseal -f {{ name }}-secrets.yaml -w {{ name }}-secrets-sealed.yaml
# 3. Apply the sealed secret: kubectl apply -f {{ name }}-secrets-sealed.yaml
# 4. Do NOT check this file into version control! It should be ignored by .gitignore
```