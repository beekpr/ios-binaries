# ios-binaries
A place to keep binary dependencies. Those binaries can by imported by [Swift Package Manager](https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages) or [CocoaPods](https://github.com/beekpr/ios-base/blob/develop/BeekeeperPackage/OpusCodec.podspec).

# Caution
Do not delete releases on this repository or binaries attached to those releases. This would break our CI builds.

## What are tags for?
Every new swift version requires new version of swift binaries, which is why we have separate tags like swift-5.7. Swift version is usually incremented with every new major release of Xcode.

In case of ObjC libraries, this is not needed, and we can keep them forever on `objc` tag.

## How to upload binaries
1. In one directory, prepare zipped xcframeworks that you want to upload
2. Calculate checksum file using this command:
```
find . -name "*.zip" -print0 | sort -z | xargs -r0 sha256sum > checksums-tag.txt
```
3. Create a release in github with a new tag (does not matter on which commit).
4. Rename checksums-tag to match the tag you picked. Example: checksums-swift-5.7.txt
5. Upload zipped frameworks and checksum file.
6. Add the checksums file to ios-base repository under BeekeeperPackage.
7. Use the new tag in Package.swift.

Note: checksums file is not required, but simplifies the process of migration to new version or adding new libraries.

## FrameworkGenerator

ios-base dependends on a number of obsolete libraries which do not support SPM. Because of that, we developed a workaround:
1. Have a dummy iOS project.
2. Added necessary pods to the project.
3. Wrote a script that generates xcframeworks for those projects.
4. Published those xcframeworks as a release.
```
cd FrameworkGenerator
sh Scripts/build/build_targets.sh
```

## Realm & RxSwift
We don't have to build those frameworks (althought we could, through FrameworkGenerator). They are built and uploaded to github by their own developers, but we have to repack them into our release workflow. They are providing multiple .xcframeworks packaged together, while we need to have every xcframework in a separate zip.
https://github.com/ReactiveX/RxSwift/releases
https://github.com/realm/realm-swift/releases

## Building ogg & opus

Those two libraries, written in C, are special.
See: https://github.com/beekpr/ios-AudioXCFrameworks

To generate ogg.xcframework and opus.xcframework, run these commands:
```
git clone git@github.com:sbooth/AudioXCFrameworks.git --recurse-submodules
cd AudioXCFrameworks/ogg
make
cd ../opus
make
```
