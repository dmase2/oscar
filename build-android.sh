#!/bin/bash

# Build script for Android APK without deprecated x86 targets
# This avoids the "Support for Android x86 targets will be removed" warning

echo "Building Android APK (Debug)..."
flutter build apk --debug --no-shrink --target-platform android-arm,android-arm64

echo ""
echo "Building Android APK (Release)..."
flutter build apk --release --target-platform android-arm,android-arm64

echo ""
echo "Android APK builds completed!"
echo "Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
echo "Release APK: build/app/outputs/flutter-apk/app-release.apk"
