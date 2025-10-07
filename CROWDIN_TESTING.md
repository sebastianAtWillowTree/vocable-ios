# Testing Crowdin Workflow Locally

This guide explains how to test the Crowdin translation workflow (`.github/workflows/crowdin_pull.yml`) locally before running it in GitHub Actions.

## Overview

The workflow performs these steps:
1. Downloads translation bundles from Crowdin as XLIFF files
2. Processes and imports them into the Xcode project using fastlane
3. Stages the changes and creates a pull request

## Prerequisites

### Required Tools

Install the following tools on your macOS system:

```bash
# Crowdin CLI
brew install crowdin

# Ruby 3.3.1 (if not already installed)
# Use rbenv or rvm to manage Ruby versions

# Bundler
gem install bundler

# SwiftLint
brew install swiftlint
```

### Environment Variables

Set up the required environment variables:

```bash
export CROWDIN_PROJECT_ID=834156
export CROWDIN_PERSONAL_TOKEN=84079ca8898375f652f3723b83c4da9cbdefdcd551841902bafa2341fc518efb686878a66ebb3f60
```

**Note**: For production use, these credentials should be stored in GitHub Secrets, not hardcoded.

### Project Dependencies

Install Ruby dependencies:

```bash
bundle install
```

## Testing Methods

### Method 1: Automated Test Script (Recommended)

**For xcstrings bundles (recommended):**

```bash
# Set the Crowdin token
export CROWDIN_PERSONAL_TOKEN=84079ca8898375f652f3723b83c4da9cbdefdcd551841902bafa2341fc518efb686878a66ebb3f60

# Run the xcstrings test script with your bundle ID
./test_crowdin_xcstrings_workflow.sh YOUR_BUNDLE_ID

# Or use default bundle 13
./test_crowdin_xcstrings_workflow.sh
```

**For XLIFF bundles (legacy):**

```bash
# Set the Crowdin token
export CROWDIN_PERSONAL_TOKEN=84079ca8898375f652f3723b83c4da9cbdefdcd551841902bafa2341fc518efb686878a66ebb3f60

# Run the XLIFF test script
./test_crowdin_workflow.sh
```

The xcstrings script will:
- ✓ Verify all required tools are installed
- ✓ Clean previous test data
- ✓ Download translations from Crowdin (bundle ID as parameter)
- ✓ Auto-detect file format (XLIFF or xcstrings)
- ✓ Use appropriate import lane (xliff_import or xcstrings_import)
- ✓ Show detailed analysis of downloaded files
- ✓ Display git changes and diff summary

### Method 2: Manual Step-by-Step Testing

Test each step individually for debugging:

#### Step 1: Download Translations

```bash
crowdin bundle download 13 --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN
```

Verify:
- XLIFF files are downloaded to `CrowdinExport/` directory
- Files have the expected structure

#### Step 2: Import XLIFFs

```bash
bundle exec fastlane xliff_import
```

This fastlane lane:
- Processes XLIFF files (fixes paths and IDs)
- Imports them into the Xcode project using `xcodebuild -importLocalizations`

Verify:
- `.xcstrings` files in `Vocable/Supporting Files/` are updated
- No errors during import

#### Step 3: Review Changes

```bash
# Check what files changed
git status

# See detailed changes
git diff Vocable/

# Stage changes (as the workflow does)
git add Vocable/

# Review staged changes
git diff --cached
```

#### Step 4: Create Test PR (Optional)

```bash
# Create a test branch
git checkout -b test/crowdin-local

# Commit changes
git commit -m "Test: Update Localizations"

# Push and create PR manually via GitHub UI
git push origin test/crowdin-local
```

### Method 3: Using act (GitHub Actions Locally)

If you have `act` installed (see `.actrc` in the project):

```bash
# Install act
brew install act

# Create a secrets file
echo "GITHUB_TOKEN=your_github_token_here" > .secrets

# Run the workflow
act workflow_dispatch -W .github/workflows/crowdin_pull.yml

# Or simulate push to develop
act push -W .github/workflows/crowdin_pull.yml
```

**Note**: The PR creation step will fail locally since it requires actual GitHub API access.

## Validation Checklist

After running the test, verify:

- [ ] XLIFF files downloaded to `CrowdinExport/` directory
- [ ] XLIFF files have correct format (paths are fixed)
- [ ] `.xcstrings` files in `Vocable/Supporting Files/` are updated
- [ ] Any `.strings` files are updated if present
- [ ] No errors in the import process
- [ ] Git shows changes only in `Vocable/` directory
- [ ] Changes are limited to localization files (`.xcstrings`, `.strings`)

## Cleanup

After testing, clean up your workspace:

```bash
# Discard changes
git checkout -- Vocable/

# Remove downloaded files
rm -rf CrowdinExport/

# Delete test branch if created
git branch -D test/crowdin-local
```

## Troubleshooting

### Crowdin CLI Not Found

```bash
brew install crowdin
```

### Bundle Install Fails

```bash
# Update bundler
gem install bundler

# Try installing again
bundle install
```

### XLIFF Import Fails

Check that:
- Xcode project exists at `Vocable.xcodeproj`
- XLIFF files are in the correct format
- You have the correct Ruby version (3.3.1)

### SwiftLint Plugin Validation Error

**Error**: `xcodebuild: error: Unable to build project for localization string extraction`

**Cause**: The SwiftLint build plugin validation fails during the `xcodebuild -importLocalizations` process.

**Solution**: The `xliff_import` fastlane lane now includes `-skipPackagePluginValidation -skipMacroValidation` flags to bypass this issue. This is the same approach used in other build lanes in the project.

If you still encounter this error:
1. Ensure you're using the latest version of the Fastfile
2. Verify SwiftLint is installed: `brew install swiftlint`
3. Check that the xcodebuild command includes the skip flags

### SwiftLint Errors

```bash
# Install or update SwiftLint
brew install swiftlint
# or
brew upgrade swiftlint
```

## Understanding the Workflow

### Crowdin Configuration

The workflow uses settings from `crowdin.yml`:
- **Project ID**: 834156
- **Bundle ID**: 13
- **Source files**: `Vocable/**/*.xcstrings`
- **Translation output**: `CrowdinExport/%osx_locale%/%file_name%.xliff`

### Fastlane Lane: xliff_import

Located in `fastlane/Fastfile`, this lane:

1. Finds all XLIFF files in `CrowdinExport/`
2. Fixes file paths (removes Crowdin-specific prefixes)
3. Normalizes translation unit IDs
4. Imports each XLIFF using `xcodebuild -importLocalizations`

### Files Modified

The workflow typically modifies:
- `Vocable/Supporting Files/Localizable.xcstrings`
- `Vocable/Supporting Files/InfoPlist.xcstrings`
- `Vocable/Supporting Files/Presets.xcstrings`
- Any other `.xcstrings` or `.strings` files in the `Vocable/` directory

## Important Notes

1. **Credentials**: The workflow currently has hardcoded Crowdin credentials. For production, move these to GitHub Secrets.

2. **PR Creation**: The `peter-evans/create-pull-request` action won't work locally. Test this in the actual GitHub Actions environment.

3. **Runner Differences**: The workflow uses `macos-latest` which may have different tool versions than your local machine.

4. **Bundle ID**: The workflow downloads bundle 13 specifically. Verify this is correct for your use case.

5. **Auto-formatting**: After import, Xcode may auto-format the `.xcstrings` files, which is expected behavior.

## Next Steps

After successful local testing:

1. Commit the test script and documentation
2. Test the full workflow in GitHub Actions
3. Verify the PR creation works as expected
4. Consider moving credentials to GitHub Secrets
