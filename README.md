# PullupBar

A macOS menu-bar app showing your open GitHub pull requests — CI status,
draft/review/conflict tags, and age, with the menu bar badge showing the
open PR count. Click a PR to open it on GitHub; hover a row to check out
its branch locally with one click.

PullupBar shells out to the [`gh`](https://cli.github.com) CLI, so it uses
whatever GitHub account you're already logged into — no tokens are stored and
nothing is tied to a specific account.

## Requirements

- macOS 13 or later
- Xcode or the Swift toolchain (for `swift build`) — install via the App Store or
  [swift.org](https://www.swift.org/install/macos/)
- The GitHub CLI, installed and authenticated:

      brew install gh
      gh auth login

## Build & run

From a terminal:

    swift build
    swift run

As a real app (double-click, Login Item, drag to Applications — no terminal
needed to launch it afterward):

    ./Scripts/build-app.sh
    open .build/PullupBar.app

The app bundle is ad-hoc signed (no Developer ID), so the first time you open a
build on another Mac, Gatekeeper may say it's from an "unidentified developer."
Right-click the app in Finder → **Open** → **Open** to allow it (only needed once).

## Settings

Open the panel from the menu bar and click the gear (bottom-left) to configure:

- **Repository folders** — the folders PullupBar searches for a local clone when
  you check out a PR's branch. Add one per place you keep clones (e.g.
  `~/Documents/GitHub`, `~/code`). Checkout matches a repo by its name inside
  these folders, so if checkout does nothing, make sure the repo is cloned under
  one of them.
- **Refresh interval** — how often open PRs are polled.
- **Closed PRs shown** — how many recent closed/merged PRs to load.

Settings are stored in `UserDefaults` and persist across launches.

## Test

    swift test

## Troubleshooting

- **"Unavailable" instead of PRs** — `gh` isn't installed, isn't on your PATH, or
  isn't authenticated. Run `gh auth status`; if it's installed somewhere unusual,
  PullupBar also checks the common Homebrew/system locations automatically.
- **Checkout does nothing** — the repo isn't cloned under any of your configured
  Repository folders (see Settings above).

## Versioning

The app version is derived from the latest git tag (`git describe`), so tagging a
release is the single source of truth for the version baked into `PullupBar.app`.
