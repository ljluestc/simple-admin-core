#!/bin/bash
# Quick fix for the macOS /home/data directory issue

set -e

echo "🔧 Fixing macOS /home/data directory issue..."

# Create log directories
mkdir -p logs/core/api logs/core/rpc

# Fix API config
sed -i '' 's|Path: /home/data/logs/core/api|Path: ./logs/core/api|' api/etc/core.yaml

# Fix RPC config
sed -i '' 's|Path: /home/data/logs/core/rpc|Path: ./logs/core/rpc|' rpc/etc/core.yaml

echo "✅ Fixed configuration files"
echo "✅ Created log directories"
echo ""
echo "🚀 Now try running your servers:"
echo "  cd api && go run ."
echo "  # In another terminal:"
echo "  cd rpc && go run ."
