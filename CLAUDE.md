# OptWin

A macOS menu bar app that repurposes the Option key and adds GNOME-style hot corners.

**Keep this file up to date.** When adding features, changing architecture, or learning new project conventions, update the relevant sections below so future sessions have full context.

## Features

- **Single press `⌥`** → Opens Mission Control
- **Double press `⌥`** → Opens Spotlight (simulates Cmd+Space)
- **Hot corner** → Slamming mouse to top-left corner of any screen opens Mission Control with a GNOME-style ripple animation
- All three features can be individually toggled on/off via the status bar menu (persisted via UserDefaults, all enabled by default)
- **Request Permissions** menu item — checks Accessibility (`AXIsProcessTrusted`) and Input Monitoring (event tap exists), offers buttons to open each settings pane directly
- Option key detection happens on key-up so existing keyboard shortcuts are unaffected

## Architecture

Single-target Swift app compiled with `swiftc` (no Xcode project, no SPM). All sources are in `Sources/`.

| File | Purpose |
|---|---|
| `main.swift` | Entry point — creates NSApplication, sets `.accessory` policy, runs the app |
| `AppDelegate.swift` | Status bar menu, CGEventTap setup, event routing, action triggers (Mission Control / Spotlight). Contains the free `eventTapCallback` function (required for C interop). |
| `OptionKeyHandler.swift` | Tracks Option key state via `flagsChanged` events. Detects clean single/double presses using a timer. Exposes `onSinglePress` / `onDoublePress` closures. |
| `HotCorner.swift` | Monitors `mouseMoved` events and detects when cursor hits the top-left corner (2px zone) of any screen. Exposes `onTrigger(NSScreen)` closure. Handles CGEvent↔NSScreen coordinate conversion. |
| `RippleAnimation.swift` | Ported from GNOME Shell `js/ui/ripples.js`. Three concentric quarter-circle CAShapeLayer ripples with staggered scale/opacity animations. Displays in a borderless transparent window. |

## Build & Install

```bash
./build.sh        # compiles Sources/*.swift → build/OptWin.app
./install.sh      # moves to /Applications (builds first if needed)
./install.sh --run # install and launch
```

No Xcode project — just `swiftc` with `-framework Cocoa`. Build script at `build.sh`.

## Key Implementation Details

- **Event tap**: Listen-only (`CGEventTapOptions.listenOnly`) on `cgSessionEventTap`. Monitors: `flagsChanged`, `keyDown`, mouse down events, `mouseMoved`. Re-enables itself on `tapDisabledByTimeout`.
- **Option key "clean press"**: A press is dirty (ignored) if any other key, mouse button, or modifier is used while Option is held. This prevents triggering on Opt+Tab, Cmd+Opt, Opt+Click, etc.
- **Double press timing**: 300ms threshold between two clean Option releases.
- **Spotlight trigger**: Posts synthetic Cmd+Space CGEvents (virtual key 0x31).
- **Mission Control trigger**: Runs `/usr/bin/open -a "Mission Control"`.
- **Hot corner coordinate math**: CGEvent uses flipped coordinates (0,0 = top-left of primary display). NSScreen uses bottom-left origin. Conversion: `cgY = primaryScreenHeight - nsY - screenHeight`.
- **Ripple animation**: Uses GNOME's exact parameters — three ripples with delays 0/50/350ms, durations 830/1000/1000ms, scale easeOut, opacity easeIn. Quarter-circle shape via CGPath arc.
- **Permissions**: Requires both **Accessibility** and **Input Monitoring** in System Settings → Privacy & Security. Running from terminal inherits the terminal's permissions; running as a standalone app (via `open`) requires its own grants.
- **Code signing**: Ad-hoc signed (`codesign --force --sign -`) so permissions persist across rebuilds (tied to bundle ID, not binary hash).
- **App hides from Dock**: Both `LSUIElement=true` in Info.plist and `.accessory` activation policy.

## CI

GitHub Actions workflow at `.github/workflows/build.yml` — triggers on `x.y.z` tags, builds on `macos-latest`, creates a draft GitHub release with `OptWin.zip` attached.

A `Makefile` is also available with targets: `build`, `install`, `run` (kill → clean → install --run), `kill`, `clean`.

## License

WTFPL v2.
