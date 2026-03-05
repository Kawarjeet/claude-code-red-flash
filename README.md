# Claude Code Red Flash Hook

A simple Claude Code hook that flashes your terminal red when Claude is waiting for your input. Never miss when Claude finishes a task again.

## The Problem

Claude Code runs autonomously, but when it stops and waits for input, there's no visual signal. If you're on another screen or tab, you have no idea it's waiting.

## The Solution

Two bash scripts (~40 lines total) that hook into Claude Code's lifecycle:

- **`red-bg.sh`** — Flashes the terminal between red and black. Once you touch your keyboard or mouse, it settles on a solid dark red background.
- **`reset-bg.sh`** — Resets the terminal back to normal (black background, white text).

### Hook triggers

| Event | Script | Why |
|---|---|---|
| `SessionStart` | `red-bg.sh` | Flash until you start typing |
| `Stop` | `red-bg.sh` | Claude finished — your turn |
| `UserPromptSubmit` | `reset-bg.sh` | You're typing — back to normal |
| `SessionEnd` | `reset-bg.sh` | Clean up on exit |

## How It Works

The flash script polls macOS `HIDIdleTime` via `ioreg` to detect any keyboard or mouse input — **no accessibility permissions needed**. When it detects input, the flashing stops and the background settles on solid dark red so you know Claude is waiting.

## Installation

### 1. Copy the scripts

```bash
mkdir -p ~/.claude/hooks
cp red-bg.sh reset-bg.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/red-bg.sh ~/.claude/hooks/reset-bg.sh
```

### 2. Add hooks to your Claude Code settings

Add this to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/red-bg.sh",
            "async": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/red-bg.sh",
            "async": true
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/reset-bg.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/reset-bg.sh"
          }
        ]
      }
    ]
  }
}
```

## Requirements

- macOS (uses `ioreg` for HID idle time detection)
- A terminal that supports ANSI escape codes for background color (iTerm2, Terminal.app, Ghostty, etc.)
- Claude Code

## How It Looks

| State | Terminal |
|---|---|
| Claude is working | Normal (black background) |
| Claude finished, you haven't noticed | Flashing red/black |
| Claude finished, you looked | Solid dark red |
| You submitted a prompt | Back to normal |

## License

MIT
