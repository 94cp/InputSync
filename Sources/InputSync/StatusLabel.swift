import AppKit
import Carbon
import IOKit

enum StatusLabel: String, CaseIterable {
    case automatic, globe, chinese, capsLock, japanese, korean
    var title: String {
        switch self {
        case .automatic: return L("label.automatic")
        case .globe: return L("label.globe")
        case .chinese: return "中/英"
        case .capsLock: return "Caps Lock"
        case .japanese: return "英数 / かな"
        case .korean: return "한/영"
        }
    }
    var imageName: String? {
        switch self { case .globe: return "globe"; case .capsLock: return "capslock"; default: return nil }
    }
}

enum KeyboardLabelDetection {
    static func suggested(layouts: [Int], region: String?) -> StatusLabel {
        let hardware = resolve(layouts: layouts)
        if hardware != .globe { return hardware }
        switch region?.uppercased() {
        case "CN", "TW", "HK", "MO": return .chinese
        case "JP": return .japanese
        case "KR": return .korean
        default: return .globe
        }
    }
    // Unknown or conflicting hardware metadata must not imply a keycap language.
    static func resolve(layouts: [Int]) -> StatusLabel {
        guard let first = layouts.first, layouts.allSatisfy({ $0 == first }) else { return .globe }
        switch first {
        case 5: return .japanese // HID physical layout 106 (JIS)
        case 2: return .korean   // HID physical layout 103
        default: return .globe
        }
    }
    static func read() -> StatusLabel {
        var iterator: io_iterator_t = 0
        let region = Locale.current.region?.identifier
        guard IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOHIDDevice"), &iterator) == KERN_SUCCESS else { return suggested(layouts: [], region: region) }
        defer { IOObjectRelease(iterator) }
        var layouts: [Int] = []
        while case let device = IOIteratorNext(iterator), device != 0 {
            defer { IOObjectRelease(device) }
            func number(_ key: String) -> Int? {
                (IORegistryEntryCreateCFProperty(device, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? NSNumber)?.intValue
            }
            guard number("PrimaryUsagePage") == 1, number("PrimaryUsage") == 6 else { continue }
            layouts.append(number("HIDKeyboardLayoutValue") ?? 0)
        }
        // Carbon can identify JIS when a single keyboard omits the HID layout property.
        if layouts == [0], KBGetLayoutType(Int16(LMGetKbdType())) == kKeyboardJIS { return .japanese }
        return suggested(layouts: layouts, region: region)
    }
}
extension AppDelegate {
    func addStatusLabelMenu(to parent: NSMenu) {
        let menu = NSMenu()
        for choice in StatusLabel.allCases {
            let item = add(choice.title, #selector(changeStatusLabel(_:)), to: menu)
            item.representedObject = choice.rawValue
            item.state = choice == selectedStatusLabel ? .on : .off
        }
        let item = NSMenuItem(title: L("label.menu"), action: nil, keyEquivalent: "")
        item.submenu = menu
        parent.addItem(item)
    }
    var selectedStatusLabel: StatusLabel {
        StatusLabel(rawValue: UserDefaults.standard.string(forKey: "statusLabel") ?? "automatic") ?? .automatic
    }
    @objc func changeStatusLabel(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String, StatusLabel(rawValue: value) != nil else { return }
        UserDefaults.standard.set(value, forKey: "statusLabel")
        for option in sender.menu?.items ?? [] { option.state = option === sender ? .on : .off }
        updateStatusLabel(refreshAutomatic: true)
    }
    func updateStatusLabel(refreshAutomatic: Bool = false) {
        if selectedStatusLabel == .automatic && (refreshAutomatic || automaticStatusLabel == nil) {
            automaticStatusLabel = KeyboardLabelDetection.read()
        }
        let choice = selectedStatusLabel == .automatic ? (automaticStatusLabel ?? .globe) : selectedStatusLabel
        item.button?.title = choice.imageName == nil ? choice.title : ""
        let stateImage = symbol(enabled ? "arrow.triangle.2.circlepath" : "pause.circle")
        if let keyImage = choice.imageName.flatMap({ symbol($0) }) {
            let image = NSImage(size: NSSize(width: 34, height: 16), flipped: false) { _ in
                stateImage?.draw(in: NSRect(x: 0, y: 1, width: 14, height: 14))
                keyImage.draw(in: NSRect(x: 19, y: 1, width: 15, height: 14))
                return true
            }
            image.isTemplate = true
            item.button?.image = image
            item.button?.imagePosition = .imageOnly
        } else {
            item.button?.image = stateImage
            item.button?.imagePosition = .imageLeading
        }
    }
}
