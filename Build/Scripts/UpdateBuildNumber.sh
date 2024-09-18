#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Change to the project's root directory
cd "$SRCROOT"

BUILD_NUMBER_XCCONFIG="$SRCROOT/Build/Configuration/BuildNumber.xcconfig"
echo $BUILD_NUMBER_XCCONFIG

mkdir -p "$(dirname "$BUILD_NUMBER_XCCONFIG")"

BUILD_NUMBER=$(git rev-list --count HEAD)
echo "CI_BUILD_NUMBER = $BUILD_NUMBER" > "$BUILD_NUMBER_XCCONFIG"
echo "CI_BUILD_NUMBER = $BUILD_NUMBER"
