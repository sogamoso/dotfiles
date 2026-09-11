cask "epistles" do
  version "1.8.0"
  sha256 "5cb693a1857a9349ee2d43f7ed93a159ec320f418f18b8200b92235713817c54"

  # Upstream names the DMG after the first 12 hex digits of its own sha256.
  url "https://repo.epistles.net/mac/Epistles_#{version}_#{sha256.to_s[0, 12]}.dmg",
      verified: "repo.epistles.net/mac/"
  name "Epistles"
  desc "Unified email client for Fastmail, Gmail, Exchange, ProtonMail, and IMAP"
  homepage "https://epistles.net/"

  livecheck do
    url "https://repo.epistles.net/mac/latest.json"
    strategy :json do |json|
      json.dig("platforms", "darwin-aarch64") ? json["version"] : nil
    end
  end

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "Epistles.app"
end
