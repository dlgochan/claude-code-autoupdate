# frozen_string_literal: true

require_relative "core"
require_relative "config"
require "time"

# 현재 상태, 마지막 실행 시간, 다음 실행 시간 표시
module ClaudeAutoupdate
  module Status
    module_function

    def run
      if Core.running?
        show_enabled_status
      else
        puts "Status: ❌ DISABLED"
        puts
        puts "Auto-updates are not enabled."
        puts "Run 'claude-autoupdate enable' to enable."
      end
    end

    def show_enabled_status
      config = Config.load
      interval_str = Config.format_interval(config["interval_seconds"])

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
      puts "  LaunchAgent: #{Core.plist_path}"
      puts "  Script: #{Core.script_path}"
      puts "  Log: #{Core.log_path}"
    end

    def show_run_times(interval_seconds)
      last_run = parse_last_run_time
      interval_hours = interval_seconds / 3600.0

      unless last_run
        puts "Last run: Never"
        puts "Next run: At system boot or within #{interval_hours} hours"
        return
      end

      puts "Last run: #{last_run.strftime('%Y-%m-%d %H:%M:%S')}"

      next_run = last_run + interval_seconds
      if next_run > Time.now
        hours_until = ((next_run - Time.now) / 3600).round(1)
        puts "Next run: #{next_run.strftime('%Y-%m-%d %H:%M:%S')} (in ~#{hours_until} hours)"
      else
        puts "Next run: Soon (overdue)"
      end
    end

    # 로그에서 마지막 실행 시간을 파싱
    # 로그 형식: [Tue Feb 18 15:57:46 KST 2026] Starting claude-code update check...
    def parse_last_run_time
      return nil unless File.exist?(Core.log_path)

      last_timestamp = nil
      File.readlines(Core.log_path).each do |line|
        if line =~ /^\[(.+?)\] Starting claude-code update check/
          last_timestamp = Time.parse($1) rescue next
        end
      end
      last_timestamp
    rescue StandardError
      nil
    end
  end
end
