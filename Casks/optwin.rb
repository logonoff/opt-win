cask "optwin" do
  version "0.2.1"
  sha256 "702b65e19dadf0cb92a290cc33d0037900bc45a8606d0d1d0d81ef547902f0ee"

  url "https://github.com/logonoff/opt-win/releases/download/#{version}/OptWin.zip"
  name "OptWin"
  desc "macOS menu bar app that repurposes the Option key with GNOME-style features"
  homepage "https://github.com/logonoff/opt-win"

  depends_on macos: ">= :tahoe"

  app "OptWin.app"

  zap trash: [
    "~/Library/Preferences/co.logonoff.optwin.plist",
  ]
end
