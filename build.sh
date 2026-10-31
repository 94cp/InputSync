#!/bin/zsh
set -eu
cd "${0:A:h}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
xcodebuild -project InputSync.xcodeproj -scheme InputSync -configuration Release -derivedDataPath build "$@" build
