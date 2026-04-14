import Cocoa

// MARK: - Event Tap Callback (free function required for C interop)

func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
    let app = Unmanaged<OptWinApp>.fromOpaque(userInfo).takeUnretainedValue()

    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = app.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }

    app.handleEvent(type: type, event: event)
    return Unmanaged.passUnretained(event)
}

// MARK: - App

class OptWinApp: NSObject, NSApplicationDelegate {
    var eventTap: CFMachPort?
    private var statusItem: NSStatusItem!

    // Option key tracking state
    private var optionIsDown = false
    private var otherInputDetected = false
    private var lastCleanOptionUpTime: TimeInterval = 0
    private var singlePressWorkItem: DispatchWorkItem?

    private let doublePressThreshold: TimeInterval = 0.3

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()

        if !setupEventTap() {
            showAccessibilityAlert()
        }
    }

    // MARK: - Status Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "⌥"
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit OptWin", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Event Tap Setup

    private func setupEventTap() -> Bool {
        let mask: CGEventMask =
            (1 << CGEventType.flagsChanged.rawValue)
            | (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.leftMouseDown.rawValue)
            | (1 << CGEventType.rightMouseDown.rawValue)
            | (1 << CGEventType.otherMouseDown.rawValue)

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: eventTapCallback,
            userInfo: selfPtr
        ) else {
            return false
        }

        self.eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
            OptWin needs Accessibility access to detect key presses.

            Please grant access in:
            System Settings → Privacy & Security → Accessibility
            """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Event Handling

    func handleEvent(type: CGEventType, event: CGEvent) {
        switch type {
        case .flagsChanged:
            handleFlagsChanged(event: event)
        case .keyDown:
            if optionIsDown { otherInputDetected = true }
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            if optionIsDown { otherInputDetected = true }
        default:
            break
        }
    }

    private func handleFlagsChanged(event: CGEvent) {
        let flags = event.flags
        let optionCurrentlyDown = flags.contains(.maskAlternate)
        let hasOtherModifiers =
            flags.contains(.maskCommand)
            || flags.contains(.maskControl)
            || flags.contains(.maskShift)

        if optionCurrentlyDown && !optionIsDown {
            // Option just pressed down
            optionIsDown = true
            otherInputDetected = hasOtherModifiers

        } else if !optionCurrentlyDown && optionIsDown {
            // Option just released
            optionIsDown = false

            if !otherInputDetected && !hasOtherModifiers {
                handleCleanOptionRelease()
            }

        } else if optionIsDown && hasOtherModifiers {
            // Another modifier changed while Option is held
            otherInputDetected = true
        }
    }

    // MARK: - Press Detection

    private func handleCleanOptionRelease() {
        let now = ProcessInfo.processInfo.systemUptime

        singlePressWorkItem?.cancel()
        singlePressWorkItem = nil

        if now - lastCleanOptionUpTime < doublePressThreshold {
            // Double press detected
            lastCleanOptionUpTime = 0
            triggerSpotlight()
        } else {
            // Wait for possible double press
            lastCleanOptionUpTime = now
            let work = DispatchWorkItem { [weak self] in
                self?.triggerMissionControl()
            }
            singlePressWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + doublePressThreshold, execute: work)
        }
    }

    // MARK: - Actions

    private func triggerMissionControl() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "Mission Control"]
        try? task.run()
    }

    private func triggerSpotlight() {
        let src = CGEventSource(stateID: .hidSystemState)

        guard let down = CGEvent(keyboardEventSource: src, virtualKey: 0x31, keyDown: true),
              let up = CGEvent(keyboardEventSource: src, virtualKey: 0x31, keyDown: false)
        else { return }

        down.flags = .maskCommand
        up.flags = .maskCommand

        down.post(tap: .cgSessionEventTap)
        up.post(tap: .cgSessionEventTap)
    }
}

// MARK: - Entry Point

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = OptWinApp()
app.delegate = delegate
app.run()
