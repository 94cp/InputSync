import XCTest
import AppKit
@testable import InputSync

final class CoreTests: XCTestCase {
    func testAutomaticLabelRequiresUnambiguousHardware() {
        XCTAssertEqual(KeyboardLabelDetection.resolve(layouts: [5]), .japanese)
        XCTAssertEqual(KeyboardLabelDetection.resolve(layouts: [2]), .korean)
        for layouts in [[], [0], [1], [3], [5, 2], [5, 0]] {
            XCTAssertEqual(KeyboardLabelDetection.resolve(layouts: layouts), .globe)
        }
    }
    func testRegionSuggestsDefaultWithoutOverridingKnownHardware() {
        for region in ["CN", "TW", "HK", "MO"] {
            XCTAssertEqual(KeyboardLabelDetection.suggested(layouts: [0], region: region), .chinese)
        }
        XCTAssertEqual(KeyboardLabelDetection.suggested(layouts: [], region: "JP"), .japanese)
        XCTAssertEqual(KeyboardLabelDetection.suggested(layouts: [], region: "KR"), .korean)
        XCTAssertEqual(KeyboardLabelDetection.suggested(layouts: [], region: "US"), .globe)
        XCTAssertEqual(KeyboardLabelDetection.suggested(layouts: [], region: nil), .globe)
        XCTAssertEqual(KeyboardLabelDetection.suggested(layouts: [5], region: "CN"), .japanese)
    }
    func testAnchorFollowsWindowAcrossDisplaysAndSizes() {
        for rect in [CGRect(x: 38, y: 85, width: 1435, height: 807), CGRect(x: -1600, y: 40, width: 1200, height: 900), CGRect(x: 300, y: 100, width: 800, height: 500), CGRect(x: 0, y: 0, width: 2560, height: 1440)] {
            let anchor = menuAnchor(in: rect)
            XCTAssertTrue(rect.contains(anchor))
            let moved = menuAnchor(in: rect.offsetBy(dx: 91, dy: 37))
            XCTAssertEqual(moved, CGPoint(x: anchor.x + 91, y: anchor.y + 37))
        }
    }
    func testGrantedAccessibilityIsNotReportedAsMissing() {
        let partial = PermissionSnapshot(accessibility: true, eventPosting: false)
        XCTAssertFalse(partial.ready)
        XCTAssertEqual(partial.title, L("permission.input.title"))
        XCTAssertTrue(PermissionSnapshot(accessibility: true, eventPosting: true).ready)
    }
    func testHeaderClearsPermissionMessageAfterGrant() {
        let header = MenuHeader(frame: NSRect(x: 0, y: 0, width: 320, height: 122))
        header.configure(enabled: false, permission: .init(accessibility: false, eventPosting: false), detail: L("state.intro"))
        XCTAssertEqual(header.stateLabel.stringValue, L("permission.accessibility.title"))
        header.configure(enabled: false, permission: .init(accessibility: true, eventPosting: true), detail: L("state.intro"))
        XCTAssertEqual(header.stateLabel.stringValue, L("state.paused"))
        XCTAssertEqual(header.detailLabel.stringValue, L("state.intro"))
        header.configure(enabled: false, permission: .init(accessibility: true, eventPosting: false), detail: L("state.intro"))
        XCTAssertEqual(header.stateLabel.stringValue, L("permission.input.title"))
    }
    func testSystemMenuMatchesAcrossLanguages() {
        let titles = ScreenSharingMenus.syncTitles()
        for text in ["Sync Keyboard Language", "同步键盘语言", "キーボードの言語を同期", "키보드 언어 동기화", "Tastatursprache synchronisieren"] { XCTAssertTrue(titles.contains(text)) }
    }
    func testNumberFormattingUsesLocale() {
        XCTAssertEqual(L10n.number(0.5, locale: Locale(identifier: "de")), "0,5")
        XCTAssertEqual(L10n.number(0.5, locale: Locale(identifier: "en")), "0.5")
    }
    func testKeyLabelsAreIndependentOfApplicationLanguage() {
        XCTAssertEqual(StatusLabel.chinese.title, "中/英")
        XCTAssertEqual(StatusLabel.japanese.title, "英数 / かな")
        XCTAssertEqual(StatusLabel.globe.imageName, "globe")
    }
}
