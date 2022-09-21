#!/bin/bash
set -e

TAG=$1
xcrun swift -version
echo "TAG: $TAG"
TARGET=Pods-Dummy-SwiftLibs
#TARGET=SomeDependency <- SomeDependency = eg Themes <- will build specific dependency
#TARGET=Pods-Dummy-SwiftLibs <- will build all dependencies of Swift target
#TARGET=Pods-Dummy-ObjectiveLibs <- will build all dependencies of Objective-C target

if [ -z "$TAG" ]
then
      echo "Tag not specified"
      exit 1
fi

if ! command -v gh &> /dev/null
then
    echo "Github Command line not found."
    echo "Run brew install gh && gh auth login (and then login properly)"
    exit 1
fi

# produce frameworks attached to Swift target in Podfile
./Scripts/build_xcframeworks.sh $TARGET

# create a github release
echo "Frameworks prepared. Uploading a new github release for $TAG"
cd Pods/Products-$TARGET || exit 1
FRAMEWORKS=$(find . -maxdepth 1 -name "*.xcframework.zip")
gh release create "$TAG" -F checksums-tag.txt $FRAMEWORKS
gh release list
open "https://github.com/beekpr/ios-binaries/releases/tag/$TAG"
