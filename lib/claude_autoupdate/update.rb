# frozen_string_literal: true

require_relative "core"

# Manual update command for claude-autoupdate
# Immediately updates claude-code via Homebrew
module ClaudeAutoupdate
  module Update
    module_function

    def run
      puts "Updating claude-code now..."
      puts

      # Get current version
      current_version = get_current_version

      if current_version
        puts "Current version: #{current_version}"
      end

      puts

      # Run update
      run_update

      # Get new version
      new_version = get_current_version

      puts
      if new_version && new_version != current_version
        puts "✅ Updated to version #{new_version}"
      elsif new_version == current_version
        puts "✅ Already up to date (#{new_version})"
      else
        puts "✅ Update complete"
      end

      # Cleanup
      run_cleanup
    end

    def get_current_version
      version_output = `brew info --cask claude-code 2>/dev/null`

      # Parse version from output
      # Format: "claude-code: 1.2.3 (auto_updates)"
      if version_output =~ /claude-code:\s+(\S+)/
        $1
      else
        nil
      end
    end

    def run_update
      puts "Running: brew upgrade --cask claude-code"
      puts

      # Run upgrade (show output to user)
      system("brew", "upgrade", "--cask", "claude-code")
    end

    def run_cleanup
      puts
      puts "Cleaning up..."
      system("brew", "cleanup", "claude-code", out: File::NULL, err: File::NULL)
      puts "✓ Cleanup complete"
    end
  end
end
