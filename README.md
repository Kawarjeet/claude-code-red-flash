# Claude Code Red Flash Hook

A simple Claude Code hook that flashes your terminal when Claude is waiting for your input. Never miss when Claude finishes a task again.

## The Problem

Claude Code runs autonomously, but when it stops and waits for input, there's no visual signal. If you're on another screen or tab, you have no idea it's waiting.

## The Solution

Two bash scripts that hook into Claude Code's lifecycle:

- **`red-bg.sh`** — Flashes the terminal between light green and dark green. Once you touch your keyboard or mouse, it settles on a solid light green background. Uses light mint green (`#C8E6C9`) — the easiest color for human eyes (green sits at peak cone sensitivity).
- **`reset-bg.sh`** — Switches to a white background with dark text palette, so all text remains readable.

Both scripts remap the full ANSI palette (16 colors + extended) to ensure all text is readable against the background — including true-color text rendered by Claude Code.

### Hook triggers

| Event | Script | Why |
|---|---|---|
| `SessionStart` | `red-bg.sh` | Flash until you start typing |
| `Stop` | `red-bg.sh` | Claude finished — your turn |
| `UserPromptSubmit` | `reset-bg.sh` | You're typing — back to normal |
| `SessionEnd` | `reset-bg.sh` | Clean up on exit |

## How It Works

The flash script polls macOS `HIDIdleTime` via `ioreg` to detect any keyboard or mouse input — **no accessibility permissions needed**. When it detects input, the flashing stops and the background settles on solid light green so you know Claude is waiting.

Escape sequences are written to temp files to avoid nested-quoting issues in subshells — ensuring palette remaps actually apply.

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
| Claude is working | White background, dark text |
| Claude finished, you haven't noticed | Flashing green/dark |
| Claude finished, you looked | Solid light green |
| You submitted a prompt | Back to white |

## License

MIT
