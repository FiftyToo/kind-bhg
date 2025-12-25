# KAgent Resources

This directory contains base KAgent resources and configurations.

## Agent Configuration

Agents should be defined in the kagent-bhg repository for version control.
This directory can contain cluster-wide configurations:

- ModelConfig resources
- RemoteMCPServer resources
- Namespace configurations

## Example ModelConfig

```yaml
apiVersion: kagent.dev/v1alpha2
kind: ModelConfig
metadata:
  name: openai-gpt-4
  namespace: kagent
spec:
  provider: openai
  model: gpt-4-turbo
  apiKeySecret:
    name: openai-api-key
    key: api-key
```
