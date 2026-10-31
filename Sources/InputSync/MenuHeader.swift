import AppKit

// Auto Layout and wrapping keep longer translations readable without truncation.
final class MenuHeader: NSView {
    let stateLabel = NSTextField(wrappingLabelWithString: "")
    let detailLabel = NSTextField(wrappingLabelWithString: "")
    let stateIcon = NSImageView()
    let titleLabel = NSTextField(labelWithString: AppIdentity.name)
    override init(frame: NSRect) {
        super.init(frame: frame)
        let device = NSTextField(labelWithString: L("sharing.name"))
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        device.font = .systemFont(ofSize: 11)
        device.textColor = .secondaryLabelColor
        let heading = NSStackView(views: [titleLabel, device])
        heading.orientation = .vertical
        heading.alignment = .leading
        heading.spacing = 3
        stateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        stateIcon.contentTintColor = .secondaryLabelColor
        stateIcon.setAccessibilityElement(false)
        stateIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stateIcon.widthAnchor.constraint(equalToConstant: 15), stateIcon.heightAnchor.constraint(equalToConstant: 16)])
        let state = NSStackView(views: [stateIcon, stateLabel])
        state.orientation = .horizontal
        state.alignment = .top
        state.spacing = 7
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabelColor
        detailLabel.maximumNumberOfLines = 0
        stateLabel.maximumNumberOfLines = 0
        let stack = NSStackView(views: [heading, state, detailLabel])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            state.widthAnchor.constraint(equalTo: stack.widthAnchor),
            detailLabel.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(enabled: Bool, permission: PermissionSnapshot, detail: String) {
        stateLabel.stringValue = enabled ? L("state.enabled") : !permission.ready ? permission.title : L("state.paused")
        stateLabel.textColor = .labelColor
        let symbol = enabled ? "arrow.triangle.2.circlepath" : !permission.ready ? "lock" : "pause.circle"
        stateIcon.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        detailLabel.stringValue = permission.ready ? detail : permission.detail
        // NSMenu custom views need an explicit final size; use content fitting height.
        frame.size.width = 320
        layoutSubtreeIfNeeded()
        frame.size.height = max(122, fittingSize.height)
    }
}
