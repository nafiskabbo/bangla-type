# Homebrew Cask for BanglaType. Update VERSION and sha256 on release.
cask "banglatype" do
  version "1.0.0"
  sha256 "REPLACE_WITH_SHA256"

  url "https://github.com/nafiskabbo/bangla-type/releases/download/v#{version}/BanglaType-#{version}.dmg"
  name "BanglaType"
  desc "Open-source Bangladeshi Bangla input method for macOS"
  homepage "https://github.com/nafiskabbo/bangla-type"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "BanglaType.app", target: "/Library/Input Methods/BanglaType.app"
end
