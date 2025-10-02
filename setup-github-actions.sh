#!/bin/bash

# macOS GitHub Actions Local Setup Script
# Idempotent: Safe to run multiple times
# Checks requirements before installation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is for macOS only"
    exit 1
fi

log_section "macOS GitHub Actions Setup"
log_info "Starting setup process..."

# ============================================
# Phase 1: Xcode Command Line Tools
# ============================================
log_section "Phase 1: Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    log_success "Xcode CLI Tools already installed at $(xcode-select -p)"
else
    log_info "Installing Xcode CLI Tools..."
    xcode-select --install
    log_warning "Please complete the Xcode CLI Tools installation in the popup"
    log_warning "Press Enter after installation completes..."
    read -r
    log_success "Xcode CLI Tools installed"
fi

# ============================================
# Phase 2: Homebrew
# ============================================
log_section "Phase 2: Homebrew"

if command_exists brew; then
    log_success "Homebrew already installed (version $(brew --version | head -n1))"
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    
    log_success "Homebrew installed"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update >/dev/null 2>&1
log_success "Homebrew updated"

# ============================================
# Phase 3: Docker Desktop
# ============================================
log_section "Phase 3: Docker Desktop"

if command_exists docker; then
    if docker ps >/dev/null 2>&1; then
        log_success "Docker already installed and running"
    else
        log_warning "Docker installed but not running"
        log_info "Starting Docker Desktop..."
        open -a Docker
        log_info "Waiting for Docker to start (30 seconds)..."
        sleep 30
        if docker ps >/dev/null 2>&1; then
            log_success "Docker is now running"
        else
            log_error "Docker failed to start. Please start Docker Desktop manually"
        fi
    fi
else
    log_info "Installing Docker Desktop..."
    brew install --cask docker
    log_info "Starting Docker Desktop..."
    open -a Docker
    log_info "Waiting for Docker to start (30 seconds)..."
    sleep 30
    log_success "Docker installed"
fi

# ============================================
# Phase 4: rbenv (Ruby Version Manager)
# ============================================
log_section "Phase 4: rbenv"

if command_exists rbenv; then
    log_success "rbenv already installed"
else
    log_info "Installing rbenv and ruby-build..."
    brew install rbenv ruby-build
    log_success "rbenv installed"
fi

# Initialize rbenv in shell
if ! grep -q 'rbenv init' ~/.zshrc 2>/dev/null; then
    log_info "Adding rbenv to ~/.zshrc..."
    echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
fi

# Load rbenv for this session
eval "$(rbenv init - zsh)" 2>/dev/null || true

# ============================================
# Phase 5: Ruby 3.3.1
# ============================================
log_section "Phase 5: Ruby 3.3.1"

if rbenv versions | grep -q "3.3.1"; then
    log_success "Ruby 3.3.1 already installed"
else
    log_info "Installing Ruby 3.3.1 (this may take several minutes)..."
    rbenv install 3.3.1
    log_success "Ruby 3.3.1 installed"
fi

# Set global Ruby version
log_info "Setting Ruby 3.3.1 as global version..."
rbenv global 3.3.1
rbenv rehash

# Verify Ruby version
RUBY_VERSION=$(ruby -v | grep -o "3.3.1" || echo "")
if [[ "$RUBY_VERSION" == "3.3.1" ]]; then
    log_success "Ruby 3.3.1 is active"
else
    log_warning "Ruby version mismatch. Please restart your terminal and try running the script again"
fi

# ============================================
# Phase 6: Bundler
# ============================================
log_section "Phase 6: Bundler"

if gem list bundler -i >/dev/null 2>&1; then
    log_success "Bundler already installed (version $(bundle --version | grep -o '[0-9.]*'))"
else
    log_info "Installing Bundler..."
    gem install bundler
    rbenv rehash
    log_success "Bundler installed"
fi

