#!/bin/bash
set -e

echo "Installing KAgent..."

# Check if kagent CLI is installed
if ! command -v kagent &> /dev/null; then
    echo "KAgent CLI not found. Installing..."
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install kagent
        else
            curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash
        fi
    else
        # Linux
        curl https://raw.githubusercontent.com/kagent-dev/kagent/refs/heads/main/scripts/get-kagent | bash
    fi
fi

# Check for OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "WARNING: OPENAI_API_KEY environment variable is not set"
    echo "KAgent will be installed but agents won't work without an API key"
    echo "Set it with: export OPENAI_API_KEY='your-api-key'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install KAgent with demo profile (includes sample agents)
echo "Installing KAgent with demo profile..."
kagent install --profile demo

echo "KAgent installed successfully!"
echo ""
echo "To access KAgent dashboard:"
echo "  1. Run: kagent dashboard"
echo "  2. Or port forward manually:"
echo "     kubectl port-forward svc/kagent-ui -n kagent 8082:8080"
echo "  3. Access at http://localhost:8082"
echo ""
echo "To list agents:"
echo "  kagent get agent"
echo ""
