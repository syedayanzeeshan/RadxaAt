#!/bin/bash

# GPU Driver Switch Script for Rock 5B+
# Switches from Panfrost to Mali proprietary driver

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

print_status "Starting GPU driver switch from Panfrost to Mali..."

# 1. Install required packages for Mali driver
print_status "Updating package lists..."
apt-get update

# 2. Detect the SoC type and install appropriate Mali driver
print_status "Detecting SoC type..."
PRODUCT_ID=""
if command -v rsetup >/dev/null 2>&1; then
    PRODUCT_ID=$(rsetup get_product_ids)
    print_status "Product ID: $PRODUCT_ID"
else
    print_warning "rsetup not found, assuming RK3588 for Rock 5B+"
    PRODUCT_ID="rk3588"
fi

# Install Mali driver based on SoC
if echo "$PRODUCT_ID" | grep -qE 'rk3588'; then
    print_status "Installing Mali driver for RK3588..."
    apt-get install -y libmali-valhall-g610-g24p0-x11-wayland-gbm
elif echo "$PRODUCT_ID" | grep -qE 'rk3576|rk3568|rk3566'; then
    print_status "Installing Mali driver for RK356X/RK3576..."
    apt-get install -y libmali-bifrost-g52-g13p0-x11-wayland-gbm
else
    print_warning "Unknown SoC type, installing RK3588 Mali driver by default..."
    apt-get install -y libmali-valhall-g610-g24p0-x11-wayland-gbm
fi

# 3. Apply configuration files (already done in previous steps)
print_status "Configuration files already applied:"
print_status "- /etc/modprobe.d/panfrost.conf (Panfrost blacklisted)"
print_status "- /etc/apt/preferences.d/mali (Mali repositories prioritized)"
print_status "- /etc/environment (Zink disabled, logging configured)"

# 4. Update initramfs to apply module blacklist
print_status "Updating initramfs..."
update-initramfs -u

# 5. Create log directory for kernel logging system
print_status "Creating kernel log directory..."
mkdir -p /var/log/kernel
chmod 755 /var/log/kernel

print_success "GPU driver switch configuration completed!"
print_status "Next steps:"
echo "1. Enable Mali GPU overlay (if using rsetup)"
echo "2. Reboot the system to load Mali driver"
echo "3. Verify with: lsmod | grep bifrost_kbase"
echo "4. Check Mali packages: apt list libmali-* --installed"

print_warning "Remember to reboot the system for changes to take effect!"
