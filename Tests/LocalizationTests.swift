import XCTest
@testable import InputSync

final class LocalizationTests: XCTestCase {
    func testEveryLanguageHasCompleteCompiledResources() throws {
        var referenceKeys: Set<String>?
        for language in L10n.languages {
            let path = try XCTUnwrap(Bundle.main.path(forResource: language, ofType: "lproj"))
            let bundle = try XCTUnwrap(Bundle(path: path))
            let url = try XCTUnwrap(bundle.url(forResource: "Localizable", withExtension: "strings"))
            let data = try Data(contentsOf: url)
            let values = try XCTUnwrap(try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String])
            if let keys = referenceKeys { XCTAssertEqual(Set(values.keys), keys, language) } else { referenceKeys = Set(values.keys) }
            XCTAssertGreaterThan(values.count, 70)
            for (key,value) in values { XCTAssertFalse(value.isEmpty, "\(language):\(key)"); XCTAssertNotEqual(key,value) }
            let name = AppIdentity.localizedName(in: bundle)
            XCTAssertFalse(name.isEmpty)
            XCTAssertFalse(L10n.text("menu.quit", arguments: [name], bundle: bundle).contains("%@"))
        }
    }
    func testNamesFollowLanguage() throws {
        for (language,name) in [("en","InputSync"), ("zh-Hans","输入法同步"), ("zh-Hant","輸入法同步")] {
            let path = try XCTUnwrap(Bundle.main.path(forResource: language, ofType: "lproj"))
            XCTAssertEqual(AppIdentity.localizedName(in: try XCTUnwrap(Bundle(path: path))), name)
        }
    }
    func testUnsupportedLanguageFallsBackToEnglish() {
        XCTAssertEqual(Bundle.preferredLocalizations(from: L10n.languages, forPreferences: ["sv"]), ["en"])
    }
}
