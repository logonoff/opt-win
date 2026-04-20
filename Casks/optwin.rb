cask "optwin" do
  version "0.1.1"
  sha256 "34a3f35576a5e524f2f838bb2b837cff5b6fc01744d3964031a4f606720c2bac"

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
