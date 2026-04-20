import Cocoa

enum ScrollZoomMode: Int {
    case off = 0
    case natural = 1      // scroll up = zoom in (macOS natural)
    case traditional = 2  // scroll down = zoom in (traditional mouse)
}

class ScrollZoomHandler {
    private static let keyPlus: Int64 = 0x18
    private static let keyMinus: Int64 = 0x1B

    /// Returns true if the event was consumed.
    func handleScroll(event: CGEvent) -> Bool {
        guard event.flags.contains(.maskControl),
              !event.flags.contains(.maskCommand)
        else { return false }

        let delta = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
        guard delta != 0 else { return false }

        let mode = ScrollZoomMode(
            rawValue: UserDefaults.standard.integer(forKey: "scrollZoomMode")
        ) ?? .off
        guard mode != .off else { return false }

        let zoomIn = mode == .natural ? delta > 0 : delta < 0
        KeyboardUtils.postKey(
            zoomIn ? Self.keyPlus : Self.keyMinus,
            flags: .maskCommand
        )
        return true
    }
}
