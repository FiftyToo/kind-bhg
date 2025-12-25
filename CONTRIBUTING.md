# Contributing to kind-bhg

Thank you for your interest in contributing!

## How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-new-feature`
3. **Make your changes**
4. **Test your changes**: Ensure scripts work and manifests are valid
5. **Commit your changes**: `git commit -am 'Add some feature'`
6. **Push to the branch**: `git push origin feature/my-new-feature`
7. **Submit a Pull Request**

## Guidelines

### Adding New Components

1. Create manifest directory under `manifests/component-name/`
2. Add installation script under `scripts/install-component-name.sh`
3. Update `scripts/install-all.sh` to include new component
4. Update README.md with component documentation
5. Add example configurations and README in manifest directory

### Scripts

- All scripts should start with `#!/bin/bash` and `set -e`
- Add error checking for required environment variables
- Include helpful echo messages
- Make scripts idempotent when possible

### Manifests

- Use YAML format (not JSON)
- Include comments explaining non-obvious configurations
- Add namespace specifications
- Use meaningful names

### Documentation

- Update README.md for any user-facing changes
- Add inline comments for complex configurations
- Include troubleshooting tips

## Testing

Before submitting:

```bash
# Test cluster creation
./scripts/create-cluster.sh

# Test individual installations
./scripts/install-cert-manager.sh
# ... etc

# Test full installation
./scripts/install-all.sh

# Validate manifests
kubectl apply --dry-run=client -R -f manifests/
```

## Questions?

Feel free to open an issue for questions or discussion.
