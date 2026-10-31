import AppKit

// System menu language can differ from this app's language. Match all available
// system translations, using the installed Screen Sharing resources when present.
enum ScreenSharingMenus {
    static let fallbackTitles: Set<String> = [
        "Sync Keyboard Language", "Synchronize Keyboard Language",
        "同步键盘语言", "同步鍵盤語言", "キーボードの言語を同期", "키보드 언어 동기화",
        "Tastatursprache synchronisieren", "Synchroniser la langue de clavier",
        "Sincronizar idioma del teclado"
    ]
    static func syncTitles() -> Set<String> { cachedTitles }
    private static let cachedTitles: Set<String> = {
        var result = fallbackTitles
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ScreenSharing"),
              let bundle = Bundle(url: url),
              let tableURL = bundle.url(forResource: "MainMenu", withExtension: "loctable"),
              let data = try? Data(contentsOf: tableURL),
              let table = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: [String: String]] else { return result }
        // Discover the entry by its English value, not an OS-version-specific nib ID.
        let keys = Set(table.values.flatMap { entries in entries.compactMap { key, value in
            ["Sync Keyboard Language", "Synchronize Keyboard Language"].contains(value) ? key : nil
        } })
        for entries in table.values {
            for key in keys { if let value = entries[key] { result.insert(value) } }
        }
        return result
    }()
}
