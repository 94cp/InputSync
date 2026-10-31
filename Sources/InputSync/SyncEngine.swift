import AppKit
import ApplicationServices

extension AppDelegate {
    func changed() {
        guard let source = inputSource(), source != previous else { return }
        previous = source
        generation += 1
        let token = generation
        guard enabled else { return }
        guard let initial = target() else { report(L("state.waiting")); return }
        log("SCHEDULE \(source) delay=\(delay)")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, self.enabled, self.generation == token else { return }
            self.wake(initial, source: source)
        }
    }
    func wake(_ initial: Target, source: String) {
        guard enabled, AXIsProcessTrusted(), CGPreflightPostEventAccess(),
              let current = target(), initial.matches(current), inputSource() == source, idle() else {
            report(L("state.skipped"))
            return
        }
        let oldPointer = CGEvent(source: nil)!.location
        let menuPoint = menuAnchor(in: current.rect)
        // Refresh through the remote menu bar, positioned from this window.
        for type: CGEventType in [.mouseMoved, .leftMouseDown, .leftMouseUp] {
            post(CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: menuPoint, mouseButton: .left)!)
            usleep(40000)
        }
        usleep(200000)
        guard let after = target(), current.matches(after), inputSource() == source,
              CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .keyDown) > 0.35,
              CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .leftMouseDown) > 0.2 else {
            report(L("state.cancelled"))
            return
        }
        for down in [true, false] {
            post(CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: down)!)
            usleep(40000)
        }
        let pointer = CGEvent(source: nil)!.location
        if hypot(pointer.x - menuPoint.x, pointer.y - menuPoint.y) < 2 {
            post(CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: oldPointer, mouseButton: .left)!)
        }
        report(L("state.sent", inputSourceName() ?? source))
    }
}
