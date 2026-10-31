import AppKit
import ApplicationServices
import Carbon
import ServiceManagement
import Sparkle

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    lazy var updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    var automaticUpdatesItem: NSMenuItem!
    var item: NSStatusItem!
    var toggleItem: NSMenuItem!
    var header: MenuHeader!
    var delayItem: NSMenuItem!
    var keyboardSyncItem: NSMenuItem!
    var launchAtLoginItem: NSMenuItem!
    var setupMessage: String?
    var infoWindow: NSWindow?
    var permissions = PermissionSnapshot.read()
    var needsPermission: Bool { !permissions.ready }
    var enabled = false
    var generation = 0
    var previous = inputSource()
    var observers: [NSObjectProtocol] = []
    var loggedPermissions: PermissionSnapshot?
    var automaticStatusLabel: StatusLabel?
    var lastStatus = L("state.ready")
    var delay: Double = 0.5
    let logURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/InputSync/events.log")

    func applicationDidFinishLaunching(_ notification: Notification) {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return }
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        menu.delegate = self
        header = MenuHeader(frame: NSRect(x: 0, y: 0, width: 302, height: 108))
        let heading = NSMenuItem()
        heading.view = header
        menu.addItem(heading)
        menu.addItem(.separator())
        toggleItem = add(L("menu.enable"), #selector(toggle), to: menu)
        let delays = NSMenu()
        for (name, tag) in [(L("delay.default", L10n.number(0.5)), 500), (L("delay.seconds", L10n.number(1)), 1000), (L("delay.seconds", L10n.number(2.2)), 2200)] {
            let option = add(name, #selector(changeDelay(_:)), to: delays)
            option.tag = tag
            option.state = tag == 500 ? .on : .off
        }
        delayItem = NSMenuItem(title: L("delay.menu", L10n.number(0.5)), action: nil, keyEquivalent: "")
        delayItem.image = symbol("clock")
        delayItem.submenu = delays
        menu.addItem(delayItem)
        launchAtLoginItem = add(L("login.menu"), #selector(toggleLaunchAtLogin), to: menu)
        launchAtLoginItem.image = symbol("sunrise")
        menu.addItem(.separator())
        keyboardSyncItem = add(L("setup.menu"), #selector(enableKeyboardSync), to: menu)
        keyboardSyncItem.image = symbol("keyboard")
        add(L("menu.help"), #selector(help), to: menu).image = symbol("questionmark.circle")
        let checkUpdates = add(L("update.check"), #selector(SPUStandardUpdaterController.checkForUpdates(_:)), to: menu)
        checkUpdates.target = updaterController
        checkUpdates.image = symbol("arrow.down.circle")
        let details = NSMenu()
        automaticUpdatesItem = add(L("update.automatic"), #selector(toggleAutomaticUpdates), to: details)
        addStatusLabelMenu(to: details)
        details.addItem(.separator())
        add(L("menu.about", AppIdentity.name), #selector(about), to: details)
        add(L("menu.logs"), #selector(showLog), to: details)
        let more = NSMenuItem(title: L("menu.more"), action: nil, keyEquivalent: "")
        more.image = symbol("stethoscope")
        more.submenu = details
        menu.addItem(more)
        menu.addItem(.separator())
        add(L("menu.quit", AppIdentity.name), #selector(quit), to: menu).image = symbol("power")
        item.menu = menu
        updaterController.startUpdater()
        refreshPermissions()
        updateLoginItem()
        update()
        log("START paused; no remote events")
        log("LOGIN startup status=\(SMAppService.mainApp.status.rawValue)")
        // Common mode also updates the header while its menu remains open.
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            let previous = self.permissions
            self.refreshPermissions()
            if previous != self.permissions { self.update() }
        }
        RunLoop.main.add(timer, forMode: .common)
        observers.append(DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String), object: nil, queue: .main) { [weak self] _ in self?.changed() })
        observers.append(NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] _ in
            if NSWorkspace.shared.frontmostApplication?.bundleIdentifier != "com.apple.ScreenSharing" { self?.generation += 1 }
        })
    }
    @discardableResult func add(_ title: String, _ action: Selector, to menu: NSMenu) -> NSMenuItem {
        let entry = NSMenuItem(title: title, action: action, keyEquivalent: "")
        entry.target = self
        menu.addItem(entry)
        return entry
    }
    func symbol(_ name: String) -> NSImage? {
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 13, weight: .regular))
        image?.isTemplate = true
        return image
    }
    func refreshPermissions() {
        let latest = PermissionSnapshot.read()
        if latest != loggedPermissions {
            log("PERMISSION accessibility=\(latest.accessibility) eventPosting=\(latest.eventPosting)")
            loggedPermissions = latest
        }
        permissions = latest
        if enabled && !latest.ready {
            enabled = false
            generation += 1
            log("PAUSE permission unavailable")
        }
    }
    @objc func toggleAutomaticUpdates() {
        updaterController.updater.automaticallyChecksForUpdates.toggle()
    }
    func menuNeedsUpdate(_ menu: NSMenu) {
        automaticUpdatesItem.state = updaterController.updater.automaticallyChecksForUpdates ? .on : .off
        refreshPermissions()
        keyboardSyncItem.state = keyboardSyncMenuItem().map { syncMarked($0) ? .on : .off } ?? .off
        updateLoginItem()
        update(refreshAutomaticLabel: true)
    }
    func update(refreshAutomaticLabel: Bool = false) {
        updateStatusLabel(refreshAutomatic: refreshAutomaticLabel)
        let description = enabled ? L("status.enabled", AppIdentity.name) : L("status.paused", AppIdentity.name)
        item.button?.toolTip = description
        item.button?.setAccessibilityLabel(description)
        toggleItem.title = enabled ? L("menu.pause") : permissions.ready ? L("menu.enable") : permissions.accessibility ? L("permission.check.menu") : L("permission.open.menu")
        toggleItem.image = symbol(enabled ? "pause" : needsPermission ? "lock.open" : "play")
        delayItem.title = L("delay.menu", L10n.number(delay))
        header.configure(enabled: enabled, permission: permissions, detail: setupMessage ?? (enabled ? lastStatus : L("state.intro")))
    }
    func report(_ value: String) { setupMessage = nil; lastStatus = value; update(); log(value) }
    func log(_ value: String) {
        let line = "\(ISO8601DateFormatter().string(from: Date())) \(value)\n"
        try? FileManager.default.createDirectory(at: logURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        // Bound diagnostics; never record typed text or credentials.
        if let size = (try? FileManager.default.attributesOfItem(atPath: logURL.path)[.size]) as? NSNumber, size.intValue > 512_000 {
            try? Data().write(to: logURL)
        }
        if !FileManager.default.fileExists(atPath: logURL.path) { FileManager.default.createFile(atPath: logURL.path, contents: nil) }
        if let file = try? FileHandle(forWritingTo: logURL) {
            defer { try? file.close() }
            _ = try? file.seekToEnd()
            try? file.write(contentsOf: Data(line.utf8))
        }
    }
    @objc func toggle() {
        generation += 1
        if enabled { enabled = false; report(L("state.paused")); return }
        refreshPermissions()
        guard permissions.ready else {
            // Ask macOS for this running build, not an older entry with the same name.
            if !permissions.accessibility {
                _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
            }
            report(permissions.detail)
            let instruction = permissions.accessibility
                ? L("permission.input.body")
                : L("permission.accessibility.body", AppIdentity.name)
            showInformation(permissions.title, sections: [
                (permissions.accessibility ? L("permission.check.heading") : L("permission.allow.heading"), instruction),
                (L("permission.after.heading"), L("permission.after.body"))
            ])
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            return
        }
        previous = inputSource()
        enabled = true
        report(L("state.ready"))
    }
    @objc func changeDelay(_ sender: NSMenuItem) {
        generation += 1
        delay = Double(sender.tag) / 1000
        for option in sender.menu?.items ?? [] { option.state = option === sender ? .on : .off }
        log("DELAY \(delay)")
        update()
    }
    @objc func showLog() { NSWorkspace.shared.open(logURL) }
    @objc func quit() { enabled = false; generation += 1; log("QUIT paused"); NSApp.terminate(nil) }
}
