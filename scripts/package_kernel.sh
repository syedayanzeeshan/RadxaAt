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

# Ensure we're in the right directory
cd "$(dirname "$0")/.."
WORK_DIR=$(pwd)

# Create complete package structure
echo_info "Creating package structure..."
mkdir -p complete-package
cd complete-package

# Clone kernel if not exists
if [ ! -d "linux" ]; then
    echo_info "Cloning kernel repository..."
    git clone --depth 1 https://github.com/Joshua-Riek/linux-rockchip.git linux
    cd linux
    git checkout rk3588
    cd ..
fi

# Copy our kernel modifications directly into kernel tree
echo_info "Integrating kernel modifications..."
cp -r ../linux/drivers/misc/rock5b_*.c linux/drivers/misc/
cp -r ../linux/drivers/misc/Makefile linux/drivers/misc/
cp -r ../linux/drivers/misc/Kconfig linux/drivers/misc/
cp -r ../linux/arch/arm64/boot/dts/rockchip/overlay/rock-5b-plus-enhanced.dts linux/arch/arm64/boot/dts/rockchip/overlay/

# Copy configuration and scripts
echo_info "Adding configuration and scripts..."
cp -r ../configs .
cp -r ../scripts .

# Copy documentation
echo_info "Adding documentation..."
cp ../README.md .
cp ../INSTRUCTIONS.md .
cp ../QUICK-START.md .

# Initialize git repository
echo_info "Initializing git repository..."
git init
git add .

# Create initial commit
git commit -m "Initial commit: Complete Rock 5B Plus Enhanced Kernel Package

This package includes:
- Complete kernel source with integrated enhancements:
  * Enhanced logging system
  * Power monitoring
  * Crash reporting
  * Mali GPU driver support
- Build and configuration scripts
- Documentation and guides
- Ready-to-use configuration files"

# Configure remote
echo_info "Configuring GitHub remote..."
git remote add origin https://github.com/syedayanzeeshan/RadxaAt.git

echo_success "Package prepared successfully"
echo "
Next steps:
1. Review the package contents
2. Push to GitHub using:
   git push -f origin main

The package is ready as a complete solution that users can clone and build directly."

# Show current status
echo -e "\nCurrent repository status:"
git status