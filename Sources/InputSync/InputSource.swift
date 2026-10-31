import AppKit
import ApplicationServices
import Carbon
import ServiceManagement

func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
    return value
}
func inputSource() -> String? {
    guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
          let value = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
    return Unmanaged<CFString>.fromOpaque(value).takeUnretainedValue() as String
}
struct Target {
    let pid: pid_t
    let window: AXUIElement
    let rect: CGRect
    func matches(_ other: Target) -> Bool {
        pid == other.pid && CFEqual(window, other.window) && rect == other.rect
    }
}
// Anchor inside the remote menu bar using the current shared-screen bounds.
// The upper edge stays inside the menu bar when the viewer is scaled.
func menuAnchor(in rect: CGRect) -> CGPoint {
    CGPoint(x: rect.minX + min(27, rect.width / 2), y: rect.minY + min(3, rect.height / 2))
}
func firstSharedScreen(in element: AXUIElement, depth: Int = 0) -> AXUIElement? {
    if attribute(element, kAXRoleAttribute) as? String == "AXSharedScreen" { return element }
    guard depth < 6 else { return nil }
    for child in attribute(element, kAXChildrenAttribute) as? [AXUIElement] ?? [] {
        if let screen = firstSharedScreen(in: child, depth: depth + 1) { return screen }
    }
    return nil
}
func target() -> Target? {
    guard let app = NSWorkspace.shared.frontmostApplication,
          app.bundleIdentifier == "com.apple.ScreenSharing" else { return nil }
    let ax = AXUIElementCreateApplication(app.processIdentifier)
    guard let raw = attribute(ax, kAXFocusedWindowAttribute), CFGetTypeID(raw) == AXUIElementGetTypeID() else { return nil }
    let window = raw as! AXUIElement
    guard let screen = firstSharedScreen(in: window),
          let p = attribute(screen, kAXPositionAttribute), let s = attribute(screen, kAXSizeAttribute),
          CFGetTypeID(p) == AXValueGetTypeID(), CFGetTypeID(s) == AXValueGetTypeID() else { return nil }
    var position = CGPoint.zero
    var size = CGSize.zero
    guard AXValueGetValue(p as! AXValue, .cgPoint, &position), AXValueGetValue(s as! AXValue, .cgSize, &size),
          size.width > 0, size.height > 0 else { return nil }
    return Target(pid: app.processIdentifier, window: window, rect: CGRect(origin: position, size: size))
}
func idle() -> Bool {
    let flags = CGEventSource.flagsState(.combinedSessionState)
    guard flags.intersection([.maskCommand, .maskControl, .maskAlternate, .maskShift]).isEmpty,
          !CGEventSource.buttonState(.combinedSessionState, button: .left),
          !CGEventSource.buttonState(.combinedSessionState, button: .right) else { return false }
    return [CGEventType.keyDown, .leftMouseDown, .rightMouseDown, .mouseMoved, .scrollWheel].allSatisfy {
        CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0) > 0.45
    }
}
func post(_ event: CGEvent) {
    event.flags = []
    event.setIntegerValueField(.eventSourceUserData, value: 0x494D4557414B45)
    event.post(tap: .cghidEventTap)
}

func inputSourceName() -> String? {
    guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
          let value = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) else { return nil }
    return Unmanaged<CFString>.fromOpaque(value).takeUnretainedValue() as String
}
