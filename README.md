# Blockor
Protect BSD Unix computer servers from brute-force attacks. It works on top of the OpenBSD Packet Filter(PF) firewall.

## Prerequisites
- BSD operating system: FreeBSD, OpenBSD with [ Packet Filter( PF ) ](https://www.openbsd.org/faq/pf/filter.html) enabled.

## Installation
```
git clone https://github.com/muktadiur/blockor.git
```

#### FreeBSD
```
# root|doas|sudo required.

cd blockor/freebsd
make install
sysrc blockord_enable=YES # automatic start at boot
```
#### OpenBSD
```
# root|doas|sudo required.

cd blockor/openbsd
make install
rcctl enable blockord # automatic start at boot
```

#### Add on /etc/pf.conf
```
table <blockor> persist
block drop in quick on egress from <blockor> to any
```

#### To remove blockor
```
make uninstall
```

## Basic Commands
```
Blockor protects FreeBSD, OpenBSD servers from brute-force attacks.
Usage:
  blockor command [args]
Available Commands:
  check         Check blockor.conf file and show config for pf.conf.
  start         Start the blockord daemon.
  stop          Stop the blockord daemon.
  add           Add IP to blocked list.
  remove        Remove IP from blocked list.
  list          Show blocked list with the failed count.
  status        Running or Stopped.
Use "blockor -v|--version" for version info.
```


## Example

#### To check config.
```
root@freebsd:~ # blockor check
blockor(ok)
Add these two lines to /etc/pf.conf (if not done already):
table <blockor> persist
block drop in quick on egress from <blockor> to any
```

#### To start blockord
```
root@freebsd:~ # blockor start
blockord(ok)
```

#### To stop blockord
```
root@freebsd:~ # blockor stop
blockord(stopped)
```

#### To remove from blocked list
```
root@freebsd:~ # blockor remove 192.168.56.2
192.168.56.2
1/1 addresses deleted.
blockor(removed)
```

#### To add manually to blocked list
```
root@freebsd:~ # blockor add 192.168.56.2
1/1 addresses added.
blockor(added)

whitelisted IP will be skipped.

root@freebsd:~ # blockor add 192.168.56.20
blockor(whitelisted. skipped)
```

#### Check status (running/stopped)
```
root@freebsd:~ # blockor status
blockord(running)
```

#### Show blocked list
```
root@freebsd:~ # blockor list
Total 1 IP(s) blocked
   192.168.56.2
count  IP
  15 192.168.56.2
   2 192.168.56.30
   1 192.168.56.21
```

## /usr/local/etc/blockor.conf
Change the value of max_tolerance, and search_pattern only.
Do not change others' values.
```
blockord="/usr/local/libexec/blockor/blockord.sh"
blockor="/usr/local/bin/blockor"
blockor_file="/tmp/blockor_blacklist"
blockor_log_file="/var/log/blockord.log"
blockor_whitelist="192.168.56.20 192.168.56.102"
search_pattern="Disconnected from authenticating user root|Failed password"
max_tolerance=10
```

#### FreeBSD
```
auth_file="/var/log/auth.log"
```
#### OpenBSD
```
auth_file="/var/log/authlog"
```

#### max_tolerance=10
```
IP will be blocked when more than 10 failed activities. Change to any number.
```
#### search_pattern
```
Add any text pattern with delimiter |
example: search_pattern="Bad protocol version identification|..other patterns"
```
#### blockor_whitelist
```
IP in blockor_whitelist will be excluded from blocking. Add IP with space-separated.
blockor_whitelist="192.168.56.20 192.168.56.102"

```


## Project Structure
```
.
├── LICENSE
├── README.md
├── freebsd
│   ├── Makefile
│   └── usr
│       └── local
│           ├── etc
│           │   ├── blockor.conf
│           │   └── rc.d
│           │       └── blockord
│           └── share
│               └── examples
│                   └── blockor
│                       └── blockor.example.conf
├── openbsd
│   ├── Makefile
│   ├── etc
│   │   └── rc.d
│   │       └── blockord
│   └── usr
│       └── local
│           ├── etc
│           │   └── blockor.conf
│           └── share
│               └── examples
│                   └── blockor
│                       └── blockor.sample.conf
└── usr
    └── local
        ├── bin
        │   └── blockor
        └── libexec
            └── blockor
                └── blockord.sh
```