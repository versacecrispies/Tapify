#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Checking for xcodegen..."
if ! command -v xcodegen &>/dev/null; then
    echo "==> xcodegen not found. Installing via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "ERROR: Homebrew not found. Install it from https://brew.sh then re-run this script."
        exit 1
    fi
    brew install xcodegen
fi

echo "==> Generating Xcode project..."
xcodegen generate

echo ""
echo "==> Done! Opening project in Xcode..."
open Tapify.xcodeproj

echo ""
echo "Next steps:"
echo "  1. In Xcode: Product > Build (Cmd+B)"
echo "  2. In Xcode: Product > Run  (Cmd+R)"
echo "  3. The app will appear in your menu bar (no Dock icon)"
echo "  4. Grant Screen Recording + Accessibility in System Settings > Privacy & Security when prompted"
