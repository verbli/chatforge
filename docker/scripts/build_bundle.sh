#!/bin/bash

source /build-scripts/common.sh
cd ${BASE_PATH}

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <version> <build_number>"
    exit 1
fi

VERSION="$1"
BUILD="$2"

notify - "Building Android Bundles (Version: $VERSION, Build: $BUILD)..."

# Create output directory
BUNDLE_OUTPUT_DIR="${OUTPUT_DIR}/android-bundle"
mkdir -p "$BUNDLE_OUTPUT_DIR"


# Build free version
echo "Building free version..."
flutter build appbundle \
    --flavor free \
    --release \
    --dart-define=ENABLE_ADS=true \
    --dart-define=IS_PRO=false \
    --dart-define=APP_VERSION="${VERSION}" \
    && notify 0 "[SUCCESS] Android Bundle Free build (Version: $VERSION, Build: $BUILD)" \
    || notify 1 "[FAILED ] Android Bundle Free build (Version: $VERSION, Build: $BUILD)"

# Copy free version to output directory
cp "build/app/outputs/bundle/freeRelease/app-free-release.aab" \
    "${BUNDLE_OUTPUT_DIR}/chatforge-free-${VERSION}-${BUILD}.aab"



# Build pro version
echo "Building pro version..."
flutter build appbundle \
    --flavor pro \
    --release \
    --dart-define=ENABLE_ADS=false \
    --dart-define=IS_PRO=true \
    --dart-define=APP_VERSION="${VERSION}" \
    && notify 0 "[SUCCESS] Android Bundle Free build (Version: $VERSION, Build: $BUILD)" \
    || notify 1 "[FAILED ] Android Bundle Free build (Version: $VERSION, Build: $BUILD)"

# Copy pro version to output directory
cp "build/app/outputs/bundle/proRelease/app-pro-release.aab" \
    "${BUNDLE_OUTPUT_DIR}/chatforge-pro-${VERSION}-${BUILD}.aab"



# Generate build info file
cat > "${BUNDLE_OUTPUT_DIR}/build-info.txt" << EOF
ChatForge Build Information
Version: ${VERSION}
Build Number: ${BUILD}
Build Date: $(date)

Free Version:
- Package: org.verbli.chatforge
- Filename: chatforge-free-${VERSION}-${BUILD}.aab
- Icon: ${FREE_ICON_PATH}
- Features:
  * Ads enabled
  * Local storage only
  * Basic features

Pro Version:
- Package: org.verbli.chatforge.pro
- Filename: chatforge-pro-${VERSION}-${BUILD}.aab
- Icon: ${PRO_ICON_PATH}
- Features:
  * Ad-free
  * Backend storage support
  * All features enabled
EOF

echo "Android Bundle build files are in $BUNDLE_OUTPUT_DIR"
