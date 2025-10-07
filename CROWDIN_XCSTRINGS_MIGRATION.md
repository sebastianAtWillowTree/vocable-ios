# Migrating from XLIFF to xcstrings Bundles

This guide explains how to migrate the Crowdin workflow from XLIFF bundles to xcstrings bundles.

## Why Migrate to xcstrings?

### Current XLIFF Workflow Issues:
- ❌ Complex multi-step process (download → fix paths → fix IDs → import)
- ❌ Requires `xcodebuild -importLocalizations` which needs to build the project
- ❌ SwiftLint plugin validation failures in CI
- ❌ Slower execution time
- ❌ More points of failure

### xcstrings Workflow Benefits:
- ✅ Simple direct file replacement
- ✅ No build step required
- ✅ No SwiftLint issues
- ✅ Faster execution
- ✅ Native Xcode format (Xcode 15+)
- ✅ Easier to debug

## Migration Steps

### 1. Create xcstrings Bundle in Crowdin

1. Go to your Crowdin project: https://crowdin.com/project/vocable-ios-clone
2. Navigate to **Bundles** section
3. Click **Create Bundle**
4. Configure the bundle:
   - **Name**: `iOS xcstrings Bundle` (or your preferred name)
   - **Format**: Select **Xcode Strings Catalog (.xcstrings)**
   - **Files to include**: Select these files:
     - `Vocable/Supporting Files/InfoPlist.xcstrings`
     - `Vocable/Supporting Files/Localizable.xcstrings`
     - `Vocable/Supporting Files/Presets.xcstrings`
   - **Export settings**: 
     - ✅ Include approved translations only (recommended)
     - ✅ Export only translated strings (optional)
5. Save the bundle and note the **Bundle ID** (you'll need this for the workflow)

### 2. Update the Workflow

Edit `.github/workflows/crowdin_pull.yml`:

```yaml
- name: Download Translations
  run: |
    # Replace 13 with your new xcstrings bundle ID
    crowdin bundle download YOUR_BUNDLE_ID --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN
  shell: sh
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    CROWDIN_PROJECT_ID: 834156
    CROWDIN_PERSONAL_TOKEN: ${{ secrets.CROWDIN_PERSONAL_TOKEN }}

- name: Import translations to project
  uses: ./.github/actions/run_lane
  with:
    # Change from xliff_import to xcstrings_import
    lane: xcstrings_import
```

### 3. Test the Migration

#### Option A: Test Locally

```bash
# Set environment variable
export CROWDIN_PERSONAL_TOKEN=your_token_here

# Download from new bundle
crowdin bundle download YOUR_BUNDLE_ID --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

# Check what was downloaded
ls -R CrowdinExport/

# Import using new lane
bundle exec fastlane xcstrings_import

# Check changes
git status
git diff Vocable/Supporting\ Files/
```

#### Option B: Test in GitHub Actions

1. Update the workflow with your new bundle ID
2. Commit and push changes
3. Manually trigger the workflow via GitHub Actions UI
4. Review the debug output to verify xcstrings files are downloaded and imported

### 4. Verify the Results

After running the workflow, check:

- ✅ `CrowdinExport/` contains `.xcstrings` files (not `.xliff`)
- ✅ The three xcstrings files in `Vocable/Supporting Files/` are updated
- ✅ Git shows changes to the xcstrings files
- ✅ No build errors or SwiftLint issues
- ✅ Pull request is created successfully

## Workflow Comparison

### Old XLIFF Workflow:
```
Download XLIFF → Fix paths → Fix IDs → xcodebuild import → Update xcstrings
```

### New xcstrings Workflow:
```
Download xcstrings → Copy to project → Done
```

## Fastlane Lanes

### Old Lane (xliff_import):
```ruby
lane :xliff_import do
  Dir.glob('./../CrowdinExport/**/*.xliff') do |xliff|
    text = File.read(xliff)
    text = text.gsub('original="/[willowtreeapps.vocable-ios] develop/Vocable/', 'original="Vocable/')
    text = text.gsub(/<trans-unit id=".*?" resname="(.*?)"/, '<trans-unit id="\1"')
    File.open(xliff, "w") {|file| file.puts text }
    run_with_retries(3, "xcodebuild -importLocalizations -localizationPath '#{xliff}' -project ./../Vocable.xcodeproj -skipPackagePluginValidation -skipMacroValidation")
  end
end
```

### New Lane (xcstrings_import):
```ruby
lane :xcstrings_import do
  xcstrings_files = ['InfoPlist.xcstrings', 'Localizable.xcstrings', 'Presets.xcstrings']
  
  xcstrings_files.each do |filename|
    source_files = Dir.glob("./../CrowdinExport/**/#{filename}")
    
    if source_files.empty?
      puts "⚠️  Warning: #{filename} not found in CrowdinExport, skipping"
      next
    end
    
    source_file = source_files.first
    destination = "./../Vocable/Supporting Files/#{filename}"
    
    if File.exist?(destination)
      FileUtils.cp(source_file, destination)
      puts "✓ Updated: #{filename}"
    else
      puts "✗ Error: #{destination} not found in project"
    end
  end
end
```

## Troubleshooting

### Bundle Download Returns No Files

**Cause**: Bundle might not have approved translations or is misconfigured

**Solution**:
1. Check bundle configuration in Crowdin
2. Verify translations are approved
3. Ensure bundle includes the correct files

### xcstrings Files Not Found in CrowdinExport

**Cause**: Bundle is still configured for XLIFF export

**Solution**:
1. Verify bundle format is set to "Xcode Strings Catalog (.xcstrings)"
2. Re-download the bundle
3. Check the debug output in the workflow

### Files Not Updating in Project

**Cause**: File paths might not match

**Solution**:
1. Check the `xcstrings_import` lane is finding the files
2. Verify the destination paths are correct
3. Review the fastlane output for warnings

## Rollback Plan

If you need to rollback to XLIFF:

1. Change the workflow back to use bundle 13 (or your XLIFF bundle ID)
2. Change the lane from `xcstrings_import` to `xliff_import`
3. Commit and push

The old `xliff_import` lane is still available in the Fastfile for backward compatibility.

## Next Steps

After successful migration:

1. Monitor a few workflow runs to ensure stability
2. Consider removing the old `xliff_import` lane if no longer needed
3. Update any documentation referencing the old XLIFF process
4. Archive or delete the old XLIFF bundle in Crowdin
