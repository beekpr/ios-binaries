cd Pods/Products-Pods-Dummy-Swift || exit
FRAMEWORKS=$(find . -maxdepth 1 -name "*.xcframework.zip")
gh release create $1 -F checksums-tag.txt $FRAMEWORKS