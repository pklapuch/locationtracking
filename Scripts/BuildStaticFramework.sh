#!/bin/sh

# IMPORTANT:
# Always execute this script from /Scripts directory!

NAME="LocaationTracker"
LIB_NAME="lib$NAME"

# remove existing build artefacts
rm -rf  derived_data "$NAME.framework"

echo "build simulator library"
xcodebuild \
    -project "$NAME.xcodeproj" \
    -scheme $NAME \
    -derivedDataPath derived_data \
    -arch x86_64 \
    -sdk iphonesimulator BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "build device library"
xcodebuild \
    -project "$NAME.xcodeproj" \
    -scheme $NAME \
    -derivedDataPath derived_data \
    -arch arm64 \
    -sdk iphoneos BUILD_LIBRARY_FOR_DISTRIBUTION=YES
    
FRAMEWORK_DIR="$NAME.framework"
echo "create directory at (relative): $FRAMEWORK_DIR"
mkdir $FRAMEWORK_DIR

SWIFT_MODULE_DIR="$NAME.swiftmodule"
echo "create swfit module directory at (relative): $FRAMEWORK_DIR/$SWIFT_MODULE_DIR"
mkdir "$FRAMEWORK_DIR/$SWIFT_MODULE_DIR"

echo "combine simulator + device libraries"
lipo -create  \
    derived_data/Build/Products/Debug-iphoneos/$LIB_NAME.a \
    derived_data/Build/Products/Debug-iphonesimulator/$LIB_NAME.a \
    -o $NAME.framework/$NAME

cp -r derived_data/Build/Products/*/*.swiftmodule/* $FRAMEWORK_DIR/$SWIFT_MODULE_DIR
