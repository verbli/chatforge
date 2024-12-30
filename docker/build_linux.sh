#!/bin/bash

source ./common.sh

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <version> <build_number>"
    exit 1
fi

VERSION="$1"
BUILD="$2"

notify - "Building Linux Pro version (Version: $VERSION, Build: $BUILD)..."

# Build Linux Pro version
flutter build linux \
    --release \
    --dart-define=IS_PRO=true \
    --dart-define=ENABLE_ADS=false \
    --dart-define=APP_VERSION="$VERSION" \
    --build-number="$BUILD" \
    && notify 0 "[SUCCESS] Linux Pro build (Version: $VERSION, Build: $BUILD)" \
    || notify 1 "[FAILED ] Linux Pro build (Version: $VERSION, Build: $BUILD)"

# Copy the build outputs
LINUX_OUTPUT_DIR="$OUTPUT_DIR/linux"
mkdir -p "$LINUX_OUTPUT_DIR"
cp -r build/linux/release/bundle/* "$LINUX_OUTPUT_DIR/"

# Generate build info file
cat > "${LINUX_OUTPUT_DIR}/build-info.txt" << EOF
ChatForge Build Information
Version: ${VERSION}
Build Number: ${BUILD}
Build Date: $(date)
EOF

echo "Linux Pro build files are in $LINUX_OUTPUT_DIR"
