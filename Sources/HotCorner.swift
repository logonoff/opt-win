import Cocoa

class HotCorner {
    var onTrigger: ((NSScreen) -> Void)?
    var enabled: Bool = true

    private var triggered = false
    private let zone: CGFloat = 2

    func handleMouseMoved(event: CGEvent) {
        guard enabled else { return }

        let pos = event.location

        if let screen = screenAtTopLeftCorner(pos) {
            if !triggered {
                triggered = true
                onTrigger?(screen)
            }
        } else {
            triggered = false
        }
    }

    private func screenAtTopLeftCorner(_ point: CGPoint) -> NSScreen? {
        guard let primaryHeight = NSScreen.screens.first?.frame.height else { return nil }

        for screen in NSScreen.screens {
            let frame = screen.frame
            let cornerX = frame.origin.x
            let cornerY = primaryHeight - frame.origin.y - frame.height

            if point.x >= cornerX && point.x < cornerX + zone
                && point.y >= cornerY && point.y < cornerY + zone
            {
                return screen
            }
        }
        return nil
    }
}
