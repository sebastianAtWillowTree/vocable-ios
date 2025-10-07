# Crowdin Bundle Configuration Guide

## Problem: Bundle Downloads Build Data Instead of Translation Files

### What Happened with Bundle 17

Bundle 17 ("xcstrings2") downloaded successfully but contained:
- ❌ Xcode build cache data (`XCBuildData/`)
- ❌ No `.xcstrings` files
- ❌ No translation content

This happens when the bundle is configured to include the wrong source files.

## Root Cause

The bundle is likely configured to include:
- The entire project directory (including build artifacts)
- Or incorrect file patterns that match build files

## Correct Bundle Configuration

### Step 1: Go to Bundle Settings

1. Visit: https://crowdin.com/project/vocable-ios-clone/settings#bundles
2. Find your bundle (e.g., #17 "xcstrings2")
3. Click **Edit**

### Step 2: Configure Source Files

**IMPORTANT**: Only include the actual xcstrings files, not the entire project.

#### Option A: Manually Select Files (Recommended)

In the bundle configuration, manually select ONLY these files:
- ✅ `Vocable/Supporting Files/InfoPlist.xcstrings`
- ✅ `Vocable/Supporting Files/Localizable.xcstrings`
- ✅ `Vocable/Supporting Files/Presets.xcstrings`

**DO NOT** select:
- ❌ `build/` directory
- ❌ `XCBuildData/` directory
- ❌ `.xcodeproj` files
- ❌ Any other build artifacts

#### Option B: Use Source Pattern (If Manual Selection Not Available)

If Crowdin requires a source pattern, use this **specific** pattern:

**Correct Pattern:**
```
Vocable/Supporting Files/*.xcstrings
```

This pattern:
- ✅ Only matches files in `Vocable/Supporting Files/` directory
- ✅ Excludes build directories
- ✅ Gets exactly the 3 xcstrings files you need

**AVOID These Patterns:**
```
**/*.xcstrings                    # Too broad, includes build files
Vocable/**/*.xcstrings           # Too broad, includes build files  
*.xcstrings                      # Too broad, searches everywhere
```

**Why the specific pattern matters:**
- Build artifacts can be in `build/`, `.build/`, `DerivedData/`, etc.
- Using `**/*.xcstrings` will match xcstrings files in ALL directories
- The pattern `Vocable/Supporting Files/*.xcstrings` limits the search to only the translation files

### Step 3: Configure Export Settings

1. **Format**: Xcode Strings Catalog (.xcstrings)
2. **Export pattern**: 
   - Simple: `%file_name%`
   - Or with locale: `%locale%/%file_name%`
3. **Include**: Approved translations only (recommended)

### Step 4: Test the Bundle

After saving the configuration:

```bash
# Clean up
rm -rf CrowdinExport/ build/

# Download the bundle
export CROWDIN_PERSONAL_TOKEN=your_token
crowdin bundle download 17 --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

# Check what was downloaded
ls -la

# Should see xcstrings files, NOT build data
find . -name "*.xcstrings" -type f
```

## Expected Output After Fix

When correctly configured, you should see:

```
✔️  #17 'xcstrings2' has been successfully downloaded
✔️  Extracting archive     
✔️  InfoPlist.xcstrings
✔️  Localizable.xcstrings
✔️  Presets.xcstrings

File counts:
  XLIFF files: 0
  xcstrings files: 3

✓ Detected xcstrings files - will use xcstrings_import lane
```

## Alternative: Create a New Bundle from Scratch

If the current bundle is too broken, create a fresh one:

### 1. Create New Bundle

1. Go to Bundles → **Create Bundle**
2. Name: `iOS Translations - xcstrings`
3. Format: **Xcode Strings Catalog (.xcstrings)**

### 2. Add Files Manually

Click **Add Files** and select ONLY:
- `Vocable/Supporting Files/InfoPlist.xcstrings`
- `Vocable/Supporting Files/Localizable.xcstrings`
- `Vocable/Supporting Files/Presets.xcstrings`

### 3. Configure Export

- Export pattern: `%file_name%`
- Include approved translations only: ✅

### 4. Save and Test

Note the new bundle ID and test:

```bash
./test_crowdin_xcstrings_workflow.sh NEW_BUNDLE_ID
```

## Verification Checklist

After configuring the bundle, verify:

- [ ] Bundle includes ONLY the 3 xcstrings files
- [ ] Bundle does NOT include build directories
- [ ] Bundle does NOT include .xcodeproj files
- [ ] Export pattern is simple (e.g., `%file_name%`)
- [ ] Test download produces xcstrings files
- [ ] No build artifacts in download

## Common Mistakes to Avoid

### ❌ Including Too Many Files
```
Source: Vocable/**/*
Result: Downloads entire project including build files
```

### ❌ Wrong File Pattern
```
Source: **/*.xcstrings
Result: Includes build cache xcstrings files
```

### ❌ Complex Export Pattern
```
Export: %two_letters_code%/%original_path%/%file_name%
Result: Creates nested directories with placeholders
```

### ✅ Correct Configuration
```
Source: Manually selected 3 xcstrings files
Export: %file_name%
Result: Clean download with just translation files
```

## Testing Your Bundle

Use this command to verify your bundle configuration:

```bash
# Set token
export CROWDIN_PERSONAL_TOKEN=your_token

# Download and inspect
crowdin bundle download YOUR_BUNDLE_ID --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

# Check for xcstrings files (should find 3)
find . -name "*.xcstrings" -type f | wc -l

# Check for build files (should find 0)
find . -name "*.xcbuilddata" -type f | wc -l
find . -type d -name "XCBuildData" | wc -l
```

Expected results:
- xcstrings files: **3**
- build files: **0**

## Summary

The key is to be **specific** about which files to include in the bundle:
1. Manually select the 3 xcstrings files
2. Use a simple export pattern
3. Test the download
4. Verify no build artifacts are included

Once configured correctly, the workflow will work smoothly!
