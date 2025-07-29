#!/bin/bash

# Install Git hooks for Kotlinish development

echo "🔧 Installing Git hooks for Kotlinish..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy commit-msg hook
cp .githooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg

echo "✅ Git hooks installed successfully!"
echo ""
echo "📋 Hooks installed:"
echo "  • commit-msg: Validates commit message format"
echo ""
echo "📖 See .github/COMMIT_CONVENTION.md for commit guidelines"
echo ""
echo "🚀 You're ready to contribute with properly formatted commits!"