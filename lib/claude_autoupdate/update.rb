# frozen_string_literal: true

require_relative "core"

# brew upgrade --cask claude-code를 즉시 실행
module ClaudeAutoupdate
  module Update
    module_function

    def run
      puts "Updating claude-code now..."
      puts

      current = get_version
      puts "Current version: #{current}" if current
      puts

      system("brew", "upgrade", "--cask", "claude-code")

      new_ver = get_version
      puts
      if new_ver && new_ver != current
        puts "✅ Updated to version #{new_ver}"
      elsif new_ver
        puts "✅ Already up to date (#{new_ver})"
      else
        puts "✅ Update complete"
      end

      system("brew", "cleanup", "claude-code", out: File::NULL, err: File::NULL)
    end

    def get_version
      output = `brew info --cask claude-code 2>/dev/null`
      $1 if output =~ /claude-code:\s+(\S+)/
    end
  end
end
