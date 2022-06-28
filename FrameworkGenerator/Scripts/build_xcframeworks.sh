#!/bin/bash
# This script will build depdencies specified in Podfile and prepares zipped frameworks

# ./Scripts/build_xcframeworks.sh Pods-Dummy-Swift
# ./Scripts/build_xcframeworks.sh Pods-Dummy-ObjC

set -e

pod install
cd Pods

SCHEME="$1"
FRAMEWORK_NAME="$1"

BUILD_DIR="Build-$SCHEME"
TMP_DIR="${BUILD_DIR}/Tmp"
IOS_ARCHIVE_PATH="${TMP_DIR}/iOS.xcarchive"
IOS_SIM_ARCHIVE_PATH="${TMP_DIR}/iOSSimulator.xcarchive"
OUTPUT="Products-$SCHEME"

rm -rf ${BUILD_DIR}
rm -rf  $OUTPUT

 xcodebuild archive \
 -scheme "${SCHEME}" \
 -archivePath ${IOS_ARCHIVE_PATH} \
 -sdk iphoneos \
 SKIP_INSTALL=NO | xcpretty

xcodebuild archive \
 -scheme "${SCHEME}" \
 -archivePath ${IOS_SIM_ARCHIVE_PATH} \
 -sdk iphonesimulator \
 SKIP_INSTALL=NO | xcpretty

create_xcframework() {
    FRAMEWORK_NAME=$(basename -- "$1")
    FRAMEWORK_NAME="${FRAMEWORK_NAME%.*}"

    if [[ $FRAMEWORK_NAME == Pods* ]]; then
        # Skip Pods-SwiftFrameworks.framework and others like it
        return
    fi

    xcodebuild -create-xcframework -allow-internal-distribution \
    -framework "${IOS_SIM_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${IOS_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${OUTPUT}/${FRAMEWORK_NAME}.xcframework" \
    | xcpretty

    zip -r "${OUTPUT}/${FRAMEWORK_NAME}.xcframework.zip" "${OUTPUT}/${FRAMEWORK_NAME}.xcframework"
}

find ${IOS_ARCHIVE_PATH}/Products/Library/Frameworks -maxdepth 1 -name "*.framework" | while read -r file; do
    create_xcframework "$file"
done

cd $OUTPUT
find . -name "*.zip" -print0 | sort -z | xargs -r0 shasum -a 256 > checksums-tag.txt