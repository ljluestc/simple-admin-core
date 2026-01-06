#!/bin/bash
# Script to create PR for inventory management system implementation

set -e

echo "🚀 Creating PR for Inventory Management System Implementation..."
echo

# Check if we're in the right directory
if [ ! -f "core.json" ] || [ ! -d "rpc" ]; then
    echo "❌ Error: Please run this script from the simple-admin-core project root directory"
    exit 1
fi

# Check git status
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: You have uncommitted changes. Please commit or stash them first."
    echo "Current status:"
    git status --short
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📋 PR Details:"
echo "   Title: Add comprehensive inventory management system"
echo "   Type: Feature + API Change"
echo "   Files: 80+ files added, 20+ files modified"
echo "   New APIs: 16 REST endpoints + 16 gRPC services"
echo
echo "🔗 PR Description created at: PR_DESCRIPTION.md"
echo
echo "📝 PR Content Summary:"
echo "   ✅ Warehouse Management (CRUD)"
echo "   ✅ Product Management (CRUD)"
echo "   ✅ Inventory Management (CRUD)"
echo "   ✅ Stock Movement Tracking (CRUD)"
echo "   ✅ Ent ORM Integration"
echo "   ✅ gRPC Services"
echo "   ✅ REST API Endpoints"
echo "   ✅ Protobuf Definitions"
echo
echo "🚀 Create PR using one of these methods:"
echo
echo "1. GitHub Web Interface:"
echo "   Visit: https://github.com/ljluestc/simple-admin-core/pull/new/feature/inventory-management-system"
echo "   Title: 'Add comprehensive inventory management system'"
echo "   Use content from: PR_DESCRIPTION.md"
echo
echo "2. GitHub CLI (if installed):"
echo "   gh pr create \\"
echo "     --title \"Add comprehensive inventory management system\" \\"
echo "     --body \"$(cat PR_DESCRIPTION.md)\" \\"
echo "     --base main \\"
echo "     --head feature/inventory-management-system"
echo
echo "3. Manual PR creation:"
echo "   Copy the content from PR_DESCRIPTION.md"
echo
echo "📊 Files Added/Modified:"
echo "$(git diff --cached --stat)"
echo
echo "✨ Ready for code review!"
