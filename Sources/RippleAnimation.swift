import Cocoa
import QuartzCore

/// Ripple animation ported from GNOME Shell js/ui/ripples.js and _corner-ripple.scss.
/// Three concentric quarter-circle ripples expand from the top-left corner of a screen.
class RippleAnimation {
    private var activeWindows: [NSWindow] = []

    // GNOME's parameters:
    //                    delay   duration  startScale  startOpacity  finalScale
    private let ripples: [(CFTimeInterval, CFTimeInterval, CGFloat, Float, CGFloat)] = [
        (0.0,   0.83,  0.25, 1.0,  1.5),
        (0.05,  1.0,   0.0,  0.7,  1.25),
        (0.35,  1.0,   0.0,  0.3,  1.0),
    ]

    func play(onScreen screen: NSScreen) {
        let rippleSize: CGFloat = 52
        let windowSize: CGFloat = ceil(rippleSize * 1.5) + 2

        let windowFrame = NSRect(
            x: screen.frame.minX,
            y: screen.frame.maxY - windowSize,
            width: windowSize,
            height: windowSize
        )

        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.ignoresMouseEvents = true
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        let view = NSView(frame: NSRect(origin: .zero, size: windowFrame.size))
        view.wantsLayer = true
        window.contentView = view

        guard let rootLayer = view.layer else { return }

        // Quarter-circle path matching GNOME's border-radius style
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: rippleSize))
        path.addLine(to: CGPoint(x: rippleSize, y: rippleSize))
        path.addArc(
            center: CGPoint(x: 0, y: rippleSize),
            radius: rippleSize,
            startAngle: 0,
            endAngle: -.pi / 2,
            clockwise: true
        )
        path.closeSubpath()

        let now = CACurrentMediaTime()

        for (delay, duration, startScale, startOpacity, finalScale) in ripples {
            let layer = CAShapeLayer()
            layer.path = path
            layer.fillColor = NSColor(white: 1.0, alpha: 0.25).cgColor
            layer.bounds = CGRect(x: 0, y: 0, width: rippleSize, height: rippleSize)
            layer.anchorPoint = CGPoint(x: 0, y: 1)
            layer.position = CGPoint(x: 0, y: windowSize)
            layer.opacity = 0

            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = startScale
            scaleAnim.toValue = finalScale
            scaleAnim.duration = duration
            scaleAnim.beginTime = now + delay
            scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            scaleAnim.fillMode = .both
            scaleAnim.isRemovedOnCompletion = false

            let opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = sqrt(startOpacity)
            opacityAnim.toValue = 0
            opacityAnim.duration = duration
            opacityAnim.beginTime = now + delay
            opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
            opacityAnim.fillMode = .both
            opacityAnim.isRemovedOnCompletion = false

            rootLayer.addSublayer(layer)
            layer.add(scaleAnim, forKey: "scale")
            layer.add(opacityAnim, forKey: "opacity")
        }

        window.orderFrontRegardless()
        activeWindows.append(window)

        let maxDuration = ripples.map { $0.0 + $0.1 }.max() ?? 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration + 0.1) { [weak self] in
            window.orderOut(nil)
            self?.activeWindows.removeAll { $0 === window }
        }
    }
}
