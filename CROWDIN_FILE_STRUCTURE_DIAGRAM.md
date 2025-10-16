# Crowdin File Structure Diagram

## Overview
This diagram shows the Crowdin bundle configuration for the vocable-ios project, illustrating how source files are organized and exported.

## ⚠️ CURRENT ISSUE: Dual File Structure

**Problem**: The project currently has TWO separate sets of xcstrings files in Crowdin:
- **Files B (Root Level)**: Receives source string uploads
- **Files A (Bundle)**: Provides translation downloads

This creates a disconnect where source updates don't flow to the translation bundle.

### Root Cause: Invalid crowdin.yml Configuration

The `crowdin.yml` file has an **invalid translation pattern**:

```yaml
files:
  - source: /Vocable/Supporting Files/*.xcstrings
    translation: /Vocable/Supporting Files/%original_file_name%  # ❌ INVALID
    ignore:
      - CrowdinExport
```

**Error**: The translation pattern is missing the required `%locale%` placeholder.

**Result**: When `crowdin upload sources` runs, it encounters this invalid configuration and likely:
1. Ignores the crowdin.yml file entirely
2. Defaults to uploading files to the **root level** (Files B)
3. Creates files at `/InfoPlist.xcstrings`, `/Localizable.xcstrings`, `/Presets.xcstrings`

Meanwhile, the bundle is configured to use Files A at `/Vocable/Supporting Files/`, creating the disconnect.

## Current File Structure Diagram (PROBLEMATIC)

```
                    ┌─────────────────────────────────────────────┐
                    │         GITHUB REPOSITORY                   │
                    │                                             │
                    │  📁 Vocable/Supporting Files/               │
                    │     ├── InfoPlist.xcstrings                 │
                    │     ├── Localizable.xcstrings               │
                    │     └── Presets.xcstrings                   │
                    └─────────────────────────────────────────────┘
                                      │
                                      │ (crowdin upload sources)
                                      ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                         CROWDIN PROJECT (ID: 834156)                       │
│                                                                            │
│  ┌──────────────────────────────────┐  ┌──────────────────────────────┐  │
│  │  FILES B (Root Level) ⚠️          │  │  FILES A (Bundle) ⚠️          │  │
│  │  Receives source uploads         │  │  Provides translations       │  │
│  │                                  │  │                              │  │
│  │  📄 / (root)                     │  │  📄 Vocable/Supporting Files/│  │
│  │     ├── InfoPlist.xcstrings      │  │     ├── InfoPlist.xcstrings  │  │
│  │     ├── Localizable.xcstrings    │  │     ├── Localizable.xcstrings│  │
│  │     └── Presets.xcstrings        │  │     └── Presets.xcstrings    │  │
│  │                                  │  │                              │  │
│  │  ⬆️ Source strings pushed here   │  │  ⬇️ Translations pulled here │  │
│  └──────────────────────────────────┘  └──────────────────────────────┘  │
│           ❌ DISCONNECT ❌                                                 │
│  These should be the SAME files, not separate copies!                    │
└────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ (crowdin bundle download)
                                      ▼
                    ┌─────────────────────────────────────────────┐
                    │         DOWNLOADED BUNDLE                   │
                    │                                             │
                    │  📦 CrowdinExport/                          │
                    │     ├── InfoPlist.xcstrings                 │
                    │     ├── Localizable.xcstrings               │
                    │     └── Presets.xcstrings                   │
                    │                                             │
                    │  (From Files A, not Files B!)               │
                    └─────────────────────────────────────────────┘
                                      │
                                      │ (xcstrings_import lane)
                                      ▼
                    ┌─────────────────────────────────────────────┐
                    │      GITHUB REPOSITORY (Updated)            │
                    │                                             │
                    │  📁 Vocable/Supporting Files/               │
                    │     ├── InfoPlist.xcstrings ✓               │
                    │     ├── Localizable.xcstrings ✓             │
                    │     └── Presets.xcstrings ✓                 │
                    └─────────────────────────────────────────────┘
```

## The Problem Explained

### Current Workflow (BROKEN):

1. **Push Workflow** (`crowdin upload sources`):
   - Uploads source xcstrings to **Files B** (root level in Crowdin)
   - These files receive the latest source strings from GitHub

2. **Pull Workflow** (`crowdin bundle download`):
   - Downloads translations from **Files A** (bundle configuration)
   - These files may have outdated source strings

3. **Result**: 
   - ❌ New source strings don't reach translators
   - ❌ Translations are based on old source strings
   - ❌ Manual sync required between Files A and Files B

## Detailed File Mapping

### Source → Export → Destination Flow

