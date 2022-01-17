# Blockor
Protect BSD Unix computer servers from brute-force attacks. It works on top of the OpenBSD Packet Filter(PF) firewall.


## Installation
```
git clone https://github.com/muktadiur/blockor.git

cd blockor/freebsd
or 
cd blockor/openbsd

make install
```

### To remove blockor
```
make uninstall
```


## Basic Commands
```
Blockor protects FreeBSD, OpenBSD servers from brute-force attacks.
Usage:
  blockor command [args]
Available Commands:
  check         Check blockor.conf file and show "pf.conf" config.
  start         Start the blockord daemon.
  stop          Stop the blockord daemon.
  add           Add IP to blocked list.
  remove        Remove IP from blocked list.
  list          Show blocked list with the failed count.
  status        Running or Stopped.
Use "blockor -v|--version" for version info.
Use "blockor command -h|--help" for more info.
```


## Example

### To check blockor config file.
```
blockor check
```

### Add following lines on etc/pf.conf
```
table <blockor> persist
block drop in quick on egress from <blockor> to any
```

### To start the blockor daemon
```
blockor start
```

### To stop the blockor daemon
```
blockor stop
```

### To remove an IP from blocked list
```
blockor remove 192.168.56.2
```

