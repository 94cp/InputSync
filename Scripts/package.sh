#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"

# Build a universal Release app without replacing the locally installed copy.
./build.sh ONLY_ACTIVE_ARCH=NO 'ARCHS=arm64 x86_64'
app_path="build/Build/Products/Release/InputSync.app"
/usr/bin/codesign --verify --deep --strict "$app_path"
architectures=$(/usr/bin/lipo -archs "$app_path/Contents/MacOS/InputSync")
[[ "$architectures" == *arm64* && "$architectures" == *x86_64* ]]
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_path/Contents/Info.plist")
output_dir="$PWD/dist/releases"
mkdir -p "$output_dir"
package_tmp=$(mktemp -d "${TMPDIR:-/tmp}/inputsync-package.XXXXXX")
trap 'rm -rf "$package_tmp"' EXIT

# Drag-and-drop installer: app plus a shortcut to Applications.
dmg_name="InputSync-${version}-macOS-universal.dmg"
mkdir -p "$package_tmp/dmg"
/usr/bin/ditto "$app_path" "$package_tmp/dmg/InputSync.app"
ln -s /Applications "$package_tmp/dmg/Applications"
/usr/bin/hdiutil create -volname InputSync -srcfolder "$package_tmp/dmg" -format UDZO -ov "$package_tmp/$dmg_name"
/usr/bin/hdiutil verify "$package_tmp/$dmg_name"
mv "$package_tmp/$dmg_name" "$output_dir/$dmg_name"
(cd "$output_dir" && /usr/bin/shasum -a 256 "$dmg_name" > "$dmg_name.sha256")
# Sparkle reads a signed feed from the latest GitHub Release.
mkdir -p "$package_tmp/updates"
ln "$output_dir/$dmg_name" "$package_tmp/updates/$dmg_name"
"build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast" \
    --account com.cp.inputsync --maximum-deltas 0 \
    --download-url-prefix "https://github.com/94cp/InputSync/releases/download/v${version}/" \
    --link "https://github.com/94cp/InputSync" \
    "$package_tmp/updates"
cp "$package_tmp/updates/appcast.xml" "$output_dir/appcast.xml"
print "Package: $output_dir/$dmg_name"
print "Update feed: $output_dir/appcast.xml"
