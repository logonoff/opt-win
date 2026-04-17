import Cocoa

/* Note: terminal apps are skipped by this class since CGEvents can't inject into
   a PTY. For Terminal.app, configure Home/End manually.

   Run in the terminal, then restart Terminal.app:

# Terminal.app: map Home/End to escape sequences
PROFILE=$(defaults read com.apple.Terminal "Default Window Settings")
/usr/libexec/PlistBuddy \
  -c "Add ':Window Settings:${PROFILE}:keyMapBoundKeys:F729' string '\033[H'" \
  -c "Add ':Window Settings:${PROFILE}:keyMapBoundKeys:F72B' string '\033[F'" \
  ~/Library/Preferences/com.apple.Terminal.plist 2>/dev/null || \
/usr/libexec/PlistBuddy \
  -c "Set ':Window Settings:${PROFILE}:keyMapBoundKeys:F729' '\033[H'" \
  -c "Set ':Window Settings:${PROFILE}:keyMapBoundKeys:F72B' '\033[F'" \
  ~/Library/Preferences/com.apple.Terminal.plist

# zsh: bind the escape sequences to cursor movement
grep -q 'beginning-of-line' ~/.zshrc 2>/dev/null || printf '\n# Home/End\nbindkey "\\e[H" beginning-of-line\nbindkey "\\e[F" end-of-line\n' >> ~/.zshrc && source ~/.zshrc
*/

class HomeEndHandler {
    private static let keyHome: Int64 = 0x73
    private static let keyEnd: Int64 = 0x77
    private static let keyLeft: Int64 = 0x7B
    private static let keyRight: Int64 = 0x7C

    // Terminal apps handle Home/End via their own keyboard settings, not CGEvents
    private static let terminalBundleIDs: Set<String> = [
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "io.alacritty",
        "com.mitchellh.ghostty",
        "net.kovidgoyal.kitty",
        "co.zeit.hyper",
        "dev.warp.Warp-Stable",
    ]

    /// Attempts to handle a keyDown event. Returns true if the event was consumed.
    func handleKeyDown(event: CGEvent) -> Bool {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        guard keyCode == HomeEndHandler.keyHome || keyCode == HomeEndHandler.keyEnd else {
            return false
        }

        // Skip terminals — they need to handle Home/End via their own keyboard config
        if let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
           HomeEndHandler.terminalBundleIDs.contains(bundleID)
        {
            return false
        }

        guard isFocusedOnTextField() else { return false }

        let isHome = keyCode == HomeEndHandler.keyHome
        let arrowKey = isHome ? HomeEndHandler.keyLeft : HomeEndHandler.keyRight
        // Preserve Shift for selection (Shift+Home/End → Shift+Cmd+Left/Right)
        var newFlags = event.flags
        newFlags.insert(.maskCommand)
        postKey(arrowKey, flags: newFlags)
        return true
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

    private func isFocusedOnTextField() -> Bool {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard result == .success, let element = focusedElement else { return false }

        var roleValue: AnyObject?
        AXUIElementCopyAttributeValue(element as! AXUIElement, kAXRoleAttribute as CFString, &roleValue)
        guard let role = roleValue as? String else { return false }

        let textRoles: Set<String> = [
            kAXTextFieldRole, kAXTextAreaRole, kAXComboBoxRole, "AXSearchField",
        ]
        return textRoles.contains(role)
    }
}
