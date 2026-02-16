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

Enable auto-updates:
```bash
brew claude-autoupdate install
```

Done! Updates run every 24 hours + at boot.

### Commands

- `install` - Enable auto-updates
- `status` - Check current status
- `update` - Update now manually
- `uninstall` - Disable auto-updates

## How It Works

Creates a macOS LaunchAgent that runs `brew upgrade --cask claude-code` every 24 hours.

**Technical details:**
- LaunchAgent plist: `~/Library/LaunchAgents/com.github.dlgochan.claude-autoupdate.plist`
- Update script: `~/Library/Application Support/claude-autoupdate/update.sh`
- Runs at boot and every 86400 seconds (24 hours)
- Low priority background process

## Troubleshooting

**Check logs**: `tail ~/Library/Logs/claude-autoupdate/claude-autoupdate.log`

**Check status**: `brew claude-autoupdate status`

**Disable temporarily**: `brew claude-autoupdate uninstall`

**Manual update**: `brew claude-autoupdate update`

## License

MIT
