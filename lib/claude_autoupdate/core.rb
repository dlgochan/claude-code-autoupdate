# frozen_string_literal: true

# 경로 관리, 설치 방식 감지, 플랫폼 검증
module ClaudeAutoupdate
  module Core
    module_function

    LABEL = "com.github.dlgochan.claude-autoupdate"

    def plist_path
      File.expand_path("~/Library/LaunchAgents/#{LABEL}.plist")
    end

    def script_dir
      File.expand_path("~/Library/Application Support/claude-autoupdate")
    end

    def script_path
      "#{script_dir}/update.sh"
    end

    def log_dir
      File.expand_path("~/Library/Logs/claude-autoupdate")
    end

    def log_path
      "#{log_dir}/claude-autoupdate.log"
    end

    def running?
      `launchctl list`.include?(LABEL)
    end

    # 실제 사용 중인 claude 경로를 확인하여 Native 설치인지 판별
    # Native는 auto-update가 내장되어 있으므로 이 도구가 불필요
    def native_installation?
      claude_path = `/bin/bash -c 'which claude' 2>/dev/null`.strip
      return false if claude_path.empty?
      return false if claude_path.include?("/opt/homebrew/") ||
                      claude_path.include?("/usr/local/") ||
                      claude_path.include?("/home/linuxbrew/")

      claude_path.include?("/.local/")
    end

    def homebrew_installation?
      system("brew", "list", "--cask", "claude-code",
             out: File::NULL, err: File::NULL)
    end

    def validate!
      raise "This tool only works on macOS (requires launchd)" unless RUBY_PLATFORM.include?("darwin")

      if native_installation?
        raise <<~MSG
          You have native Claude Code installed - auto-updates are already enabled!

          Native Claude Code automatically updates in the background.
          This tool is only needed for Homebrew installations.

          Check your installation: claude doctor
        MSG
      end

      unless homebrew_installation?
        raise <<~MSG
          Error: claude-code is not installed via Homebrew.
          Install first: brew install --cask claude-code
        MSG
      end
    end
  end
end
