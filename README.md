# claude-code-autoupdate

Automatic updates for **claude-code** installed via **Homebrew**. One command setup - never see update notifications again.

## Who needs this?

✅ **You installed claude-code via Homebrew**
```sh
brew install --cask claude-code
```

❌ **You used the native installer** (already has auto-updates!)
```sh
curl -fsSL https://claude.ai/install.sh | bash
```

<details>
<summary>How to check your installation type</summary>

Run `claude doctor` to see your installation type:
- **Native**: Auto-updates already enabled, you don't need this tool
- **Homebrew**: This tool will help you enable auto-updates
</details>

## Why?

Homebrew installations don't auto-update. Stop seeing update notifications - enable auto-updates once, forget about it forever.

## Installation

```bash
brew tap dlgochan/tap
brew install claude-autoupdate
```

## Usage

Enable auto-updates (default: 24 hours):
```bash
claude-autoupdate enable
```

Enable with custom interval:
```bash
claude-autoupdate enable --interval 12h   # Every 12 hours
claude-autoupdate enable -i 6h            # Every 6 hours
claude-autoupdate enable -i 2d            # Every 2 days
```

Done! Updates run automatically at your chosen interval + at boot.

### Commands

```bash
claude-autoupdate enable           # Enable auto-updates (24h default)
claude-autoupdate enable -i 12h    # Enable with custom interval
claude-autoupdate status           # Check current status
claude-autoupdate config           # Show configuration
claude-autoupdate update           # Update now manually
claude-autoupdate disable          # Disable auto-updates
```

### Supported Intervals

- **Hours**: `6h`, `12h`, `24h` (minimum: 1h)
- **Days**: `1d`, `2d`, `7d` (maximum: 7d)

## How It Works

Creates a macOS LaunchAgent that runs `brew upgrade --cask claude-code` every 24 hours.

**Technical details:**
- LaunchAgent plist: `~/Library/LaunchAgents/com.github.dlgochan.claude-autoupdate.plist`
- Update script: `~/Library/Application Support/claude-autoupdate/update.sh`
- Runs at boot and every 86400 seconds (24 hours)
- Low priority background process

## Troubleshooting

**Check logs**: `tail ~/Library/Logs/claude-autoupdate/claude-autoupdate.log`

**Check status**: `claude-autoupdate status`

**Disable**: `claude-autoupdate disable`

**Manual update**: `claude-autoupdate update`

## License

MIT
