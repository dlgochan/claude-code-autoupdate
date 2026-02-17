# frozen_string_literal: true

require_relative "core"
require "fileutils"

# Uninstall command for claude-autoupdate
# Stops LaunchAgent and removes configuration files (keeps logs)
module ClaudeAutoupdate
  module Uninstall
    module_function

    def run
      unless ClaudeAutoupdate::Core.running?
        puts "Auto-updates are not enabled."
        puts "Nothing to uninstall."
        exit 0
      end

      puts "Disabling auto-updates for claude-code..."
      puts

      # Unload LaunchAgent
      unload_launchagent

      # Remove plist
      remove_plist

      # Remove script directory
      remove_scripts

      # Keep logs for user reference
      preserve_logs

      print_success
    end

    def unload_launchagent
      plist_path = ClaudeAutoupdate::Core.plist_path

      unless system("launchctl", "unload", plist_path)
        warn "Warning: Failed to unload LaunchAgent (may not be running)"
      end

      puts "✓ Stopped LaunchAgent"
    end

    def remove_plist
      plist_path = ClaudeAutoupdate::Core.plist_path

      if File.exist?(plist_path)
        File.delete(plist_path)
        puts "✓ Removed LaunchAgent plist"
      end
    end

    def remove_scripts
      script_dir = ClaudeAutoupdate::Core.script_dir

      if Dir.exist?(script_dir)
        FileUtils.rm_rf(script_dir)
        puts "✓ Removed scripts"
      end
    end

    def preserve_logs
      log_path = ClaudeAutoupdate::Core.log_path

      if File.exist?(log_path)
        puts "✓ Logs preserved at #{log_path}"
      end
    end

    def print_success
      puts
      puts "Auto-updates disabled for claude-code."
      puts
      puts "To re-enable: claude-autoupdate install"
    end
  end
end
