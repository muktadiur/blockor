# Changelog

All notable changes to blockor are documented here.

## [Unreleased]

### Added
- **`blockor test [logfile]`** — a dry run that scans a log and shows which
  addresses would be banned with the current pattern, threshold, and whitelist,
  without touching PF or any state. Use it to tune settings before going live.
- **Lock-out safety** (`protect_active_ssh`, default on) — blockor never
  auto-bans an address that currently has a live SSH session, so a noisy
  reconnect or an over-broad pattern can't lock you out of your own box. The
  SSH port is configurable via `ssh_port`.

## [0.2.0] - 2026-06-23

### Added
- **Expiring bans (`bantime`) and a sliding detection window (`findtime`).**
  An IP is banned only after `max_tolerance` failures *within* `findtime`
  seconds, and is automatically released after `bantime` seconds
  (`bantime=0` keeps it permanent). A background loop expires bans on an
  interval even when the logs are quiet.
- **IPv6 support** throughout detection, validation, banning and whitelisting.
- **Multiple log sources.** Set `auth_files="..."` to watch several logs at once.
- **CIDR whitelist** for IPv4 and IPv6, matched via a PF table.
- **Notifications** on ban/unban: syslog (`logger`), email (`mail`), or a
  custom `notify_command` hook.
- **`blockor reload`** restarts the daemon while keeping the ban list.
- **`blockor top`** shows the busiest offenders within the current window.
- **`blockor check`** now verifies the `<blockor>` table and rule are actually
  loaded, so a misconfigured pf.conf no longer fails silently.
- **Persistent bans** survive a reboot (state moved to `/var/db/blockor`).
- Test harness (`tests/run_tests.sh`) and CI (shellcheck + tests).
- Shared library `blockor.subr` used by both the CLI and the daemon.
- Redesigned, readable command output: `✓`/`✗` markers, a `●` status line,
  aligned tables, and human-readable durations (`52m`, `1h`, `3d`). Color is
  used only on an interactive terminal (honors `NO_COLOR`); pipes and logs stay
  plain. Errors and warnings now go to stderr as `blockor: error: ...`.

### Fixed
- `tail -F` (follow by name) on FreeBSD so detection keeps working after log
  rotation. OpenBSD's `tail` has no `-F`, so it uses `-f` there (restart blockor
  after a rotation on OpenBSD).
- The daemon no longer re-scans the whole history and re-adds every banned IP on
  every log line; it evaluates only the current address and skips IPs already in
  the table.
- State moved out of world-writable `/tmp` (was a local DoS / symlink risk) to
  root-owned `/var/db/blockor` with `0600` files.
- Clean process management via a PID file and signal handling; stopping no
  longer leaks the `tail` child when a non-default log path is used, and uses
  `SIGTERM` (then `SIGKILL`) instead of an immediate `kill -9`.
- Stricter IP validation (octets `0-255`, anchored match).
- `blockor` with no arguments shows usage instead of a `usage: not found` error.
- `make uninstall` removes the daemon from `/usr/local/libexec/blockor/` (the
  old path was wrong, leaving files behind) and stops/disables the service first.
- rc.d default no longer sets the wrong variable; config is sourced only after a
  permission check.
- Spelling: `enable`/`enabled` (was `eanble`/`eanbled`).
