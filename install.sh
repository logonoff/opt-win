#!/bin/bash
set -e

APP_NAME="OptWin"
APP_BUNDLE="build/$APP_NAME.app"
INSTALL_DIR="/Applications"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "App not built yet. Building..."
    ./build.sh
fi

echo "Installing $APP_NAME to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR/$APP_NAME.app"
mv "$APP_BUNDLE" "$INSTALL_DIR/"
echo "Done. You can launch $APP_NAME from Applications."

if [ "$1" = "--run" ]; then
    open "$INSTALL_DIR/$APP_NAME.app"
fi
