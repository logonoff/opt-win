cask "superopt" do
  version "0.3.1"
  sha256 "7e87e777a9d2f8ae583b0923f7a11231ff10a852b674f93bbe63185180585e7d"

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
