cask "superopt" do
  version "0.2.1"
  sha256 "702b65e19dadf0cb92a290cc33d0037900bc45a8606d0d1d0d81ef547902f0ee"

  url "https://github.com/logonoff/superopt/releases/download/#{version}/SuperOpt.zip"
  name "SuperOpt"
  desc "macOS menu bar app that repurposes the Option key with GNOME-style features"
  homepage "https://github.com/logonoff/superopt"

  depends_on macos: ">= :tahoe"

  app "SuperOpt.app"

  zap trash: [
    "~/Library/Preferences/co.logonoff.superopt.plist",
  ]
end
