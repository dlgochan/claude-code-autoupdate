# frozen_string_literal: true

require_relative "core"
require_relative "config"
require "fileutils"

# LaunchAgent plist와 update script를 생성하고 launchctl로 등록
module ClaudeAutoupdate
  module Enable
    module_function

    def run(interval: nil)
      if Core.running?
        puts "Auto-updates already enabled for claude-code!"
        puts "Run 'claude-autoupdate status' for details."
        exit 0
      end

      if interval
        begin
          Config.update_interval(interval)
          puts "Using custom interval: #{interval}"
        rescue ArgumentError => e
          puts "Error: #{e.message}"
          exit 1
        end
      else
        Config.save(Config.load)
      end

      puts "Setting up auto-updates for claude-code..."
      puts

      create_directories
      write_update_script
      write_plist
      load_launchagent
      verify
      print_success
    end

    def create_directories
      [Core.script_dir, Core.log_dir, File.dirname(Core.plist_path)].each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def write_update_script
      brew_prefix = `brew --prefix`.chomp

      content = <<~SCRIPT
        #!/bin/bash
        echo "[$(date)] Starting claude-code update check..."
        export PATH="#{brew_prefix}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1
        brew update && brew upgrade --cask claude-code && brew cleanup claude-code
        echo "[$(date)] Update check complete"
      SCRIPT

      File.write(Core.script_path, content)
      File.chmod(0555, Core.script_path)
      puts "✓ Created update script"
    end

    def write_plist
      config = Config.load

      content = <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{Core::LABEL}</string>
          <key>ProgramArguments</key>
          <array>
            <string>/bin/bash</string>
            <string>#{Core.script_path}</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>StartInterval</key>
          <integer>#{config["interval_seconds"]}</integer>
          <key>StandardErrorPath</key>
          <string>#{Core.log_path}</string>
          <key>StandardOutPath</key>
          <string>#{Core.log_path}</string>
          <key>LowPriorityBackgroundIO</key>
          <true/>
          <key>ProcessType</key>
          <string>Background</string>
        </dict>
        </plist>
      PLIST

      File.write(Core.plist_path, content)
      puts "✓ Created LaunchAgent"
    end

    def load_launchagent
      raise "Failed to load LaunchAgent. Check permissions." unless system("launchctl", "load", Core.plist_path)

      puts "✓ Loaded LaunchAgent"
    end

    def verify
      sleep 1
      raise "LaunchAgent failed to start. Check logs at #{Core.log_path}" unless Core.running?

      puts "✓ Verified LaunchAgent is running"
    end

    def print_success
      interval_str = Config.format_interval(Config.load["interval_seconds"])

      puts
      puts "🎉 Auto-updates enabled for claude-code!"
      puts
      puts "  • Updates run every #{interval_str}"
      puts "  • Updates run at system boot"
      puts "  • Updates run in the background (low priority)"
      puts
      puts "Logs: #{Core.log_path}"
    end
  end
end
