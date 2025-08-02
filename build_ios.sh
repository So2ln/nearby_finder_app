#!/bin/bash

# iOS Build Script to prevent concurrent build issues
# Usage: ./build_ios.sh [debug|release]

set -e

BUILD_MODE=${1:-debug}

echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔧 Setting environment variables to prevent concurrent builds..."
export RUN_CLANG_STATIC_ANALYZER=0
export DISABLE_MANUAL_TARGET_ORDER_BUILD_WARNING=YES
export ENABLE_PARALLEL_BUILDING=NO

echo "🍎 Building iOS app in $BUILD_MODE mode..."
if [ "$BUILD_MODE" = "release" ]; then
    flutter build ios --release --no-codesign
else
    flutter build ios --debug --no-codesign
fi

echo "✅ Build completed successfully!"
