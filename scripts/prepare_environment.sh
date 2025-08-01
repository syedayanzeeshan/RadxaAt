#!/bin/bash

# Exit on error
set -e

# Configuration
IMAGE_URL="https://github.com/Joshua-Riek/ubuntu-rockchip/releases/download/v2.4.0/ubuntu-22.04-preinstalled-desktop-arm64-rock-5b-plus.img.xz"
IMAGE_NAME="ubuntu-22.04-preinstalled-desktop-arm64-rock-5b-plus.img.xz"
EXTRACTED_IMAGE="ubuntu-22.04-preinstalled-desktop-arm64-rock-5b-plus.img"
MOUNT_POINT="/mnt/rock5b_image"
KERNEL_SRC_DIR="linux"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo_error "Please run as root"
    exit 1
fi

# Create working directory
WORK_DIR=$(pwd)
mkdir -p "$WORK_DIR/build"
cd "$WORK_DIR/build"

# Download image if not exists
if [ ! -f "$IMAGE_NAME" ]; then
    echo "Downloading Ubuntu image..."
    wget "$IMAGE_URL" -O "$IMAGE_NAME"
    echo_success "Image downloaded successfully"
fi

# Extract image if not already extracted
if [ ! -f "$EXTRACTED_IMAGE" ]; then
    echo "Extracting image..."
    xz -d -k "$IMAGE_NAME"
    echo_success "Image extracted successfully"
fi

# Setup mount point
mkdir -p "$MOUNT_POINT"

# Get partition information
PARTITION_INFO=$(fdisk -l "$EXTRACTED_IMAGE")
SECTOR_SIZE=$(echo "$PARTITION_INFO" | grep "Sector size" | awk '{print $4}')
# Look for the first partition (should be the main partition)
ROOT_PART_START=$(echo "$PARTITION_INFO" | grep "${EXTRACTED_IMAGE}1" | awk '{print $2}')

# Calculate offset
OFFSET=$((ROOT_PART_START * SECTOR_SIZE))

# Debug output
echo "Debug: Sector size: $SECTOR_SIZE"
echo "Debug: Root partition start: $ROOT_PART_START"
echo "Debug: Calculated offset: $OFFSET"

# Check if already mounted and unmount if necessary
if mountpoint -q "$MOUNT_POINT"; then
    echo "Image already mounted, unmounting first..."
    umount "$MOUNT_POINT"
fi

# Mount image
echo "Mounting image..."
mount -o loop,offset=$OFFSET "$EXTRACTED_IMAGE" "$MOUNT_POINT"
echo_success "Image mounted at $MOUNT_POINT"

# Setup cross-compilation environment
echo "Setting up build environment..."

# Install required packages
apt-get update
apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    build-essential \
    flex \
    bison \
    libssl-dev \
    libelf-dev \
    bc \
    kmod \
    libncurses-dev \
    pkg-config

# Clone kernel source if not already present
if [ ! -d "$KERNEL_SRC_DIR" ]; then
    echo "Cloning kernel source..."
    git clone --depth 1 https://github.com/Joshua-Riek/linux-rockchip.git "$KERNEL_SRC_DIR"
    cd "$KERNEL_SRC_DIR"
    # The repository now uses 'noble' as the main branch instead of 'rk3588'
    echo "Using branch: $(git branch --show-current)"
    echo_success "Kernel source cloned successfully"
    # Return to build directory
    cd ..
fi

# Setup kernel build configuration
cd "$KERNEL_SRC_DIR"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
# Note: menuconfig is interactive, skip for automated builds
# Run 'make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig' manually if needed
echo "Kernel configuration set to default (defconfig)"

echo_success "Build environment setup complete"
echo "You can now proceed with kernel modifications"
echo "Kernel source is available at: $WORK_DIR/build/$KERNEL_SRC_DIR"
echo "Image is mounted at: $MOUNT_POINT"