# frozen_string_literal: true

require_relative "core"
require_relative "config"

# Show configuration command for claude-autoupdate
# Displays current configuration settings
module ClaudeAutoupdate
  module ShowConfig
    module_function

    def run
      config = ::ClaudeAutoupdate::Config.load

      puts "Configuration:"
      puts
      puts "  Update interval: #{config['interval']} (#{::ClaudeAutoupdate::Config.format_interval(config['interval_seconds'])})"
      puts "  Interval (seconds): #{config['interval_seconds']}"
      puts
      puts "  Config file: #{::ClaudeAutoupdate::Config.config_path}"
      puts

      if ::ClaudeAutoupdate::Core.running?
        puts "Status: ✅ ENABLED"
        puts
        puts "To change interval:"
        puts "  1. Disable: claude-autoupdate disable"
        puts "  2. Re-enable with new interval: claude-autoupdate enable --interval 12h"
      else
        puts "Status: ❌ DISABLED"
        puts
        puts "To enable with custom interval:"
        puts "  claude-autoupdate enable --interval 12h"
      end
    end
  end
end