```
SOURCE (GitHub)                    EXPORT (Crowdin)              DESTINATION (GitHub)
─────────────────────────────────────────────────────────────────────────────────────

Vocable/Supporting Files/          CrowdinExport/                Vocable/Supporting Files/
├── InfoPlist.xcstrings    ──────► InfoPlist.xcstrings    ──────► InfoPlist.xcstrings
├── Localizable.xcstrings  ──────► Localizable.xcstrings  ──────► Localizable.xcstrings
└── Presets.xcstrings      ──────► Presets.xcstrings      ──────► Presets.xcstrings
```

## Bundle Configuration Details

### Current Setup (xcstrings Bundle)

```yaml
Bundle Format: Xcode Strings Catalog (.xcstrings)
Bundle ID: [Your Bundle ID]
Project ID: 834156

Source Files Pattern:
  /Vocable/Supporting Files/**/*.xcstrings
  
Specific Files Included:
  ✓ InfoPlist.xcstrings    # App metadata translations
  ✓ Localizable.xcstrings  # Main UI translations
  ✓ Presets.xcstrings      # Preset phrases translations

Export Pattern:
  %file_name%
  
Export Settings:
  ✓ Include approved translations only
  ✓ Export as .xcstrings format
```

### Files Excluded from Bundle

```
❌ Build artifacts (XCBuildData/, build/, DerivedData/)
❌ Xcode project files (.xcodeproj)
❌ Other source code files
❌ Assets and resources (except xcstrings)
```

## Workflow Integration

### GitHub Actions Workflow

```
┌──────────────────────────────────────────────────────────────┐
│  1. PUSH WORKFLOW (crowdin_push.yml)                         │
│                                                              │
│  Trigger: Push to develop branch                            │
│  Action: Upload source xcstrings to Crowdin                 │
│                                                              │
│  Vocable/Supporting Files/*.xcstrings ──► Crowdin Project   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  2. PULL WORKFLOW (crowdin_pull.yml)                         │
│                                                              │
│  Trigger: Manual or scheduled                               │
│  Steps:                                                      │
│    1. Download bundle from Crowdin                          │
│    2. Extract to CrowdinExport/                             │
│    3. Run xcstrings_import lane                             │
│    4. Copy files to Vocable/Supporting Files/               │
│    5. Create pull request with changes                      │
└──────────────────────────────────────────────────────────────┘
```

## File Contents Overview

### InfoPlist.xcstrings
- **Purpose**: App metadata and Info.plist localizations
- **Contains**: App name, permissions descriptions, etc.
- **Languages**: Multiple target languages

### Localizable.xcstrings
- **Purpose**: Main application UI strings
- **Contains**: Buttons, labels, messages, alerts
- **Languages**: Multiple target languages

### Presets.xcstrings
- **Purpose**: Preset phrases for AAC communication
- **Contains**: Pre-defined communication phrases
- **Languages**: Multiple target languages

## Translation Languages

Based on the project structure, translations are managed for:
- **Base Language**: English (en)
- **Target Languages**: 
  - German (de) - visible in `de.lproj/`
  - Multiple languages (mul) - visible in `mul.lproj/`
  - Additional languages configured in Crowdin

## Key Points

1. **Single Source of Truth**: The 3 xcstrings files in `Vocable/Supporting Files/` are the source
2. **Bundle-Based Export**: Crowdin uses a bundle to package all translations
3. **Direct File Replacement**: No complex transformation needed (unlike XLIFF)
4. **Automated Sync**: GitHub Actions handles push/pull automatically
5. **Clean Structure**: Only translation files, no build artifacts

## Comparison: Old vs New Structure

### Old XLIFF Structure (Deprecated)
```
Source: *.xcstrings
  ↓ (export as XLIFF)
Crowdin: *.xliff files
  ↓ (download + transform)
Temp: Fixed *.xliff files
  ↓ (xcodebuild -importLocalizations)
Destination: *.xcstrings (updated)
```

### New xcstrings Structure (Current)
```
Source: *.xcstrings
  ↓ (direct sync)
Crowdin: *.xcstrings files
  ↓ (download)
CrowdinExport: *.xcstrings files
  ↓ (copy)
Destination: *.xcstrings (updated)
```

## SOLUTION: Fix the Dual File Structure

### Option 1: Fix crowdin.yml and Update Bundle (RECOMMENDED)

This is the cleanest solution that properly uses the crowdin.yml configuration:

**Step 1: Fix crowdin.yml**

Update the translation pattern to include the required `%locale%` placeholder:

```yaml
"project_id_env": "CROWDIN_PROJECT_ID"
"api_token_env": "CROWDIN_PERSONAL_TOKEN"

files:
  - source: /Vocable/Supporting Files/*.xcstrings
    translation: /Vocable/Supporting Files/%locale%/%original_file_name%
    ignore:
      - CrowdinExport
```

**Step 2: Update Crowdin Bundle**

1. Go to: https://crowdin.com/project/vocable-ios-clone/settings#bundles
2. Edit your xcstrings bundle
3. Update source files to match the crowdin.yml path:
   - `Vocable/Supporting Files/InfoPlist.xcstrings`
   - `Vocable/Supporting Files/Localizable.xcstrings`
   - `Vocable/Supporting Files/Presets.xcstrings`

