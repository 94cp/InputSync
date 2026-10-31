# Development

Users install the DMG from GitHub Releases; building from source is optional.

## Build and test

Requires Xcode and its macOS SDK. The deployment target is macOS 13. Xcode resolves Sparkle 2.10.1 through Swift Package Manager.

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

Creates a universal Intel/Apple silicon DMG, SHA-256 checksum and signed Sparkle `appcast.xml` in `dist/releases/`. The script verifies the app signature and disk image. It does not replace the locally installed app.

## Updates

Sparkle handles checking, downloading, installation and relaunch. Automatic checks default to on; users can turn them off under Settings. Installation requires confirmation. The feed points to `https://github.com/94cp/InputSync/releases/latest/download/appcast.xml`; it becomes accessible to users once the repository is public.

The update signing key is stored in the macOS login Keychain under account `com.cp.inputsync`. Its public key is in `Config/Info.plist`. Back up the private key securely; do not commit it. On another release machine, import the same key with Sparkle’s `generate_keys` tool. Generating a different key will break updates for existing installations.

For each release:

1. Increase `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in both build configurations.
2. Run `./Scripts/package.sh` on the signing machine.
3. Upload the DMG, checksum and `appcast.xml` together to a GitHub Release tagged `v<MARKETING_VERSION>` and mark it as the latest release. Prefer uploading to a draft before publishing. Do not change the DMG after signing.

Version 0.7.0 has no updater and needs one manual upgrade. Keep the bundle identifier and app filename unchanged. Ad-hoc signed updates may require granting Accessibility permission again.

Sparkle’s license and bundled third-party notices are included in `Resources/ThirdPartyNotices.txt` and copied into the app.

## Localization

Edit `Resources/Localizable.xcstrings` and `Resources/InfoPlist.xcstrings` in Xcode. Preserve format placeholders and run the localization check above.
