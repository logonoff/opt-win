import Cocoa

@MainActor
class OptionKeyHandler {
    var onSinglePress: (() -> Void)?
    var onDoublePress: (() -> Void)?

    private var optionIsDown = false
    private var otherInputDetected = false
    private var lastCleanOptionUpTime: TimeInterval = 0
    private var singlePressWorkItem: DispatchWorkItem?

    private let doublePressThreshold: TimeInterval = 0.3

    func handleFlagsChanged(event: CGEvent) {
        let flags = event.flags
        let optionCurrentlyDown = flags.contains(.maskAlternate)
        let hasOtherModifiers =
            flags.contains(.maskCommand)
            || flags.contains(.maskControl)
            || flags.contains(.maskShift)

        if optionCurrentlyDown && !optionIsDown {
            optionIsDown = true
            otherInputDetected = hasOtherModifiers

        } else if !optionCurrentlyDown && optionIsDown {
            optionIsDown = false

            if !otherInputDetected && !hasOtherModifiers {
                handleCleanOptionRelease()
            }

        } else if optionIsDown && hasOtherModifiers {
            otherInputDetected = true
        }
    }

    func markOtherInput() {
        if optionIsDown { otherInputDetected = true }
    }

    private func handleCleanOptionRelease() {
        let now = ProcessInfo.processInfo.systemUptime

        singlePressWorkItem?.cancel()
        singlePressWorkItem = nil

        if now - lastCleanOptionUpTime < doublePressThreshold {
            lastCleanOptionUpTime = 0
            onDoublePress?()
        } else {
            lastCleanOptionUpTime = now
            let work = DispatchWorkItem { [weak self] in
                MainActor.assumeIsolated { self?.onSinglePress?() }
            }
            singlePressWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + doublePressThreshold, execute: work)
        }
    }
}
