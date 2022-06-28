set -e

TAG=$1
xcrun swift -version
echo "TAG: $TAG"
read -p "Check that tag matches your installed swift version and press enter."

if ! command -v gh &> /dev/null
then
    echo "Github Command line not found."
    echo "Run brew install gh && gh auth login (and then login properly)"
    exit
fi

# produce frameworks attached to Swift target in Podfile
./Scripts/build_xcframeworks.sh Pods-Dummy-Swift

# create a github release
cd Pods/Products-Pods-Dummy-Swift || exit -1
FRAMEWORKS=$(find . -maxdepth 1 -name "*.xcframework.zip")
gh release create $TAG -F checksums-tag.txt $FRAMEWORKS