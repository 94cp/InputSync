# Development

Users install the DMG from GitHub Releases; building from source is optional.

## Build and test

Requires Xcode and its macOS SDK. The deployment target is macOS 13. No third-party packages are required.

Open `InputSync.xcodeproj`, select the `InputSync` scheme, then Run. Or run from the repository root:

```sh
./build.sh
./Scripts/test.sh
python3 Scripts/check_localizations.py
```

The scripts default to `/Applications/Xcode.app`; override `DEVELOPER_DIR` if needed. The Release app is generated at `build/Build/Products/Release/InputSync.app`.

## Package

```sh
./Scripts/package.sh
```

Creates a universal Intel/Apple silicon DMG and a SHA-256 checksum in `dist/releases/`. The script verifies the app signature and disk image. Upload the DMG and checksum to a GitHub Release. It does not replace the locally installed app.

## Localization

Edit `Resources/Localizable.xcstrings` and `Resources/InfoPlist.xcstrings` in Xcode. Preserve format placeholders and run the localization check above.
