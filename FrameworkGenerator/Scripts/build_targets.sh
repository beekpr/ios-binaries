#!/bin/bash
set -e

while read -r p; do 
    echo "Building $p"
    sh Scripts/build_xcframework.sh "$p"
done < "Scripts/targets.txt"