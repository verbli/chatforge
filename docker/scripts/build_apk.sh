#!/bin/bash

source /build-scripts/common.sh
cd ${BASE_PATH}

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <version> <build_number>"
    exit 1
fi

VERSION="$1"
BUILD="$2"

notify - "Building Android APKs (Version: $VERSION, Build: $BUILD)..."

# Create output directory
APK_OUTPUT_DIR="${OUTPUT_DIR}/android-apk"
mkdir -p "$APK_OUTPUT_DIR"


# Build free version
echo "Building free version..."
flutter build apk \
    --flavor free \
    --release \
    --dart-define=ENABLE_ADS=true \
    --dart-define=IS_PRO=false \
    --dart-define=APP_VERSION="${VERSION}" \
    --build-number="$BUILD" \
     && notify 0 "[SUCCESS] Android APK Free build (Version: $VERSION, Build: $BUILD)" \
     || notify 1 "[FAILED ] Android APK Free build (Version: $VERSION, Build: $BUILD)"

# Copy free version to output directory
cp "build/app/outputs/flutter-apk/app-free-release.apk" \
    "${APK_OUTPUT_DIR}/chatforge-free-${VERSION}-${BUILD}.apk"


# Build pro version
echo "Building pro version..."
flutter build apk \
    --flavor pro \
    --release \
    --dart-define=ENABLE_ADS=false \
    --dart-define=IS_PRO=true \
    --dart-define=APP_VERSION="${VERSION}" \
    --build-number="$BUILD" \
    && notify 0 "[SUCCESS] Android APK Pro build (Version: $VERSION, Build: $BUILD)" \
    || notify 1 "[FAILED ] Android APK Pro build (Version: $VERSION, Build: $BUILD)"

# Copy pro version to output directory
cp "build/app/outputs/flutter-apk/app-pro-release.apk" \
    "${APK_OUTPUT_DIR}/chatforge-pro-${VERSION}-${BUILD}.apk"



# Generate build info file
cat > "${APK_OUTPUT_DIR}/build-info.txt" << EOF
ChatForge Build Information
Version: ${VERSION}
Build Number: ${BUILD}
Build Date: $(date)

Free Version:
- Package: org.verbli.chatforge
- Filename: chatforge-free-${VERSION}-${BUILD}.aab
- Icon: ${FREE_ICON_PATH}

Pro Version:
- Package: org.verbli.chatforge.pro
- Filename: chatforge-pro-${VERSION}-${BUILD}.aab
- Icon: ${PRO_ICON_PATH}
EOF

echo "Android APK build files are in $APK_OUTPUT_DIR"
