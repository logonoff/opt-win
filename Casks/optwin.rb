cask "optwin" do
  version "0.0.6"
  sha256 "e046b30d323459e0724a32f746aef2cc6240bd712d1c3299d87ad63ea0072446"

  url "https://github.com/logonoff/opt-win/releases/download/#{version}/OptWin.zip"
  name "OptWin"
  desc "macOS menu bar app that repurposes the Option key with GNOME-style features"
  homepage "https://github.com/logonoff/opt-win"

  depends_on macos: ">= :tahoe"

  app "OptWin.app"

  zap trash: [
    "~/Library/Preferences/com.local.optwin.plist",
  ]
end
