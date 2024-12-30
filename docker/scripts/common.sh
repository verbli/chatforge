#!/bin/bash

# Exit on error
set -e

# Default version values
BASE_PATH=/app

# Common settings
MAJOR="1"
MINOR="0"
PATCH="0"
BUILD="1"
VERSION="${MAJOR}.${MINOR}.${PATCH}"
OUTPUT_DIR="${BASE_PATH}/dist/${VERSION}"
FREE_ICON_PATH="${BASE_PATH}/assets/icon/icon.png"
PRO_ICON_PATH="${BASE_PATH}/assets/icon/icon_pro.png"

# Notify helper function
notify() {
    EC="$1"
    MSG="$2"

    if [[ "$EC" == "0" ]]; then
        /usr/local/bin/gotify push "[SUCCESS] $MSG" 2>/dev/null
        ffplay -autoexit /build-assets/success.wav 2>/dev/null
    elif [[ "$EC" == "-" ]]; then
        /usr/local/bin/gotify push "$MSG" 2>/dev/null
    else
        /usr/local/bin/gotify push "[FAILED/$EC] $MSG" 2>/dev/null
        ffplay -autoexit /build-assets/failure.wav 2>/dev/null
    fi

    echo "$MSG"
}

# Clean build directories
clean_build() {
    echo "Cleaning build environment..."

    cd ${BASE_PATH}
    flutter clean
    rm -rf \
        lib/data/models.freezed.dart \
        lib/data/models.g.dart \
        lib/core/config.g.dart \
        lib/core/config.freezed.dart
    cd android
    ./gradlew clean
    cd ..
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs

}


# Function to generate icons for a flavor
generate_icons() {
    local flavor=$1
    local icon_path=$2
    local mipmap_dir="${BASE_PATH}/android/app/src/${flavor}/res"

    # Create necessary directories
    mkdir -p "${mipmap_dir}/mipmap-hdpi"
    mkdir -p "${mipmap_dir}/mipmap-mdpi"
    mkdir -p "${mipmap_dir}/mipmap-xhdpi"
    mkdir -p "${mipmap_dir}/mipmap-xxhdpi"
    mkdir -p "${mipmap_dir}/mipmap-xxxhdpi"

    # Generate different sizes
    convert "$icon_path" -resize 72x72 "${mipmap_dir}/mipmap-hdpi/launcher_icon.png"
    convert "$icon_path" -resize 48x48 "${mipmap_dir}/mipmap-mdpi/launcher_icon.png"
    convert "$icon_path" -resize 96x96 "${mipmap_dir}/mipmap-xhdpi/launcher_icon.png"
    convert "$icon_path" -resize 144x144 "${mipmap_dir}/mipmap-xxhdpi/launcher_icon.png"
    convert "$icon_path" -resize 192x192 "${mipmap_dir}/mipmap-xxxhdpi/launcher_icon.png"

    # Generate adaptive icons if needed
    if [ -f "android/app/src/${flavor}/res/mipmap-anydpi-v26/launcher_icon.xml" ]; then
        convert "$icon_path" -resize 432x432 "${mipmap_dir}/mipmap-xxxhdpi/ic_launcher_foreground.png"
        convert "$icon_path" -resize 324x324 "${mipmap_dir}/mipmap-xxhdpi/ic_launcher_foreground.png"
        convert "$icon_path" -resize 216x216 "${mipmap_dir}/mipmap-xhdpi/ic_launcher_foreground.png"
        convert "$icon_path" -resize 162x162 "${mipmap_dir}/mipmap-hdpi/ic_launcher_foreground.png"
        convert "$icon_path" -resize 108x108 "${mipmap_dir}/mipmap-mdpi/ic_launcher_foreground.png"
    fi
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
