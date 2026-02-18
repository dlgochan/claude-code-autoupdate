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

Creates a macOS LaunchAgent that runs `brew upgrade --cask claude-code` at your chosen interval (default: 24h).

**Technical details:**
- LaunchAgent plist: `~/Library/LaunchAgents/com.github.dlgochan.claude-autoupdate.plist`
- Update script: `~/Library/Application Support/claude-autoupdate/update.sh`
- Config: `~/Library/Application Support/claude-autoupdate/config.json`
- Runs at boot + configurable interval (default: 24h)
- Low priority background process

## Troubleshooting

**Check logs**: `tail ~/Library/Logs/claude-autoupdate/claude-autoupdate.log`

**Check status**: `claude-autoupdate status`

**Disable**: `claude-autoupdate disable`

**Manual update**: `claude-autoupdate update`

---

## For AI Agents: Installation Guide

> This section is written for AI coding agents (Claude Code, Cursor, Copilot, etc.) who are helping a user set up claude-autoupdate. Follow these steps in order.

### Step 1: Verify Homebrew Installation

Check if claude-code is installed via Homebrew:
```bash
brew list --cask claude-code
```

**If NOT installed via Homebrew:**
- Check if the user has a native installation: `which claude` — if the path contains `/.local/`, it's native
- Native installations already have auto-updates built-in. Explain this to the user and stop here
- If claude-code is not installed at all, guide the user to install it first: `brew install --cask claude-code`

### Step 2: Install claude-autoupdate

```bash
brew tap dlgochan/tap
brew install claude-autoupdate
```

### Step 3: Enable Auto-Updates

Ask the user how often they want updates to run. Common options:
- `6h` — Every 6 hours (for users who want the latest immediately)
- `12h` — Every 12 hours (good balance)
- `24h` — Once a day (default, recommended for most users)

Then run:
```bash
claude-autoupdate enable                # Uses default 24h interval
claude-autoupdate enable --interval 12h # Or with custom interval
```

Verify it's working:
```bash
claude-autoupdate status
```

**Important notes:**
- Minimum interval is `1h`, maximum is `7d`
- The update runs at system boot as well as at the configured interval
- Logs are written to `~/Library/Logs/claude-autoupdate/claude-autoupdate.log`

### Step 4: Inform the User About Management

Let the user know how to manage auto-updates in the future:
- **Check status**: `claude-autoupdate status`
- **Change interval**: `claude-autoupdate disable` then `claude-autoupdate enable -i <new_interval>`
- **Manual update**: `claude-autoupdate update`
- **Disable completely**: `claude-autoupdate disable`
- **Check logs**: `tail ~/Library/Logs/claude-autoupdate/claude-autoupdate.log`

---

## License

MIT
