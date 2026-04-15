#!/bin/bash
set -e

APP_NAME="OptWin"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."

mkdir -p "$BUILD_DIR"

swiftc Sources/*.swift \
    -o "$BUILD_DIR/$APP_NAME" \
    -framework Cocoa \
    -O

mkdir -p "$APP_BUNDLE/Contents/MacOS"
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"
cp Info.plist "$APP_BUNDLE/Contents/"

codesign --force --sign - "$APP_BUNDLE"

echo "Build complete: $APP_BUNDLE"
echo ""
echo "To run:    open $APP_BUNDLE"
echo "To install: cp -r $APP_BUNDLE /Applications/"
echo ""
echo "NOTE: Grant Accessibility permissions in"
echo "  System Settings -> Privacy & Security -> Accessibility"
