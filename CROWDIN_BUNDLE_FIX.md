# Fixing Crowdin Bundle Export Path Issue

## Problem

When downloading bundle 15, Crowdin extracts files to `%two_letters_code%` instead of `CrowdinExport/`:

```
✔️  #15 'xcstrings1' has been successfully downloaded
✔️  Extracting archive     
✔️  %two_letters_code%
```

This happens because the bundle's export path pattern is not configured correctly.

## Root Cause

The bundle export path is set to use a placeholder (`%two_letters_code%`) that isn't being resolved. This is a bundle configuration issue in Crowdin.

## Solution

### Option 1: Fix Bundle Configuration in Crowdin (Recommended)

1. Go to your Crowdin project: https://crowdin.com/project/vocable-ios-clone
2. Navigate to **Settings** → **Bundles**
3. Find bundle #15 "xcstrings1"
4. Click **Edit**
5. Look for the **Export pattern** or **File structure** setting
6. Change it to: `CrowdinExport/%locale%/%file_name%`
   - Or simply: `%file_name%` (files will be in root of export)
7. Save the bundle

### Option 2: Update crowdin.yml Configuration

Edit your `crowdin.yml` file to specify the export path:

```yaml
"project_id": "834156"
"api_token": "84079ca8898375f652f3723b83c4da9cbdefdcd551841902bafa2341fc518efb686878a66ebb3f60"
"base_path": "."

"preserve_hierarchy": true

"files": [
  {
    "source": "Vocable/**/*.xcstrings",
    "ignore": [
      "CrowdinExport"
    ],
    "translation": "CrowdinExport/%locale%/%file_name%"
  }
]

"bundles": [
  15
]
```

### Option 3: Workaround - Update Test Script

If you can't change the bundle configuration, update the test script to handle the different directory:

```bash
# After download, check for both possible directories
if [ -d "CrowdinExport" ]; then
    EXPORT_DIR="CrowdinExport"
elif [ -d "%two_letters_code%" ]; then
    EXPORT_DIR="%two_letters_code%"
    # Rename it to expected directory
    mv "%two_letters_code%" CrowdinExport
    EXPORT_DIR="CrowdinExport"
else
    echo "✗ Export directory not found"
    exit 1
fi
```

## Testing After Fix

After fixing the bundle configuration:

```bash
# Clean up any existing files
rm -rf CrowdinExport/ "%two_letters_code%"

# Download again
export CROWDIN_PERSONAL_TOKEN=84079ca8898375f652f3723b83c4da9cbdefdcd551841902bafa2341fc518efb686878a66ebb3f60
crowdin bundle download 15 --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

# Check where files were extracted
ls -la

# Should now see CrowdinExport/ directory
ls -R CrowdinExport/
```

## Recommended Bundle Settings

When creating or editing a bundle in Crowdin for xcstrings:

1. **Name**: Something descriptive like "iOS xcstrings Bundle"
2. **Format**: Xcode Strings Catalog (.xcstrings)
3. **Files**: 
   - Vocable/Supporting Files/InfoPlist.xcstrings
   - Vocable/Supporting Files/Localizable.xcstrings
   - Vocable/Supporting Files/Presets.xcstrings
4. **Export pattern**: `CrowdinExport/%locale%/%file_name%`
   - Or: `%file_name%` (simpler, files in root)
5. **Include**: Approved translations only

## Why This Matters

The workflow and test scripts expect files in `CrowdinExport/` directory. If files are extracted elsewhere, the import will fail because:

1. The script looks for files in `CrowdinExport/`
2. The fastlane lanes expect this directory structure
3. Git staging looks in `Vocable/` for changes

## Quick Fix for Immediate Testing

If you need to test right now without changing bundle config:

```bash
# After download, manually move the files
mv "%two_letters_code%" CrowdinExport

# Then run the import
bundle exec fastlane xcstrings_import

# Check changes
git status
