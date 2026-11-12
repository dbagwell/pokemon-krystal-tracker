#!/bin/sh

version_number=$(sed -n 's/.*"package_version": "\(.*\)".*/\1/p' manifest.json)
zip -r pokemon-krystal-tracker-"$version_number".zip . -x "*.DS_Store" -x "__MACOSX" -x "*.sh" -x "*.zip" -x ".*" -x "versions.json"