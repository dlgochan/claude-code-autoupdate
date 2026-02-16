# frozen_string_literal: true

# Core utilities for claude-autoupdate
# Manages paths, installation detection, and launchd status checks
module ClaudeAutoupdate
  module Core
    module_function

    # LaunchAgent label identifier
    def label_name
      "com.github.dlgochan.claude-autoupdate"
    end

    # Path to LaunchAgent plist file
    def plist_path
      File.expand_path("~/Library/LaunchAgents/#{label_name}.plist")
    end

    # Directory for update scripts
    def script_dir
      File.expand_path("~/Library/Application Support/claude-autoupdate")
    end

    # Path to update script
    def script_path
      "#{script_dir}/update.sh"
    end

    # Directory for logs
    def log_dir
      File.expand_path("~/Library/Logs/claude-autoupdate")
    end

    # Path to log file
    def log_path
      "#{log_dir}/claude-autoupdate.log"
    end

    # Check if launchd job is currently loaded and running
    def running?
      `launchctl list`.include?(label_name)
    end

    # Check if native Claude Code installation exists
    # Native installations have auto-updates built-in
    def native_installation?
      native_bin = File.expand_path("~/.local/bin/claude")
      native_share = File.expand_path("~/.local/share/claude")
      File.exist?(native_bin) || Dir.exist?(native_share)
    end

    # Check if Homebrew installation exists
    def homebrew_installation?
      system("brew", "list", "--cask", "claude-code",
             out: File::NULL, err: File::NULL)
    end

    # Validate platform and installation
    def validate!
      unless RUBY_PLATFORM.include?("darwin")
        raise "This tool only works on macOS (requires launchd)"
      end

      if native_installation?
        raise <<~ERROR
          You have native Claude Code installed - auto-updates are already enabled!

          Native Claude Code automatically updates in the background.
          This tool is only needed for Homebrew installations.

          Check your installation: claude doctor
        ERROR
      end

      unless homebrew_installation?
        raise <<~ERROR
          Error: claude-code is not installed via Homebrew.
          Install first: brew install --cask claude-code
        ERROR
      end
    end
  end
end
