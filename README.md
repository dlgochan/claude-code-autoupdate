# claude-code-autoupdate

Automatic updates for **claude-code** installed via **Homebrew**.
One command setup — never see update notifications again.

## Table of Contents

- [Who Needs This?](#who-needs-this)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Commands](#commands)
  - [Custom Intervals](#custom-intervals)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [For AI Agents](#for-ai-agents-installation-guide)
- [License](#license)

## Who Needs This?

| Installation Method | Auto-Updates | Need This Tool? |
|---|---|---|
| `brew install --cask claude-code` | ❌ Manual | ✅ **Yes** |
| `curl -fsSL https://claude.ai/install.sh \| bash` | ✅ Built-in | ❌ No |

> **Not sure?** Run `claude doctor` to check your installation type.

## Quick Start

```bash
brew tap dlgochan/tap
brew install claude-autoupdate
claude-autoupdate enable
```

Done. claude-code now updates automatically every 24 hours.

## Usage

### Commands

| Command | Description |
|---|---|
| `claude-autoupdate enable` | Enable auto-updates (default: 24h) |
| `claude-autoupdate enable -i 12h` | Enable with custom interval |
| `claude-autoupdate disable` | Disable auto-updates |
| `claude-autoupdate status` | Show current status |
| `claude-autoupdate config` | Show configuration |
| `claude-autoupdate update` | Update claude-code right now |

### Custom Intervals

```bash
claude-autoupdate enable -i 6h    # Every 6 hours
claude-autoupdate enable -i 12h   # Every 12 hours
claude-autoupdate enable -i 2d    # Every 2 days
```

Supported range: `1h` ~ `7d` (hours or days)

## How It Works

Creates a macOS LaunchAgent that runs `brew upgrade --cask claude-code` on a schedule.

```
~/Library/LaunchAgents/com.github.dlgochan.claude-autoupdate.plist   # Schedule
~/Library/Application Support/claude-autoupdate/update.sh            # Update script
~/Library/Application Support/claude-autoupdate/config.json          # Config
~/Library/Logs/claude-autoupdate/claude-autoupdate.log               # Logs
```

- Runs at boot + every configured interval
- Low priority background process
- Zero external dependencies

## Troubleshooting

| Problem | Solution |
|---|---|
| Check if it's running | `claude-autoupdate status` |
| View logs | `tail ~/Library/Logs/claude-autoupdate/claude-autoupdate.log` |
| Force update now | `claude-autoupdate update` |
| Change interval | `claude-autoupdate disable` → `claude-autoupdate enable -i 6h` |
| Something went wrong | `claude-autoupdate disable` → `claude-autoupdate enable` |

---

## For AI Agents: Installation Guide

> Step-by-step instructions for AI coding agents (Claude Code, Cursor, etc.) helping a user set up claude-autoupdate.

### Step 1: Verify Installation Type

```bash
brew list --cask claude-code
```

- **Not installed via Homebrew?** → Check `which claude`. If path contains `/.local/`, it's a native install with built-in auto-updates. Explain this to the user and stop.
- **Not installed at all?** → Guide the user: `brew install --cask claude-code`

### Step 2: Install

```bash
brew tap dlgochan/tap
brew install claude-autoupdate
```

### Step 3: Enable

Ask the user their preferred update interval:

| Interval | Who it's for |
|---|---|
| `6h` | Wants the latest ASAP |
| `12h` | Good balance |
| `24h` | Default, recommended |

```bash
claude-autoupdate enable                 # Default 24h
claude-autoupdate enable --interval 12h  # Custom
```

Verify: `claude-autoupdate status` should show `✅ ENABLED`.

> **Notes:** Min `1h`, max `7d`. Also runs at system boot. Logs at `~/Library/Logs/claude-autoupdate/claude-autoupdate.log`.

### Step 4: Inform the User

Tell the user how to manage it later:

- `claude-autoupdate status` — Check status
- `claude-autoupdate disable` → `enable -i <interval>` — Change interval
- `claude-autoupdate update` — Manual update
- `claude-autoupdate disable` — Turn off

---

## License

MIT
