cask "optwin" do
  version "0.1.0"
  sha256 "92dcbe9f3c6d1c4cab118796199cf3ca95a704ab309d75545e91fc636d21223a"

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
