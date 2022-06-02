#!/bin/sh
# this script lets you compile dependency in Pods into xcframework that can be imported by SPM
set -e

cd Pods

SCHEME="$1"
FRAMEWORK_NAME="$1"

BUILD_DIR="Build"
TMP_DIR="${BUILD_DIR}/Tmp"
IOS_ARCHIVE_PATH="${TMP_DIR}/iOS.xcarchive"
IOS_SIM_ARCHIVE_PATH="${TMP_DIR}/iOSSimulator.xcarchive"

rm -rf ${BUILD_DIR}
rm -rf "${FRAMEWORK_NAME}.xcframework"

xcodebuild archive \
 -scheme ${SCHEME} \
 -archivePath ${IOS_SIM_ARCHIVE_PATH} \
 -sdk iphonesimulator \
 SKIP_INSTALL=NO ENABLE_BITCODE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty



 xcodebuild archive \
 -scheme ${SCHEME} \
 -archivePath ${IOS_ARCHIVE_PATH} \
 -sdk iphoneos \
 SKIP_INSTALL=NO ENABLE_BITCODE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty



SWIFT_HEADER="${IOS_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework/Headers/${FRAMEWORK_NAME}-Swift.h"
if [ -f "$SWIFT_HEADER" ]; then
    OUTPUT="Products/Swift"
else 
    OUTPUT="Products/ObjectiveC"
fi

 xcodebuild -create-xcframework \
 -framework ${IOS_SIM_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
 -framework ${IOS_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework \
 -output ${OUTPUT}/${FRAMEWORK_NAME}.xcframework \
 | xcpretty

zip -r ${OUTPUT}/${FRAMEWORK_NAME}.xcframework.zip ${OUTPUT}/${FRAMEWORK_NAME}.xcframework

rm -rf ${BUILD_DIR}