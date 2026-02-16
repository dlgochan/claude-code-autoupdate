# frozen_string_literal: true

# Homebrew formula for claude-autoupdate
class ClaudeAutoupdate < Formula
  desc "Automatic updates for claude-code Homebrew installations"
  homepage "https://github.com/dlgochan/claude-code-autoupdate"
  url "https://github.com/dlgochan/claude-code-autoupdate.git",
      branch: "main"
  version "1.0.0"
  license "MIT"

  depends_on "ruby" => :build
  depends_on macos: :catalina

  def install
    # Install library files
    lib.install Dir["lib/*"]

    # Install command
    (bin/"claude-autoupdate").write_env_script(
      "#{Formula["ruby"].opt_bin}/ruby",
      "#{libexec}/cmd/claude-autoupdate.rb",
      RUBYLIB: ENV["RUBYLIB"] ? "#{lib}:#{ENV["RUBYLIB"]}" : lib.to_s
    )

    # Copy command file to libexec
    libexec.install "cmd"
  end

  def caveats
    <<~EOS
      To enable auto-updates for claude-code:
        claude-autoupdate install

      Check status:
        claude-autoupdate status

      This tool is only for Homebrew installations of claude-code.
      Native installations already have built-in auto-updates.
    EOS
  end

  test do
    # Test that the command exists and shows help
    assert_match "Usage: brew claude-autoupdate", shell_output("#{bin}/claude-autoupdate")
  end
end
