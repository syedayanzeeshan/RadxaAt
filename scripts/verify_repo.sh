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
}

# Repository information
REPO_URL="https://github.com/syedayanzeeshan/RadxaAt"
REPO_API="https://api.github.com/repos/syedayanzeeshan/RadxaAt"

echo_info "Verifying repository structure..."

# Check local structure
echo "Local repository structure:"
tree -L 2 complete-package/

# Check remote repository
echo -e "\nRemote repository information:"
curl -s "$REPO_API" | jq '{name, description, default_branch, size, language}'

echo -e "\nRepository is available at: $REPO_URL"
echo "
Key components:
1. Kernel Modifications:
   - Enhanced logging system
   - Power monitoring
   - Crash reporting
   - Mali GPU driver support

2. Build System:
   - Build scripts
   - Configuration files
   - Installation tools

3. Documentation:
   - README.md
   - INSTRUCTIONS.md
   - QUICK-START.md

To clone and use:
git clone $REPO_URL
cd RadxaAt
./scripts/build_all.sh"