#!/bin/bash

source ./common.sh

# Check for required arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <version> [targets...]"
    echo "Example: $0 1.0.0 linux web"
    exit 1
fi

VERSION="$1"
TARGETS=${@:2}  # Remaining arguments are the targets

ICONS_BUILT=false

# Default to "all" if no specific targets are provided
if [[ -z "$TARGETS" ]]; then
    TARGETS="all"
fi

# Path to the build number file
BUILD_NUMBER_FILE="build_number.txt"

# Initialize the build number file if it doesn't exist
if [[ ! -f $BUILD_NUMBER_FILE ]]; then
    echo "1" > "$BUILD_NUMBER_FILE"
fi

# Read the current build number
BUILD=$(cat "$BUILD_NUMBER_FILE")

# Increment the build number
NEW_BUILD=$((BUILD + 1))
echo "$NEW_BUILD" > "$BUILD_NUMBER_FILE"

echo "Version: $VERSION"
echo "Build number: $BUILD"

notify - "Building (${TARGETS}) releases (Version: $VERSION, Build: $BUILD)..."

# Check for specific targets and run corresponding scripts
if [[ "$TARGETS" == *"clean"* || "$TARGETS" == "all" ]]; then
    echo "Cleaning build environment..."
    ./clean.sh
fi

if [[ "$TARGETS" == *"linux"* || "$TARGETS" == "all" ]]; then
    echo "Building Linux release..."
    ./build_linux.sh "$VERSION" "$BUILD"
fi

if [[ "$TARGETS" == *"android-apk"* || "$TARGETS" == "all" ]]; then
    echo "Building Android APKs..."

    # Generate icons for each flavor
    echo "Generating icons for free version..."
    generate_icons "free" "$FREE_ICON_PATH"

    echo "Generating icons for pro version..."
    generate_icons "pro" "$PRO_ICON_PATH"

    ./build_apk.sh "$VERSION" "$BUILD"
fi

if [[ "$TARGETS" == *"android-bundle"* || "$TARGETS" == "all" ]]; then
    echo "Building Android App Bundles..."

    if ! $ICONS_BUILT; then
        # Generate icons for each flavor
        echo "Generating icons for free version..."
        generate_icons "free" "$FREE_ICON_PATH"

        echo "Generating icons for pro version..."
        generate_icons "pro" "$PRO_ICON_PATH"
    fi

    ./build_bundle.sh "$VERSION" "$BUILD"
fi

if [[ "$TARGETS" == *"web"* || "$TARGETS" == "all" ]]; then
    echo "Building Web release..."
    ./build_web.sh "$VERSION" "$BUILD"
fi

echo "Build process completed!"
