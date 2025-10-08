# Testing GitHub Actions Workflow Locally with Act

This guide explains how to test the Crowdin Pull workflow locally using `act`, which simulates a GitHub Actions environment on your machine.

## Prerequisites

1. **Install act** (already installed):
   ```bash
   brew install act
   ```

2. **Configure secrets and variables**:
   - Edit `.secrets` file with your actual tokens
   - Edit `.vars` file if needed (already configured)

## Configuration Files

### `.actrc`
Already configured with:
- Platform mappings (macOS → Ubuntu containers)
- Secret and variable file paths
- Artifact server settings

### `.secrets`
Contains sensitive tokens (DO NOT commit with real values):
```bash
GITHUB_TOKEN=your_github_token_here
CROWDIN_PERSONAL_TOKEN=your_crowdin_personal_token_here
```

### `.vars`
Contains repository variables:
```bash
CROWDIN_PROJECT_ID=834156
RUNNER_TYPE=macos-latest
```

## Running the Workflow Locally

### 1. List Available Workflows
```bash
act -l
```

### 2. Run the Crowdin Pull Workflow

**Trigger on push to develop:**
```bash
act push -W .github/workflows/crowdin_pull.yml
```

**Trigger workflow_dispatch (manual trigger):**
```bash
act workflow_dispatch -W .github/workflows/crowdin_pull.yml
```

**Run with specific runner choice:**
```bash
act workflow_dispatch -W .github/workflows/crowdin_pull.yml --input runner=macos-latest
```

### 3. Dry Run (see what would execute)
```bash
act -n -W .github/workflows/crowdin_pull.yml
```

### 4. Run Specific Job
```bash
act -j synchronize-with-crowdin -W .github/workflows/crowdin_pull.yml
```

### 5. Debug Mode
```bash
act -v -W .github/workflows/crowdin_pull.yml
```

## Important Notes

### Limitations of act

1. **Container-based**: act runs workflows in Docker containers, not native macOS
   - The `.actrc` maps `macos-latest` to Ubuntu containers
   - Some macOS-specific tools may not work exactly the same

2. **Homebrew commands**: Commands like `brew install` will work in the Ubuntu container but install Linux versions

3. **File paths**: Workspace paths will be different in containers

4. **Custom actions**: Local custom actions (`.github/actions/run_lane`) should work if they're shell-based

### What Works Well

- ✅ Testing workflow logic and step sequence
- ✅ Validating environment variables and secrets
- ✅ Checking script syntax and commands
- ✅ Debugging workflow issues before pushing

### What May Not Work

- ❌ macOS-specific tools or behaviors
- ❌ Xcode commands (xcodebuild)
- ❌ iOS-specific operations
- ❌ Native macOS file system operations

## Workflow-Specific Testing

For the Crowdin Pull workflow, you can test:

1. **Download step**: Verify Crowdin CLI commands work
2. **Import step**: Check if the custom action executes
3. **Git operations**: Validate staging and PR creation logic
4. **Environment setup**: Verify Ruby, bundler, SwiftLint installation

## Testing Specific Steps

### Testing Just the Download Translations Step

Since `act` runs in containers and may have issues with the full workflow, you can test individual steps:

**Option 1: Test Download Step Directly (Recommended)**

Just run the Crowdin CLI command directly on your machine:

```bash
# Set your Crowdin token
export CROWDIN_PERSONAL_TOKEN=your_token_here

# Clean previous downloads
rm -rf CrowdinExport/ CrowdinExports/

# Download translations (bundle 19 for xcstrings)
crowdin bundle download 19 --project-id=834156 --token=$CROWDIN_PERSONAL_TOKEN

# Check what was downloaded
ls -la CrowdinExport* 2>/dev/null || echo "No export directory found"
```

**Option 2: Test with act (Limited)**

Create a minimal workflow to test just the download step:

```bash
# Create a test workflow file
cat > .github/workflows/test_download.yml << 'EOF'
name: Test Download Only
on: workflow_dispatch

jobs:
  test-download:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Install Crowdin CLI
        run: |
          wget -qO - https://artifacts.crowdin.com/repo/GPG-KEY-crowdin | sudo apt-key add -
          echo "deb https://artifacts.crowdin.com/repo/deb/ /" | sudo tee /etc/apt/sources.list.d/crowdin.list
          sudo apt-get update
          sudo apt-get install -y crowdin3
          
      - name: Download Translations
        run: crowdin bundle download 19 --project-id=${{ vars.CROWDIN_PROJECT_ID }} --token=${{ secrets.CROWDIN_PERSONAL_TOKEN }}
        
      - name: Check Downloaded Files
        run: |
          echo "=== Looking for export directories ==="
          ls -la | grep -i crowdin || echo "No Crowdin directories found"
          echo ""
          echo "=== Checking for xcstrings files ==="
          find . -name "*.xcstrings" -type f 2>/dev/null | head -10
EOF

# Run with act
act workflow_dispatch -W .github/workflows/test_download.yml

# Clean up test workflow
rm .github/workflows/test_download.yml
```

**Option 3: Hybrid Approach (Best for Full Testing)**

Use the existing test script which already works:

```bash
# This script tests the complete workflow locally
bash test_crowdin_xcstrings_workflow.sh 19
```

This is actually better than `act` for this workflow because:
- ✅ Runs natively on macOS (not in container)
- ✅ Uses your local Crowdin CLI installation
- ✅ Tests the actual fastlane import process
- ✅ Shows real git changes
- ✅ Faster and more reliable

## Alternative: Step-by-Step Testing

If act doesn't fully simulate the workflow, use the test scripts:

```bash
# Test xcstrings workflow
bash test_crowdin_xcstrings_workflow.sh 19

# Test XLIFF workflow  
bash test_crowdin_workflow.sh 13
```

## Troubleshooting

### act fails to start
- Check Docker is running: `docker ps`
- Verify `.actrc` configuration

### Secrets not loading
- Ensure `.secrets` file exists and has correct format
- Check file permissions: `chmod 600 .secrets`

### Workflow not found
- Verify workflow file path: `.github/workflows/crowdin_pull.yml`
- Check workflow syntax: `act -l`

### Container issues
- Pull latest images: `docker pull catthehacker/ubuntu:act-latest`
- Clean up: `docker system prune`

## Security Notes

1. **Never commit `.secrets` with real tokens**
2. Add `.secrets` to `.gitignore` (already done)
3. Use test/dummy tokens for local testing when possible
4. Rotate tokens if accidentally exposed

## Resources

- [act Documentation](https://github.com/nektos/act)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Crowdin CLI Documentation](https://crowdin.github.io/crowdin-cli/)