**Step 3: Clean up duplicate files**

Delete the root-level files (Files B) in Crowdin since they were created due to the invalid config.

**Result**: 
- ✅ crowdin.yml properly configures file paths
- ✅ `crowdin upload sources` uploads to `/Vocable/Supporting Files/`
- ✅ Bundle downloads from the same location
- ✅ Single source of truth

### Option 2: Keep Root Files and Update Bundle (SIMPLER)

If you prefer to keep the current root-level files:

1. **Update crowdin.yml** to explicitly target root:
   ```yaml
   files:
     - source: /Vocable/Supporting Files/*.xcstrings
       translation: /%locale%/%original_file_name%
       ignore:
         - CrowdinExport
   ```

2. **Update Bundle Configuration**:
   - Remove Files A from bundle
   - Add root-level Files B to bundle

3. **Delete Files A** in Crowdin UI

**Result**: Both push and pull use root-level files

### Option 3: Manual Cleanup Only

If you don't want to change configurations:

1. Manually delete one set of files in Crowdin (recommend deleting Files B at root)
2. Ensure bundle points to the remaining files
3. Accept that crowdin.yml has an invalid config (not recommended)

## Correct File Structure Diagram (AFTER FIX)

```
                    ┌─────────────────────────────────────────────┐
                    │         GITHUB REPOSITORY                   │
                    │                                             │
                    │  📁 Vocable/Supporting Files/               │
                    │     ├── InfoPlist.xcstrings                 │
                    │     ├── Localizable.xcstrings               │
                    │     └── Presets.xcstrings                   │
                    └─────────────────────────────────────────────┘
                                      │
                                      │ (crowdin upload sources)
                                      ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                         CROWDIN PROJECT (ID: 834156)                       │
│                                                                            │
│                    ┌──────────────────────────────────┐                   │
│                    │  SINGLE SET OF FILES ✅           │                   │
│                    │                                  │                   │
│                    │  📄 / (root) OR                  │                   │
│                    │     Vocable/Supporting Files/    │                   │
│                    │     ├── InfoPlist.xcstrings      │                   │
│                    │     ├── Localizable.xcstrings    │                   │
│                    │     └── Presets.xcstrings        │                   │
│                    │                                  │                   │
│                    │  ⬆️ Source strings pushed here   │                   │
│                    │  ⬇️ Translations pulled here     │                   │
│                    │                                  │                   │
│                    │  (Bundle configured for these)   │                   │
│                    └──────────────────────────────────┘                   │
│                                                                            │
│  ✅ CONNECTED: Same files for push and pull!                              │
└────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ (crowdin bundle download)
                                      ▼
                    ┌─────────────────────────────────────────────┐
                    │         DOWNLOADED BUNDLE                   │
                    │                                             │
                    │  📦 CrowdinExport/                          │
                    │     ├── InfoPlist.xcstrings                 │
                    │     ├── Localizable.xcstrings               │
                    │     └── Presets.xcstrings                   │
                    │                                             │
                    │  (Same files as source upload!)             │
                    └─────────────────────────────────────────────┘
                                      │
                                      │ (xcstrings_import lane)
                                      ▼
                    ┌─────────────────────────────────────────────┐
                    │      GITHUB REPOSITORY (Updated)            │
                    │                                             │
                    │  📁 Vocable/Supporting Files/               │
                    │     ├── InfoPlist.xcstrings ✓               │
                    │     ├── Localizable.xcstrings ✓             │
                    │     └── Presets.xcstrings ✓                 │
                    └─────────────────────────────────────────────┘
```

## Verification Steps

After fixing the dual file structure:

1. **Upload a test source string**:
   ```bash
   # Make a small change to a source file
   # Push to develop branch
   # Verify it appears in Crowdin
   ```

2. **Check Crowdin UI**:
   - Verify only ONE set of files exists
   - Confirm the bundle includes these files
   - Check that new source strings appear

3. **Test the pull workflow**:
   ```bash
   # Trigger the pull workflow
   # Verify translations download correctly
   # Confirm source strings are up-to-date
   ```

## Benefits After Fix

✅ **Single Source of Truth**: One set of files in Crowdin
✅ **Automatic Sync**: Source updates immediately available to translators
✅ **Simplicity**: Direct file-to-file mapping
✅ **Speed**: No build step required
✅ **Reliability**: Fewer transformation steps
✅ **Maintainability**: Easy to understand and debug
✅ **Native Format**: Uses Xcode's native xcstrings format
✅ **No Build Dependencies**: Works without compiling the project

---

*Last Updated: Based on current project configuration*
*Project: vocable-ios-clone (Crowdin ID: 834156)*
*Status: ⚠️ Dual file structure identified - requires fix*
