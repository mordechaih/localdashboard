# LocalDashboard

A macOS menubar app showing Claude Code usage %, active sessions
(context window %, running cost), and your open GitHub pull requests —
independent of any terminal statusline, so it works the same whether
Claude Code runs in a terminal or the desktop app.

## Features

- **Usage** — Anthropic usage-window percentage, $ used / $ limit.
- **Sessions** — every live Claude Code session (desktop + terminal),
  with context-window % and running cost per session.
- **Pull Requests** — your open PRs across all repos, with CI status,
  draft/review/conflict tags, and age. The menu bar badge shows the
  open PR count.

Each section degrades independently to an "Unavailable" state if its
data source fails — one broken source never blocks the rest of the panel.

## Build & run

    swift build
    swift run

## Test

    swift test

## Requirements

- macOS 13+
- `gh` CLI, authenticated (`gh auth login`), for the pull requests section
- Claude Code Keychain credentials present (`Claude Code-credentials`), for the usage section
- Launch via `swift run` (or a terminal) so `gh` resolves through your shell's `PATH` — a `.app` bundle launched from Finder may not inherit it.