# ============================================
# Phase 7: act (GitHub Actions Runner)
# ============================================
log_section "Phase 7: act"

if command_exists act; then
    log_success "act already installed (version $(act --version))"
else
    log_info "Installing act..."
    brew install act
    log_success "act installed"
fi

# ============================================
# Phase 8: Project Configuration
# ============================================
log_section "Phase 8: Project Configuration"

# Create .actrc if it doesn't exist
if [[ -f ".actrc" ]]; then
    log_success ".actrc already exists"
else
    log_info "Creating .actrc configuration..."
    cat > .actrc << 'EOF'
-P ubuntu-latest=catthehacker/ubuntu:full-latest
-P macos-latest=catthehacker/ubuntu:act-latest
--container-architecture linux/amd64
EOF
    log_success ".actrc created"
fi

# Create .secrets template if it doesn't exist
if [[ -f ".secrets" ]]; then
    log_success ".secrets already exists"
else
    log_info "Creating .secrets template..."
    cat > .secrets << 'EOF'
GITHUB_TOKEN=your_github_personal_access_token
CROWDIN_PERSONAL_TOKEN=your_crowdin_api_token
CROWDIN_PR_BOT_TOKEN=your_github_bot_token
EOF
    chmod 600 .secrets
    log_warning ".secrets created - UPDATE WITH YOUR ACTUAL TOKENS"
fi

# Create .vars template if it doesn't exist
if [[ -f ".vars" ]]; then
    log_success ".vars already exists"
else
    log_info "Creating .vars template..."
    cat > .vars << 'EOF'
CROWDIN_PROJECT_ID=your_project_id
EOF
    chmod 600 .vars
    log_warning ".vars created - UPDATE WITH YOUR PROJECT ID"
fi

# Update .gitignore
if [[ -f ".gitignore" ]]; then
    if ! grep -q ".secrets" .gitignore; then
        log_info "Adding secrets to .gitignore..."
        echo -e "\n# GitHub Actions local secrets\n.secrets\n.vars\n.env" >> .gitignore
        log_success ".gitignore updated"
    else
        log_success ".gitignore already configured"
    fi
fi

# ============================================
# Phase 9: Project Dependencies
# ============================================
log_section "Phase 9: Project Dependencies"

if [[ -f "Gemfile" ]]; then
    log_info "Installing project dependencies..."
    bundle install
    log_success "Dependencies installed"
else
    log_warning "No Gemfile found - skipping bundle install"
fi

# ============================================
# Phase 10: Verification
# ============================================
log_section "Phase 10: Setup Verification"

ERRORS=0

# Check each requirement
check_requirement() {
    local name=$1
    local command=$2
    
    if eval "$command" >/dev/null 2>&1; then
        log_success "$name"
    else
        log_error "$name"
        ((ERRORS++))
    fi
}

check_requirement "Xcode CLI Tools" "xcode-select -p"
check_requirement "Homebrew" "brew --version"
check_requirement "Docker installed" "docker --version"
check_requirement "Docker running" "docker ps"
check_requirement "rbenv" "rbenv --version"
check_requirement "Ruby 3.3.1" "ruby -v | grep -q 3.3.1"
check_requirement "Bundler" "bundle --version"
check_requirement "act" "act --version"

# ============================================
# Summary
# ============================================
log_section "Setup Complete"

if [[ $ERRORS -eq 0 ]]; then
    log_success "All requirements installed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Update .secrets with your actual tokens"
    echo "  2. Update .vars with your project ID"
    echo "  3. Restart your terminal (to load rbenv)"
    echo "  4. Run: act -l (to list workflows)"
    echo "  5. Run: act workflow_dispatch --secret-file .secrets --var-file .vars"
else
    log_warning "Setup completed with $ERRORS error(s)"
    log_info "Please review the errors above and fix them manually"
fi

echo ""
log_info "For help, see: macOS_GitHub_Actions_Setup_Guide.md"
