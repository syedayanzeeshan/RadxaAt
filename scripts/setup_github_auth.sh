#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if package creation is complete
if [ ! -d "complete-package" ]; then
    echo_error "Package directory not found. Please wait for package creation to complete."
fi

# Instructions for GitHub setup
echo_info "GitHub Authentication Setup"
echo "
1. Create a Personal Access Token (PAT):
   - Go to https://github.com/settings/tokens
   - Click 'Generate new token (classic)'
   - Select scopes: 'repo' and 'workflow'
   - Copy the generated token

2. Enter your GitHub username: "
read GITHUB_USERNAME

echo "3. Enter your Personal Access Token: "
read -s GITHUB_TOKEN

echo -e "\nConfiguring git..."
cd complete-package

# Configure git
git config user.name "Syed Ayan Zeeshan"
git config user.email "syedayanzeeshan@gmail.com"

# Update remote URL with authentication
git remote set-url origin "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/syedayanzeeshan/RadxaAt.git"

echo_success "GitHub authentication configured"
echo "
You can now push the package using:
cd complete-package
git push -f origin main"