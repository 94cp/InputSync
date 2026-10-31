import AppKit
import ApplicationServices
import Carbon
import ServiceManagement

extension AppDelegate {
    @objc func help() {
        showInformation(L("help.title", AppIdentity.name), sections: [
            (L("help.prepare.heading"), L("help.prepare.body")),
            (L("menu.enable"), L("help.enable.body")),
            (L("help.key.heading"), L("help.key.body")),
            (L("help.login.heading"), L("help.login.body"))
        ])
    }
    @objc func about() {
        showInformation(L("menu.about", AppIdentity.name), sections: [
            (L("about.purpose.heading"), L("about.purpose.body")),
            (L("about.window.heading"), L("about.window.body")),
            (L("about.behavior.heading"), L("about.behavior.body"))
        ])
    }
}
