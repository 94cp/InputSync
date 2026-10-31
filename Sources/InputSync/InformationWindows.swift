import AppKit

extension AppDelegate {
    func showInformation(_ title: String, sections: [(String, String)]) {
        infoWindow?.close()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 370), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = title
        window.isReleasedWhenClosed = false
        let scroll = NSScrollView(frame: window.contentView!.bounds)
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        let text = NSTextView(frame: scroll.bounds)
        text.isEditable = false
        text.isSelectable = true
        text.drawsBackground = false
        text.textContainerInset = NSSize(width: 24, height: 22)
        text.autoresizingMask = [.width]
        text.textContainer?.widthTracksTextView = true
        let body = NSMutableAttributedString()
        for (heading, content) in sections {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 4
            paragraph.paragraphSpacing = 16
            body.append(NSAttributedString(string: heading + "\n", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: NSColor.labelColor]))
            let contentStart = body.length
            body.append(NSAttributedString(string: content + "\n", attributes: [.font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.labelColor, .paragraphStyle: paragraph]))
            if content.hasPrefix("https://"), let url = URL(string: content) {
                body.addAttribute(.link, value: url, range: NSRange(location: contentStart, length: (content as NSString).length))
            }
        }
        text.textStorage?.setAttributedString(body)
        scroll.documentView = text
        window.contentView?.addSubview(scroll)
        infoWindow = window
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
