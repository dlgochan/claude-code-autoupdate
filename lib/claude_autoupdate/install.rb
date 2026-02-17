# frozen_string_literal: true

require_relative "core"
require "fileutils"

# Installation command for claude-autoupdate
# Creates LaunchAgent plist and update script, then loads via launchctl
module ClaudeAutoupdate
  module Install
    module_function

    def run
      # Check if already installed
      if ClaudeAutoupdate::Core.running?
        puts "Auto-updates already enabled for claude-code!"
        puts "Run 'claude-autoupdate status' for details."
        exit 0
      end

      puts "Setting up auto-updates for claude-code..."
      puts

      # Create necessary directories
      create_directories

      # Generate and write update script
      write_update_script

      # Generate and write plist
      write_plist

      # Load LaunchAgent
      load_launchagent

      # Verify
      verify_installation

      print_success
    end

    def create_directories
      [
        ClaudeAutoupdate::Core.script_dir,
        ClaudeAutoupdate::Core.log_dir,
        File.dirname(ClaudeAutoupdate::Core.plist_path)
      ].each do |dir|
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end
    end

    def write_update_script
      script_path = ClaudeAutoupdate::Core.script_path
      brew_prefix = `brew --prefix`.chomp

      script_content = <<~SCRIPT
        #!/bin/bash

        # Log with timestamp
        echo "[$(date)] Starting claude-code update check..."

        # Preserve Homebrew environment
        export PATH="#{brew_prefix}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1

        # Update Homebrew and upgrade claude-code
        brew update && brew upgrade --cask claude-code && brew cleanup claude-code

        echo "[$(date)] Update check complete"
      SCRIPT

      File.write(script_path, script_content)
      File.chmod(0555, script_path)

      puts "✓ Created update script at #{script_path}"
    end

    def write_plist
      plist_path = ClaudeAutoupdate::Core.plist_path
      plist_content = generate_plist

      File.write(plist_path, plist_content)

      puts "✓ Created LaunchAgent at #{plist_path}"
    end

    def generate_plist
      script_path = ClaudeAutoupdate::Core.script_path
      log_path = ClaudeAutoupdate::Core.log_path
      label = ClaudeAutoupdate::Core.label_name

      <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{label}</string>

          <key>ProgramArguments</key>
          <array>
            <string>/bin/bash</string>
            <string>#{script_path}</string>
          </array>

          <key>RunAtLoad</key>
          <true/>

          <key>StartInterval</key>
          <integer>86400</integer>

          <key>StandardErrorPath</key>
          <string>#{log_path}</string>

          <key>StandardOutPath</key>
          <string>#{log_path}</string>

          <key>LowPriorityBackgroundIO</key>
          <true/>

          <key>ProcessType</key>
          <string>Background</string>
        </dict>
        </plist>
      PLIST
    end

    def load_launchagent
      plist_path = ClaudeAutoupdate::Core.plist_path

      unless system("launchctl", "load", plist_path)
        raise "Failed to load LaunchAgent. Check permissions."
      end

      puts "✓ Loaded LaunchAgent"
    end

    def verify_installation
      sleep 1 # Give launchd time to register

      unless ClaudeAutoupdate::Core.running?
        raise "LaunchAgent failed to start. Check logs at #{ClaudeAutoupdate::Core.log_path}"
      end

      puts "✓ Verified LaunchAgent is running"
    end

    def print_success
      puts
      puts "🎉 Auto-updates enabled for claude-code!"
      puts
      puts "What happens now:"
      puts "  • Updates run every 24 hours"
      puts "  • Updates run at system boot"
      puts "  • Updates run in the background (low priority)"
      puts
      puts "Commands:"
      puts "  claude-autoupdate status  # Check status"
      puts "  claude-autoupdate update  # Update now"
      puts
      puts "Logs: #{ClaudeAutoupdate::Core.log_path}"
    end
  end
end
