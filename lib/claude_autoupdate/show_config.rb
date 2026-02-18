# frozen_string_literal: true

require_relative "core"
require_relative "config"

# 현재 설정 표시
module ClaudeAutoupdate
  module ShowConfig
    module_function

    def run
      config = Config.load

      puts "Configuration:"
      puts
      puts "  Update interval: #{config['interval']} (#{Config.format_interval(config['interval_seconds'])})"
      puts "  Config file: #{Config.config_path}"
      puts

      if Core.running?
        puts "Status: ✅ ENABLED"
        puts
        puts "To change interval:"
        puts "  claude-autoupdate disable"
        puts "  claude-autoupdate enable -i 12h"
      else
        puts "Status: ❌ DISABLED"
        puts
        puts "To enable:"
        puts "  claude-autoupdate enable -i 12h"
      end
    end
  end
end
