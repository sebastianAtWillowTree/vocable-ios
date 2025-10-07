#!/bin/bash
set -e

echo "=== Testing Crowdin Workflow Locally ==="
echo ""

# Check for required environment variables
if [ -z "$CROWDIN_PERSONAL_TOKEN" ]; then
    echo "Error: CROWDIN_PERSONAL_TOKEN environment variable is not set"
    echo "Please run: export CROWDIN_PERSONAL_TOKEN=your_token_here"
    exit 1
fi

# Check for required tools
echo "Checking required tools..."
command -v crowdin >/dev/null 2>&1 || { echo "Error: crowdin CLI is not installed. Run: brew install crowdin"; exit 1; }
command -v bundle >/dev/null 2>&1 || { echo "Error: bundler is not installed. Run: gem install bundler"; exit 1; }
command -v swiftlint >/dev/null 2>&1 || { echo "Error: swiftlint is not installed. Run: brew install swiftlint"; exit 1; }
echo "✓ All required tools are installed"
echo ""

# Clean previous test data
echo "Cleaning previous test data..."
rm -rf CrowdinExport/
echo "✓ Cleaned CrowdinExport directory"
echo ""

# Download translations
echo "Downloading translations from Crowdin..."
echo "Project ID: 834156"
echo "Bundle ID: 13"
crowdin bundle download 13 --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

if [ $? -eq 0 ]; then
    echo "✓ Successfully downloaded translations"
else
    echo "✗ Failed to download translations"
    exit 1
fi
echo ""

# List downloaded files
echo "=== Downloaded Files ==="
if [ -d "CrowdinExport" ]; then
    ls -R CrowdinExport/
else
    echo "Warning: CrowdinExport directory not found"
fi
echo ""

# Install bundle dependencies if needed
if [ ! -d "vendor/bundle" ]; then
    echo "Installing bundle dependencies..."
    bundle install
    echo ""
fi

# Import XLIFFs
echo "Importing XLIFFs to project..."
echo "Note: Using -skipPackagePluginValidation -skipMacroValidation flags to avoid SwiftLint plugin issues"
bundle exec fastlane xliff_import

if [ $? -eq 0 ]; then
    echo "✓ Successfully imported XLIFFs"
else
    echo "✗ Failed to import XLIFFs"
    exit 1
fi
echo ""

# Show changes
echo "=== Git Status ==="
git status
echo ""

echo "=== Changed xcstrings/strings Files ==="
find Vocable -name "*.xcstrings" -o -name "*.strings" | head -20
echo ""

echo "=== Git Diff Summary ==="
git diff --stat Vocable/
echo ""

echo "=== Test Complete ==="
echo ""
echo "Next steps:"
echo "1. Review the changes with: git diff Vocable/"
echo "2. To discard changes: git checkout -- Vocable/"
echo "3. To clean up: rm -rf CrowdinExport/"
echo "4. To create a test PR: git checkout -b test/crowdin-local && git add Vocable/ && git commit -m 'Test: Update Localizations'"
