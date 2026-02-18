# frozen_string_literal: true

require_relative "core"
require_relative "config"
require "time"

# Status reporting for claude-autoupdate
# Shows current state, last run time, next run estimate
module ClaudeAutoupdate
  module Status
    module_function

    def run
      if ClaudeAutoupdate::Core.running?
        show_enabled_status
      else
        show_disabled_status
      end
    end

    def show_enabled_status
      config = ::ClaudeAutoupdate::Config.load
      interval_str = ::ClaudeAutoupdate::Config.format_interval(config["interval_seconds"])

      puts "Status: ✅ ENABLED"
      puts
      puts "Configuration:"
      puts "  Interval: #{interval_str} (#{config['interval_seconds']} seconds)"
      puts "  Runs at boot: Yes"
      puts "  Priority: Low (background)"
      puts

      show_run_times(config["interval_seconds"])

      puts
      puts "Files:"
      puts "  LaunchAgent: #{::ClaudeAutoupdate::Core.plist_path}"
      puts "  Script: #{::ClaudeAutoupdate::Core.script_path}"
      puts "  Log: #{::ClaudeAutoupdate::Core.log_path}"
    end

    def show_disabled_status
      puts "Status: ❌ DISABLED"
      puts
      puts "Auto-updates are not enabled."
      puts "Run 'claude-autoupdate enable' to enable."
    end

    def show_run_times(interval_seconds)
      last_run = get_last_run_time
      interval_hours = interval_seconds / 3600.0

      if last_run
        puts "Last run: #{last_run.strftime('%Y-%m-%d %H:%M:%S')}"

        next_run = last_run + interval_seconds
        now = Time.now

        if next_run > now
          hours_until = ((next_run - now) / 3600).round(1)
          puts "Next run: #{next_run.strftime('%Y-%m-%d %H:%M:%S')} (in ~#{hours_until} hours)"
        else
          puts "Next run: Soon (overdue)"
        end
      else
        puts "Last run: Never (will run at next boot or in #{interval_hours} hours)"
        puts "Next run: At system boot or within #{interval_hours} hours"
      end
    end

    def get_last_run_time
      log_path = ClaudeAutoupdate::Core.log_path

      return nil unless File.exist?(log_path)

      # Parse log file for last timestamp
      # Format: [Mon Jan 13 14:30:00 KST 2026] Starting claude-code update check...
      last_timestamp = nil

      File.readlines(log_path).each do |line|
        if line =~ /^\[(.+?)\] Starting claude-code update check/
          timestamp_str = $1
          begin
            last_timestamp = Time.parse(timestamp_str)
          rescue ArgumentError
            # Skip invalid timestamps
            next
          end
        end
      end

      last_timestamp
    rescue => e
      nil
    end
  end
end
