# frozen_string_literal: true

require_relative "core"
require "fileutils"

# LaunchAgent를 정지하고 설정 파일을 제거 (로그는 보존)
module ClaudeAutoupdate
  module Disable
    module_function

    def run
      unless Core.running?
        puts "Auto-updates are not enabled. Nothing to disable."
        exit 0
      end

      puts "Disabling auto-updates for claude-code..."
      puts

      system("launchctl", "unload", Core.plist_path)
      puts "✓ Stopped LaunchAgent"

      File.delete(Core.plist_path) if File.exist?(Core.plist_path)
      puts "✓ Removed LaunchAgent plist"

      FileUtils.rm_rf(Core.script_dir) if Dir.exist?(Core.script_dir)
      puts "✓ Removed scripts and config"

      puts "✓ Logs preserved at #{Core.log_path}" if File.exist?(Core.log_path)

      puts
      puts "Auto-updates disabled. To re-enable: claude-autoupdate enable"
    end
  end
end
