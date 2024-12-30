#!/bin/bash

source /build-scripts/common.sh
cd ${BASE_PATH}

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <version> <build_number>"
    exit 1
fi

VERSION="$1"
BUILD="$2"

notify - "Building Web Pro version (Version: $VERSION, Build: $BUILD)..."

# Build Web Pro version
flutter build web \
    --release \
    --dart-define=IS_PRO=true \
    --dart-define=ENABLE_ADS=false \
    --dart-define=APP_VERSION="$VERSION" \
    --build-number="$BUILD" \
    && notify 0 "[SUCCESS] Web Pro build (Version: $VERSION, Build: $BUILD)" \
    || notify 1 "[FAILED ] Web Pro build (Version: $VERSION, Build: $BUILD)"

# Copy the build outputs
WEB_OUTPUT_DIR="$OUTPUT_DIR/web"
mkdir -p "$WEB_OUTPUT_DIR"
cp -r build/web/* "$WEB_OUTPUT_DIR/"

# Generate build info file
cat > "${WEB_OUTPUT_DIR}/build-info.txt" << EOF
ChatForge Build Information
Version: ${VERSION}
Build Number: ${BUILD}
Build Date: $(date)
EOF

echo "Web Pro build files are in $WEB_OUTPUT_DIR"
