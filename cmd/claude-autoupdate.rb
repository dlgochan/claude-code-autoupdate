#!/usr/bin/env ruby
# frozen_string_literal: true

# CLI 진입점: subcommand 파싱 및 검증 후 해당 모듈로 위임

require "pathname"

$LOAD_PATH.unshift(Pathname(__FILE__).dirname.parent.join("lib").to_s)
require "claude_autoupdate/core"

module Homebrew
  module Cmd
    class ClaudeAutoupdate
      SUBCOMMANDS = %w[enable disable status update config].freeze

      def self.run
        new.run
      end

      def run
        if ARGV.empty?
          print_help
          exit 0
        end

        subcommand = ARGV.first
        unless SUBCOMMANDS.include?(subcommand)
          puts "Error: Unknown subcommand '#{subcommand}'"
          puts
          print_help
          exit 1
        end

        begin
          ::ClaudeAutoupdate::Core.validate! unless %w[status config].include?(subcommand)
        rescue => e
          puts e.message
          exit 1
        end

        dispatch(subcommand, parse_flags(ARGV[1..]))
      end

      private

      def dispatch(subcommand, flags)
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
            enable      Enable auto-updates (default: 24h interval)
            disable     Disable auto-updates and cleanup
            status      Show current auto-update status
            update      Manually update claude-code now
            config      Show current configuration

          Options:
            --interval, -i    Set update interval (e.g., 6h, 12h, 24h, 2d)

          Examples:
            claude-autoupdate enable              # Default 24h
            claude-autoupdate enable -i 12h       # Every 12 hours
            claude-autoupdate enable -i 6h        # Every 6 hours
            claude-autoupdate status
            claude-autoupdate disable

          Supported intervals: 1h ~ 7d (hours or days)

          https://github.com/dlgochan/claude-code-autoupdate
        HELP
      end
    end
  end
end

Homebrew::Cmd::ClaudeAutoupdate.run
