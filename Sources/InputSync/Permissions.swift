import ApplicationServices

struct PermissionSnapshot: Equatable {
    let accessibility: Bool
    let eventPosting: Bool
    var ready: Bool { accessibility && eventPosting }
    var title: String { accessibility ? L("permission.input.title") : L("permission.accessibility.title") }
    var detail: String { accessibility ? L("permission.input.detail") : L("permission.accessibility.detail") }
    static func read() -> PermissionSnapshot {
        PermissionSnapshot(accessibility: AXIsProcessTrusted(), eventPosting: CGPreflightPostEventAccess())
    }
}

