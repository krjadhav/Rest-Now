cask "restnow" do
  version "1.0.0"
  sha256 "ded8bcd0458ba303dd8f7684b014df8cc682f5ac622d460fd010445b344f93b1"

  url "https://github.com/krjadhav/Rest-Now/releases/download/v#{version}/RestNow.dmg"
  name "RestNow"
  desc "macOS app to remind you to take breaks and rest your eyes"
  homepage "https://github.com/krjadhav/Rest-Now"

  depends_on macos: ">= :sequoia"

  app "RestNow.app"
end
