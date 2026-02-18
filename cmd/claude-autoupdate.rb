#!/usr/bin/env ruby
# frozen_string_literal: true

# External command for Homebrew: brew claude-autoupdate
# Enables automatic updates for claude-code Homebrew installations

require "pathname"

# Add lib directory to load path
HOMEBREW_LIBRARY_PATH = Pathname(__FILE__).dirname.parent.join("lib").freeze
$LOAD_PATH.unshift(HOMEBREW_LIBRARY_PATH) unless $LOAD_PATH.include?(HOMEBREW_LIBRARY_PATH)

require "claude_autoupdate/core"

module Homebrew
  module Cmd
    class ClaudeAutoupdate
      SUBCOMMANDS = %w[enable disable status update config].freeze

      def self.run
        new.run
      end

      def run
        # Show help if no subcommand provided
        if ARGV.empty?
          print_help
          exit 0
        end

        subcommand = ARGV.first

        # Validate subcommand
        unless SUBCOMMANDS.include?(subcommand)
          puts "Error: Unknown subcommand '#{subcommand}'"
          puts
          print_help
          exit 1
        end

        # Validate platform and installation (except for status and config)
        begin
          ::ClaudeAutoupdate::Core.validate! unless %w[status config].include?(subcommand)
        rescue => e
          puts e.message
          exit 1
        end

        # Parse flags
        flags = parse_flags(ARGV[1..-1])

        # Lazy-load implementation
        case subcommand
        when "enable"
          require "claude_autoupdate/enable"
          ::ClaudeAutoupdate::Enable.run(interval: flags[:interval])
        when "disable"
          require "claude_autoupdate/disable"
          ::ClaudeAutoupdate::Disable.run
        when "status"
          require "claude_autoupdate/status"
          ::ClaudeAutoupdate::Status.run
        when "update"
          require "claude_autoupdate/update"
          ::ClaudeAutoupdate::Update.run
        when "config"
          require "claude_autoupdate/show_config"
          ::ClaudeAutoupdate::ShowConfig.run
        end
      end

      private

      def parse_flags(args)
        flags = {}
        i = 0

        while i < args.length
          case args[i]
          when "--interval", "-i"
            flags[:interval] = args[i + 1]
            i += 2
          else
            i += 1
          end
        end

        flags
      end

      def print_help
        puts <<~HELP
          Usage: claude-autoupdate <subcommand> [options]

          Automatic updates for claude-code Homebrew installations.

          Subcommands:
            enable      Enable auto-updates (default: 24h interval + boot)
            disable     Disable auto-updates and cleanup
            status      Show current auto-update status
            update      Manually update claude-code now
            config      Show current configuration

          Options:
            --interval, -i INTERVAL    Set update interval (e.g., 6h, 12h, 24h, 2d)

          Examples:
            claude-autoupdate enable              # Enable with default (24h)
            claude-autoupdate enable -i 12h       # Enable with 12 hour interval
            claude-autoupdate enable -i 6h        # Enable with 6 hour interval
            claude-autoupdate status              # Check status
            claude-autoupdate config              # Show configuration
            claude-autoupdate update              # Update now
            claude-autoupdate disable             # Disable auto-updates

          Supported interval formats:
            6h, 12h, 24h    Hours (minimum: 1h)
            1d, 2d, 7d      Days (maximum: 7d)

          For more info: https://github.com/dlgochan/claude-code-autoupdate
        HELP
      end
    end
  end
end

# Run command
Homebrew::Cmd::ClaudeAutoupdate.run
