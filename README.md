# OptWin

> [!WARNING]
> This is AI slop and I have not vetted the code. Use at your own risk!

A tiny macOS menu bar app that repurposes the Option key:

- **Single press `⌥`** → Mission Control
- **Double press `⌥`** → Spotlight

Detection happens on key-up, so existing keyboard shortcuts using Option are unaffected.

## Build

```
./build.sh
```

Requires Xcode command line tools (`xcode-select --install`).

## Run

```
open build/OptWin.app
```

On first launch, grant **Accessibility** permissions when prompted (System Settings → Privacy & Security → Accessibility).

To install permanently, copy to Applications and add to Login Items:

```
cp -r build/OptWin.app /Applications/
```
