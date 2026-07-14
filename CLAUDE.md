# PullupBar

macOS menu-bar app (SwiftPM) showing open GitHub PRs. Shells out to the `gh` CLI.

## Installing / reinstalling to /Applications

Build the bundle with `./Scripts/build-app.sh` (outputs `.build/PullupBar.app`).

To (re)install into `/Applications`, quit the running app first, then sync with
`ditto` — **not** `cp -R`:

    pkill -x PullupBar
    ditto .build/PullupBar.app /Applications/PullupBar.app

`cp -R src dst` where `dst` already exists as a directory copies *into* it,
producing a nested `/Applications/PullupBar.app/PullupBar.app`. `ditto` overwrites
the bundle contents in place. After a `ditto` overwrite the ad-hoc signature stays
valid (`codesign --verify --deep --strict` passes).

## Launch at login

Controlled in-app via the Settings → "Launch at login" toggle, backed by
`SMAppService.mainApp` ([LaunchAtLogin.swift](Sources/PullupBar/Services/LaunchAtLogin.swift)).
`SMAppService` is the single source of truth — do not also add a System Events /
`osascript` login item, or the app launches twice at login. Registration only works
from a real bundle in a stable location (e.g. `/Applications`), not a `swift run` binary.
