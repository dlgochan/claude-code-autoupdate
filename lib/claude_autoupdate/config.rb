# frozen_string_literal: true

require "json"
require "fileutils"

# Configuration management for claude-autoupdate
# Stores user preferences like update interval
module ClaudeAutoupdate
  module Config
    module_function

    # Default configuration
    DEFAULTS = {
      "interval" => "24h",
      "interval_seconds" => 86_400
    }.freeze

    # Get configuration file path
    def config_path
      File.expand_path("~/Library/Application Support/claude-autoupdate/config.json")
    end

    # Load configuration from file
    def load
      return DEFAULTS.dup unless File.exist?(config_path)

      JSON.parse(File.read(config_path))
    rescue JSON::ParserError
      DEFAULTS.dup
    end

    # Save configuration to file
    def save(config)
      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, JSON.pretty_generate(config))
    end

    # Get a configuration value
    def get(key)
      load[key]
    end

    # Set a configuration value
    def set(key, value)
      config = load
      config[key] = value
      save(config)
    end

    # Parse interval string to seconds
    # Supports: 6h, 12h, 24h, 1d, 2d, etc.
    def parse_interval(interval_str)
      interval_str = interval_str.to_s.strip.downcase

      case interval_str
      when /^(\d+)h$/
        hours = $1.to_i
        validate_interval_range!(hours * 3600, interval_str)
      when /^(\d+)d$/
        days = $1.to_i
        validate_interval_range!(days * 86_400, interval_str)
      when /^(\d+)$/
        seconds = $1.to_i
        validate_interval_range!(seconds, interval_str)
      else
        raise ArgumentError, "Invalid interval format: #{interval_str}. Use format like: 6h, 12h, 24h, 1d, 2d"
      end
    end

    # Validate interval is within reasonable range
    def validate_interval_range!(seconds, original_str)
      min_seconds = 3600        # 1 hour
      max_seconds = 604_800     # 7 days

      if seconds < min_seconds
        raise ArgumentError, "Interval too short: #{original_str}. Minimum is 1h (1 hour)."
      end

      if seconds > max_seconds
        raise ArgumentError, "Interval too long: #{original_str}. Maximum is 7d (7 days)."
      end

      seconds
    end

    # Format seconds to human-readable string
    def format_interval(seconds)
      seconds = seconds.to_i

      if seconds % 86_400 == 0
        days = seconds / 86_400
        "#{days} day#{'s' if days != 1}"
      elsif seconds % 3600 == 0
        hours = seconds / 3600
        "#{hours} hour#{'s' if hours != 1}"
      else
        "#{seconds} seconds"
      end
    end

    # Update interval configuration
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
