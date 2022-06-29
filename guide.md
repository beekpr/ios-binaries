# Setup

This article describes how to build binary dependencies for a new version of swift. You can check which version of swift corresponds to which xcode on https://swiftversion.net/.


## Setup
This project requires xcode, cocoapods and authenticated [github cli](https://cli.github.com/). To setup them, install the following script.

```bash
gem install cocoapods
brew install gh
git clone git@github.com:beekpr/ios-binaries.git
gh auth login
gh release list
```

## Generation
The generation process is fully automated. Before you start, ensure that you have installed xcode with swift version that you want to release
```
 xcrun swift -version
``` 

Let's say latest swift version is 6.9. To prepare and upload frameworks, run the following script. Once it's done, it should open browser on the created release.
```bash
cd FrameworkGenerator
./Scripts/build_and_release.sh swift-6.9
```

## Adding to ios-base
1. Copy the checksums (the descriptions in the release).
2. Make a file at ios-base/BeekeeperPackage/checksums-swift-6.9.txt and paste the copied checksums there.
3. We need to support at least two version of swift in the same codebase to have smooth transition in bitrise. To achieve this, modify Package.swift to use the correct tag conditionally:
```swift
#if swift(>=6.9)
    let swift = "swift-6.9-script"
#else
    let swift = "swift-6.8-script"
#endif
```
4. Check that it works (clean project & build the app) and push changes to ios-base.
5. Update Bitrise Development apps to use new Xcode version:
    - ios-base-app-builder https://app.bitrise.io/app/d0b8c20265643152/workflow_editor#!/stack
    - ios-base pull request builder https://app.bitrise.io/app/e3a89dc05347cd72/workflow_editor#!/stack
6. Later, before app-store release, update [bitrise-app-sync](https://github.com/beekpr/bitrise-app-sync/blob/2c43e3332117f29545f83b28f4cd9d59a83c86f2/modules/beekeeper_bitrise_settings.py#L16).