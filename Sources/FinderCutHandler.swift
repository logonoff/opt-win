import Cocoa

class FinderCutHandler {
    private var cutPending = false

    private static let keyC: Int64 = 0x08
    private static let keyV: Int64 = 0x09
    private static let keyX: Int64 = 0x07

    /// Returns true if the event was consumed.
    func handleKeyDown(event: CGEvent) -> Bool {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        guard flags.contains(.maskControl),
              !flags.contains(.maskAlternate),
              !flags.contains(.maskShift),
              !flags.contains(.maskCommand),
              Self.isFinderApp(),
              !Self.isFocusedOnTextField()
        else {
            return false
        }

        // Ctrl+X: copy to clipboard and mark for move
        if keyCode == Self.keyX {
            var newFlags = flags
            newFlags.remove(.maskControl)
            newFlags.insert(.maskCommand)
            postKey(Self.keyC, flags: newFlags)
            cutPending = true
            return true
        }

        // Ctrl+V after cut: move instead of duplicate
        if keyCode == Self.keyV && cutPending {
            var newFlags = flags
            newFlags.remove(.maskControl)
            newFlags.insert([.maskCommand, .maskAlternate])
            postKey(Self.keyV, flags: newFlags)
            cutPending = false
            return true
        }

        // Ctrl+C cancels pending cut
        if keyCode == Self.keyC {
            cutPending = false
        }

        return false
    }

    private func postKey(_ keyCode: Int64, flags: CGEventFlags) {
        let src = CGEventSource(stateID: .hidSystemState)
        guard let down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode), keyDown: true),
              let up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode), keyDown: false)
        else { return }
        down.flags = flags
        up.flags = flags
        down.post(tap: .cgSessionEventTap)
        up.post(tap: .cgSessionEventTap)
    }

    private static func isFinderApp() -> Bool {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.finder"
    }

    private static func isFocusedOnTextField() -> Bool {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard result == .success,
              let element = focusedElement,
              CFGetTypeID(element) == AXUIElementGetTypeID()
        else { return false }

        let axElement = element as! AXUIElement
        var roleValue: AnyObject?
        AXUIElementCopyAttributeValue(axElement, kAXRoleAttribute as CFString, &roleValue)
        guard let role = roleValue as? String else { return false }

        let textRoles: Set<String> = [
            kAXTextFieldRole, kAXTextAreaRole, kAXComboBoxRole, "AXSearchField",
        ]
        return textRoles.contains(role)
    }
}
