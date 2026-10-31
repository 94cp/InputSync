import Foundation

enum L10n {
    static let languages = ["en", "zh-Hans", "zh-Hant", "ja", "ko", "de", "fr", "es"]
    static func text(_ key: String, arguments: [CVarArg] = [], bundle: Bundle = .main, locale: Locale = .current) -> String {
        let format = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
        return arguments.isEmpty ? format : String(format: format, locale: locale, arguments: arguments)
    }
    static func number(_ value: Double, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
func L(_ key: String, _ arguments: CVarArg...) -> String {
    L10n.text(key, arguments: arguments)
}
enum AppIdentity {
    static var name: String { localizedName(in: .main) }
    static func localizedName(in bundle: Bundle) -> String {
        bundle.localizedString(forKey: "CFBundleDisplayName", value: "InputSync", table: "InfoPlist")
    }
}
