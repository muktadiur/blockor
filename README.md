# Blockor
Protect BSD Unix computer servers from brute-force attacks. It works on top of the OpenBSD Packet Filter(PF) firewall.

![Blockor](images/blockor.png)

## Prerequisites
- BSD operating system: FreeBSD, OpenBSD with [ Packet Filter( PF ) ](https://www.openbsd.org/faq/pf/filter.html) enabled.

## Installation
```
git clone https://github.com/muktadiur/blockor.git

# root|doas|sudo required.
cd blockor
make install
```

#### Start blockord at boot
```
blockor enable

or 
sysrc blockord_enable=YES  # FreeBSD
rcctl enable blockord      # OpenBSD
```

#### Add on /etc/pf.conf and run pfctl -f /etc/pf.conf
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
  check         Check blockor.conf file and show config for /etc/pf.conf.
  start         Start the blockord daemon.
  stop          Stop the blockord daemon.
  restart       Restart the blockord daemon.
  enable        Start the blockord daemon at boot.
  disable       Not start the blockord daemon at boot.
  add           Add IP to blocked list.
  remove        Remove IP from blocked list.
  flush         Remove all entries from blocked list.
  list          Show blocked list with the failed count.
  status        Running or Stopped (enabled|disabled) 
Use "blockor -v|--version" for version info.
```


## Example

#### To check config.
```
bsd# blockor check
blockor(ok)
Add to /etc/pf.conf and run pfctl -f /etc/pf.conf(if not already done):
table <blockor> persist
block drop in quick on egress from <blockor> to any
```

#### To start blockord
```
bsd# blockor start
blockord(running)
```

#### To stop blockord
```
bsd# blockor stop
blockord(stopped)
```

#### To restart blockord
```
bsd# blockor restart
blockord(stopped)
blockord(running)
```

#### To remove an IP from blocked list
```
bsd# blockor remove 192.168.56.2
blockor(removed)

# or if multiple
bsd# blockor remove 192.168.56.45 192.168.56.151 192.168.56.152
blockor(removed)
```

#### To block(add) an IP manually
```
bsd# blockor add 192.168.56.2
blockor(ok)

# or if multiple
bsd# blockor add 192.168.56.45 192.168.56.151 192.168.56.152
blockor(ok)

# whitelisted IP will be skipped.
bsd# blockor add 192.168.56.20
blockor(whitelisted. skipped. 192.168.56.20)
```

#### Check status (running|stopped)
```
bsd# blockor status
blockord(running.enabled)

enabled - will start at boot
disabled - will not start at boot
```

#### Show blocked list
```
bsd# blockor list
Total 1 IP(s) blocked
   192.168.56.2
count  IP
  11 192.168.56.2
   2 192.168.56.30
   1 192.168.56.21
```

#### Remove all entries from blocked list
```
bsd# blockor flush
blockor(flushed)
```

## /usr/local/etc/blockor.conf
Change the value of blockor_whitelist, max_tolerance, and search_pattern.
Better not to change others' values.
```
blockord="/usr/local/libexec/blockor/blockord.sh"
blockor="/usr/local/bin/blockor"
blockor_file="/tmp/blockor_blockedlist"
blockor_log_file="/var/log/blockord.log"
blockor_whitelist="192.168.56.20 192.168.56.102"
search_pattern="Disconnected from authenticating user root|Failed password"
max_tolerance=10

auth_file="/var/log/auth.log"     # FreeBSD
auth_file="/var/log/authlog"      # OpenBSD

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


## Source code structure
```
.
├── LICENSE
├── Makefile
├── README.md
├── freebsd
│   └── usr
│       └── local
│           ├── etc
│           │   ├── blockor.conf
│           │   └── rc.d
│           │       └── blockord
│           ├── man
│           │   └── man8
│           │       └── blockor.8.gz
│           └── share
│               └── examples
│                   └── blockor
│                       └── blockor.example.conf
├── images
│   └── blockor.png
├── openbsd
│   ├── etc
│   │   └── rc.d
│   │       └── blockord
│   └── usr
│       └── local
│           ├── etc
│           │   └── blockor.conf
│           ├── man
│           │   └── man8
│           │       └── blockor.8.gz
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