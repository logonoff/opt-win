# OptWin

> [!WARNING]
> This is AI slop and I have not vetted the code. Use at your own risk!

A tiny macOS menu bar app that repurposes the Option key. Requires **macOS 26 (Tahoe)** or later.

- **Single press `⌥`** → Mission Control
- **Double press `⌥`** → Spotlight Apps
- **Hot corner** → Slam mouse to top-left corner of any screen → Mission Control (with GNOME-style ripple animation)
- **`⌥`+`1-9`** → Launch the Nth app in your Dock (1 = Finder)
- **Caps Lock OSD** → On-screen notification when Caps Lock is toggled

All features can be individually toggled on/off from the menu bar. Detection happens on key-up, so existing keyboard shortcuts using Option are unaffected.

## Build

```
./build.sh
```

Requires Xcode command line tools (`xcode-select --install`).

## Install

```
brew install --cask logonoff/opt-win/optwin
```

Or build from source:

```
./build.sh && ./install.sh
```

## Gatekeeper

The app is not notarized, so macOS will warn about it on first launch. To bypass, run:

```
xattr -d com.apple.quarantine /Applications/OptWin.app
```

## Permissions

OptWin requires two permissions to function:

1. **Accessibility** (System Settings → Privacy & Security → Accessibility)
2. **Input Monitoring** (System Settings → Privacy & Security → Input Monitoring)

Use the "Request Permissions..." menu item to open the relevant settings panes.

## License

[WTFPL](LICENSE)
