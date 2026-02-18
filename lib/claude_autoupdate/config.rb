# frozen_string_literal: true

require "json"
require "fileutils"

# 설정 관리 (update interval 등)
# 설정 파일: ~/Library/Application Support/claude-autoupdate/config.json
module ClaudeAutoupdate
  module Config
    module_function

    DEFAULTS = {
      "interval" => "24h",
      "interval_seconds" => 86_400
    }.freeze

    MIN_SECONDS = 3_600    # 1 hour
    MAX_SECONDS = 604_800  # 7 days

    def config_path
      File.expand_path("~/Library/Application Support/claude-autoupdate/config.json")
    end

    def load
      return DEFAULTS.dup unless File.exist?(config_path)

      JSON.parse(File.read(config_path))
    rescue JSON::ParserError
      DEFAULTS.dup
    end

    def save(config)
      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, JSON.pretty_generate(config))
    end

    # "6h" → 21600, "2d" → 172800
    def parse_interval(str)
      str = str.to_s.strip.downcase

      seconds = case str
                when /^(\d+)h$/ then $1.to_i * 3_600
                when /^(\d+)d$/ then $1.to_i * 86_400
                when /^(\d+)$/  then $1.to_i
                else
                  raise ArgumentError, "Invalid interval format: #{str}. Use format like: 6h, 12h, 24h, 1d, 2d"
                end

      if seconds < MIN_SECONDS
        raise ArgumentError, "Interval too short: #{str}. Minimum is 1h."
      end
      if seconds > MAX_SECONDS
        raise ArgumentError, "Interval too long: #{str}. Maximum is 7d."
      end

      seconds
    end

    # 86400 → "1 day", 43200 → "12 hours"
    def format_interval(seconds)
      seconds = seconds.to_i

      if (seconds % 86_400).zero?
        days = seconds / 86_400
        "#{days} day#{'s' if days != 1}"
      elsif (seconds % 3_600).zero?
        hours = seconds / 3_600
        "#{hours} hour#{'s' if hours != 1}"
      else
        "#{seconds} seconds"
      end
    end

    def update_interval(interval_str)
      seconds = parse_interval(interval_str)
      config = load
      config["interval"] = interval_str
      config["interval_seconds"] = seconds
      save(config)
      seconds
    end
  end
end
