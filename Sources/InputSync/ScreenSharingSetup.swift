import AppKit
import ApplicationServices

extension AppDelegate {
    // This accesses the LOCAL Screen Sharing menu, never the remote desktop.
    func keyboardSyncMenuItem() -> AXUIElement? {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.ScreenSharing").first,
              let raw = attribute(AXUIElementCreateApplication(app.processIdentifier), kAXMenuBarAttribute),
              CFGetTypeID(raw) == AXUIElementGetTypeID() else { return nil }
        return findMenuItem(in: raw as! AXUIElement, titles: ScreenSharingMenus.syncTitles())
    }
    func findMenuItem(in element: AXUIElement, titles: Set<String>, depth: Int = 0) -> AXUIElement? {
        if let title = attribute(element, kAXTitleAttribute) as? String, titles.contains(title) { return element }
        guard depth < 5 else { return nil }
        for child in attribute(element, kAXChildrenAttribute) as? [AXUIElement] ?? [] {
            if let match = findMenuItem(in: child, titles: titles, depth: depth + 1) { return match }
        }
        return nil
    }
    func refreshKeyboardSyncState() {
        let on = permissions.accessibility ? keyboardSyncMenuItem().map(syncMarked) : nil
        keyboardSyncItem.title = L(on == true ? "setup.menu.enabled" : "setup.menu")
        keyboardSyncItem.state = on == true ? .on : .off
    }
    func syncMarked(_ item: AXUIElement) -> Bool {
        !(attribute(item, "AXMenuItemMarkChar") as? String ?? "").isEmpty
    }
    func setupResult(_ text: String) {
        setupMessage = text
        refreshKeyboardSyncState()
        update()
        log("SETUP " + text)
    }
    @objc func enableKeyboardSync() {
        generation += 1
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ScreenSharing") else {
            setupResult(L("setup.notFound"))
            return
        }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { [weak self] app, error in
            DispatchQueue.main.async {
                guard let self else { return }
                guard app != nil, error == nil else { self.setupResult(L("setup.openFailed")); return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.finishKeyboardSyncSetup() }
            }
        }
    }
    func finishKeyboardSyncSetup() {
        refreshPermissions()
        guard permissions.accessibility else {
            setupResult(L("setup.path"))
            showInformation(L("setup.title"), sections: [
                (L("setup.local.heading"), L("setup.local.body")),
                (L("setup.auto.heading"), L("setup.auto.body", AppIdentity.name))
            ])
            return
        }
        guard let option = keyboardSyncMenuItem(), attribute(option, kAXEnabledAttribute) as? Bool == true else {
            setupResult(L("setup.connect"))
            showInformation(L("setup.connect.title"), sections: [
                (L("setup.connect.heading"), L("setup.connect.body")),
                (L("setup.manual.heading"), L("setup.path"))
            ])
            return
        }
        if syncMarked(option) {
            setupResult(L("setup.enabled"))
            return
        }
        guard AXUIElementPerformAction(option, kAXPressAction as CFString) == .success else {
            setupResult(L("setup.enableManually"))
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self else { return }
            let on = self.keyboardSyncMenuItem().map { self.syncMarked($0) } ?? false
            self.setupResult(on ? L("setup.enabled") : L("setup.confirm"))
        }
    }
}
