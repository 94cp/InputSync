import AppKit
import ApplicationServices
import Carbon
import ServiceManagement

extension AppDelegate {
    func updateLoginItem() {
        let status = SMAppService.mainApp.status
        launchAtLoginItem.state = status == .enabled ? .on : status == .requiresApproval ? .mixed : .off
        launchAtLoginItem.title = status == .requiresApproval ? L("login.approval.menu") : L("login.menu")
    }
    @objc func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            switch service.status {
            case .enabled:
                try service.unregister()
            case .requiresApproval:
                break
            case .notRegistered, .notFound:
                try service.register()
            @unknown default:
                SMAppService.openSystemSettingsLoginItems()
            }
            updateLoginItem()
            switch service.status {
            case .enabled: setupResult(L("login.enabled"))
            case .requiresApproval:
                setupResult(L("login.approval", AppIdentity.name))
                SMAppService.openSystemSettingsLoginItems()
            case .notRegistered: setupResult(L("login.disabled"))
            default: setupResult(L("login.unavailable"))
            }
            log("LOGIN updated status=\(service.status.rawValue)")
        } catch {
            updateLoginItem()
            setupResult(L("login.error"))
            log("LOGIN error=\(error.localizedDescription)")
        }
    }
}
