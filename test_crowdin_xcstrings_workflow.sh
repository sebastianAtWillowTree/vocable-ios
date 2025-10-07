#!/bin/bash
set -e

echo "=== Testing Crowdin xcstrings Workflow Locally ==="
echo ""

# Check for required environment variables
if [ -z "$CROWDIN_PERSONAL_TOKEN" ]; then
    echo "Error: CROWDIN_PERSONAL_TOKEN environment variable is not set"
    echo "Please run: export CROWDIN_PERSONAL_TOKEN=your_token_here"
    exit 1
fi

# Get bundle ID from command line or use default
BUNDLE_ID=${1:-13}
echo "Using Bundle ID: $BUNDLE_ID"
echo ""

# Check for required tools
echo "Checking required tools..."
command -v crowdin >/dev/null 2>&1 || { echo "Error: crowdin CLI is not installed. Run: brew install crowdin"; exit 1; }
command -v bundle >/dev/null 2>&1 || { echo "Error: bundler is not installed. Run: gem install bundler"; exit 1; }
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
echo "Bundle ID: $BUNDLE_ID"
crowdin bundle download $BUNDLE_ID --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

if [ $? -eq 0 ]; then
    echo "✓ Successfully downloaded translations"
else
    echo "✗ Failed to download translations"
    exit 1
fi
echo ""

# Analyze downloaded files
echo "=== Analyzing Downloaded Files ==="

# Handle different export directory names (Crowdin bundle config issue)
EXPORT_DIR=""
if [ -d "CrowdinExport" ]; then
    EXPORT_DIR="CrowdinExport"
    echo "✓ CrowdinExport directory exists"
elif [ -d "%two_letters_code%" ]; then
    echo "⚠️  Found '%two_letters_code%' directory (bundle export path issue)"
    echo "   Moving to CrowdinExport/ for compatibility..."
    mv "%two_letters_code%" CrowdinExport
    EXPORT_DIR="CrowdinExport"
    echo "✓ Moved to CrowdinExport directory"
elif [ -d "%locale%" ]; then
    echo "⚠️  Found '%locale%' directory (bundle export path issue)"
    echo "   Moving to CrowdinExport/ for compatibility..."
    mv "%locale%" CrowdinExport
    EXPORT_DIR="CrowdinExport"
    echo "✓ Moved to CrowdinExport directory"
else
    # Check for any other directories that might have been created
    for dir in */; do
        if [ "$dir" != "Vocable/" ] && [ "$dir" != "Tests/" ] && [ "$dir" != "fastlane/" ]; then
            echo "⚠️  Found unexpected directory: $dir"
            echo "   This might be from Crowdin bundle export"
            echo "   Moving to CrowdinExport/ for compatibility..."
            mv "$dir" CrowdinExport
            EXPORT_DIR="CrowdinExport"
            echo "✓ Moved to CrowdinExport directory"
            break
        fi
    done
fi

if [ -n "$EXPORT_DIR" ]; then
    echo ""
    
    echo "Directory structure:"
    ls -R CrowdinExport/
    echo ""
    
    # Count file types
    xliff_count=$(find CrowdinExport -name "*.xliff" 2>/dev/null | wc -l | tr -d ' ')
    xcstrings_count=$(find CrowdinExport -name "*.xcstrings" 2>/dev/null | wc -l | tr -d ' ')
    
    echo "File counts:"
    echo "  XLIFF files: $xliff_count"
    echo "  xcstrings files: $xcstrings_count"
    echo ""
    
    # Determine which lane to use
    if [ "$xcstrings_count" -gt 0 ]; then
        LANE="xcstrings_import"
        echo "✓ Detected xcstrings files - will use xcstrings_import lane"
    elif [ "$xliff_count" -gt 0 ]; then
        LANE="xliff_import"
        echo "✓ Detected XLIFF files - will use xliff_import lane"
    else
        echo "✗ No XLIFF or xcstrings files found!"
        exit 1
    fi
    echo ""
    
    # Show sample content
    echo "Sample file content (first 30 lines):"
    first_file=$(find CrowdinExport \( -name "*.xliff" -o -name "*.xcstrings" \) -print -quit)
    if [ -n "$first_file" ]; then
        echo "File: $first_file"
        echo "---"
        head -30 "$first_file"
        echo "---"
    fi
else
    echo "✗ CrowdinExport directory does NOT exist"
    echo "Bundle download may have failed or returned no files"
    exit 1
fi
echo ""

# Install bundle dependencies if needed
if [ ! -d "vendor/bundle" ]; then
    echo "Installing bundle dependencies..."
    bundle install
    echo ""
fi

# Import files
echo "Importing translations using lane: $LANE"
bundle exec fastlane $LANE

if [ $? -eq 0 ]; then
    echo "✓ Successfully imported translations"
else
    echo "✗ Failed to import translations"
    exit 1
fi
echo ""

# Show changes
echo "=== Git Status ==="
git status
echo ""

echo "=== Changed xcstrings/strings Files ==="
git diff --name-only | grep -E '\.(xcstrings|strings)$' || echo "No xcstrings/strings files changed"
echo ""

echo "=== Git Diff Summary ==="
git diff --stat Vocable/
echo ""

# Show detailed diff for xcstrings files if they changed
if git diff --name-only | grep -q '\.xcstrings$'; then
    echo "=== Detailed Changes in xcstrings Files ==="
    for file in $(git diff --name-only | grep '\.xcstrings$'); do
        echo ""
        echo "File: $file"
        echo "Lines changed: $(git diff --numstat "$file" | awk '{print "+"$1" -"$2}')"
    done
    echo ""
fi

echo "=== Test Complete ==="
echo ""
echo "Next steps:"
echo "1. Review the changes with: git diff Vocable/"
echo "2. To see specific file: git diff Vocable/Supporting\ Files/Localizable.xcstrings"
echo "3. To discard changes: git checkout -- Vocable/"
echo "4. To clean up: rm -rf CrowdinExport/"
echo "5. To create a test PR: git checkout -b test/crowdin-local && git add Vocable/ && git commit -m 'Test: Update Localizations'"
echo ""
echo "Bundle used: $BUNDLE_ID ($LANE)"
