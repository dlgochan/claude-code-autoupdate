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
      SUBCOMMANDS = %w[install uninstall status update].freeze

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

        # Validate platform and installation (except for status)
        begin
          ::ClaudeAutoupdate::Core.validate! unless subcommand == "status"
        rescue => e
          puts e.message
          exit 1
        end

        # Lazy-load implementation
        case subcommand
        when "install"
          require "claude_autoupdate/install"
          ::ClaudeAutoupdate::Install.run
        when "uninstall"
          require "claude_autoupdate/uninstall"
          ::ClaudeAutoupdate::Uninstall.run
        when "status"
          require "claude_autoupdate/status"
          ::ClaudeAutoupdate::Status.run
        when "update"
          require "claude_autoupdate/update"
          ::ClaudeAutoupdate::Update.run
        end
      end

      private

      def print_help
        puts <<~HELP
          Usage: claude-autoupdate <subcommand>

          Automatic updates for claude-code Homebrew installations.

          Subcommands:
            install     Enable auto-updates (24h interval + boot)
            uninstall   Disable auto-updates and cleanup
            status      Show current auto-update status
            update      Manually update claude-code now

          Examples:
            claude-autoupdate install   # Enable auto-updates
            claude-autoupdate status    # Check status
            claude-autoupdate update    # Update now

          For more info: https://github.com/dlgochan/claude-code-autoupdate
        HELP
      end
    end
  end
end

# Run command
Homebrew::Cmd::ClaudeAutoupdate.run
