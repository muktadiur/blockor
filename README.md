# Blockor
Protect FreeBSD and OpenBSD servers from brute-force attacks. Blockor watches
your auth logs, counts failed attempts per source address inside a time window,
and blocks offenders using the OpenBSD Packet Filter (PF) `<blockor>` table.

![Blockor](images/blockor.png)

It is a small, dependency-free set of `/bin/sh` scripts — no Python, no extra
packages. It complements PF's native connection-rate limiting: rate limiting
catches floods, while blockor catches *credential* brute-force where each
attempt completes a normal TCP connection and only the log shows the failure.

## Features
- Sliding **detection window** (`findtime`) and **auto-expiring bans** (`bantime`).
- **IPv4 and IPv6** detection, banning and whitelisting.
- **CIDR whitelist** (e.g. keep your office `10.0.0.0/8` safe).
- Watch **multiple log sources** at once (`auth_files`).
- **Notifications** on ban/unban: syslog, email, or a custom command.
- Bans **persist across reboots**.
- Follows logs across **rotation** by name on FreeBSD (`tail -F`); on OpenBSD
  (`tail -f`), restart blockor after a log rotation.

## Prerequisites
- FreeBSD or OpenBSD with [Packet Filter (PF)](https://www.openbsd.org/faq/pf/filter.html) enabled.

## Installation
```
git clone https://github.com/muktadiur/blockor.git

# root|doas|sudo required.
cd blockor
make install
```

### 1. Add the PF table and rule to /etc/pf.conf
```
table <blockor> persist
block drop in quick on egress from <blockor> to any
```
Then reload PF:
```
pfctl -f /etc/pf.conf
```

### 2. Verify the setup
```
blockor check
```
`check` warns loudly if the `<blockor>` table or rule is not actually loaded, so
you are never silently unprotected.

### 3. Start at boot and run
```
blockor enable
blockor start

# enable is equivalent to:
sysrc blockord_enable=YES   # FreeBSD
rcctl enable blockord       # OpenBSD
```

### Uninstall
```
make uninstall
```
State in `/var/db/blockor` and the log in `/var/log/blockord.log` are kept; remove
them by hand if you no longer want the history.

## Commands
```
blockor command [args]

  check         Check blockor.conf and the PF setup, show config for /etc/pf.conf.
  start         Start the blockord daemon.
  stop          Stop the blockord daemon.
  restart       Restart the blockord daemon.
  reload        Restart the daemon, keeping the current ban list.
  enable        Start the blockord daemon at boot.
  disable       Do not start the blockord daemon at boot.
  add           Add IP(s) to the blocked list (permanent).
  remove        Remove IP(s) from the blocked list.
  flush         Remove all entries from the blocked list.
  list          Show blocked IPs with failure count and time left.
  top           Show top offenders seen within the findtime window.
  status        Running or Stopped (enabled|disabled).
```

## Examples

Output uses ✓/✗ markers and color on an interactive terminal, and plain text
when piped or redirected (also honors `NO_COLOR`). Errors and warnings go to
stderr.

```
# Verify configuration and PF wiring
bsd# blockor check
Checking blockor configuration

  ✓  pf enabled
  ✓  table <blockor> loaded
  ✓  blocking rule present
  ✓  log readable  /var/log/auth.log

All checks passed.

# Start / stop / reload (reload keeps the ban list)
bsd# blockor start
Started blockord (pid 4123).
bsd# blockor reload
Stopped blockord.
Started blockord (pid 4140).

# Block manually (IPv4 or IPv6, one or many). Whitelisted IPs are skipped.
bsd# blockor add 192.168.56.2 2001:db8::1
Blocked 2 address(es): 192.168.56.2, 2001:db8::1
bsd# blockor add 192.168.56.20
Skipped (whitelisted): 192.168.56.20

# Unblock
bsd# blockor remove 192.168.56.2
Unblocked 1 address(es): 192.168.56.2

# What is blocked right now, with remaining ban time
bsd# blockor list
2 address(es) blocked

ADDRESS                                  FAILURES   EXPIRES IN
203.0.113.7                                    14   52m
2001:db8::dead                                  3   59m
192.168.56.2                                    -   permanent

# Busiest offenders in the current window
bsd# blockor top
Top offenders — last 10m

FAILURES   ADDRESS
      14   203.0.113.7
       3   198.51.100.9

# Status
bsd# blockor status
●  blockord — running   (enabled at boot, pid 4140)

# Remove everything
bsd# blockor flush
Flushed — removed 3 address(es) from the block list.
```

## Configuration: /usr/local/etc/blockor.conf
The file is sourced as `/bin/sh`; keep it root-owned and not group/world
writable (blockor refuses to run otherwise).

```sh
auth_file="/var/log/auth.log"     # FreeBSD ( /var/log/authlog on OpenBSD )
# auth_files="/var/log/auth.log /var/log/maillog"   # watch several at once

search_pattern="PAM: Authentication error|Failed password|Invalid user|..."
max_tolerance=10        # ban after this many failures within findtime
findtime=600            # sliding window in seconds (10 minutes)
bantime=3600            # ban duration in seconds; 0 = permanent
expire_interval=60      # how often (seconds) expired bans are released

blockor_whitelist="192.168.56.20 10.0.0.0/8 2001:db8::/32"

notify_syslog="YES"     # log bans/unbans via logger(1)
notify_email=""         # email address; requires mail(1)
notify_command=""       # external hook: cmd <ban|unban> <ip> <count>
```

### max_tolerance
An IP is blocked once it exceeds this many failed attempts **within `findtime`
seconds**. Old failures age out of the window, so occasional typos do not
accumulate into a ban.

### bantime
How long a ban lasts before it is automatically lifted. Use `0` for permanent
bans. Manual `blockor add` entries are always permanent.

### search_pattern
Extended-regex patterns that mark a failed attempt, separated by `|`:
```
search_pattern="Bad protocol version identification|Failed password"
```

### blockor_whitelist
Space-separated IPs and/or CIDR ranges (IPv4 and IPv6). These are never blocked.

### Notifications (optional)
- `notify_syslog="YES"` logs each ban/unban via `logger(1)`.
- `notify_email="you@example.com"` emails on each event (needs `mail(1)`).
- `notify_command="/path/to/hook"` runs your script as
  `hook <ban|unban> <ip> <count>`.

## Files
```
/usr/local/bin/blockor                  CLI
/usr/local/libexec/blockor/blockord.sh  log watcher daemon
/usr/local/libexec/blockor/blockor.subr shared functions
/usr/local/etc/blockor.conf             configuration
/var/db/blockor/bans                    active bans (persist across reboot)
/var/db/blockor/failures                recent failures (findtime window)
/var/run/blockor/blockord.pid           daemon pid
/var/log/blockord.log                   daemon log
```

## Development
```
make test          # run the test harness (stubs pfctl, no real PF needed)
```
See [CONTRIBUTING.md](CONTRIBUTING.md).

## Source code structure
```
├── LICENSE
├── Makefile
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── tests
│   └── run_tests.sh
├── usr
│   └── local
│       ├── bin
│       │   └── blockor
│       └── libexec
│           └── blockor
│               ├── blockord.sh
│               └── blockor.subr
├── freebsd
│   └── usr/local/{etc,man,share}      conf, rc.d, man page, example
└── openbsd
    ├── etc/rc.d/blockord
    └── usr/local/{etc,man,share}      conf, man page, sample
```
