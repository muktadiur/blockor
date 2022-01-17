# Blockor
Protect BSD Unix computer servers from brute-force attacks. It works on top of the OpenBSD Packet Filter(PF) firewall.


## Installation
```
git clone https://github.com/muktadiur/blockor.git
cd blockor
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
  init          Create blockor.conf file with a default value.
  start         Start the blockord.
  stop          Stop the blockord.
  add         	Add IP to blocked IP list.
  delete        Remove IP from blocked IP list.
  list          List blocked IP list. With '-all' will show the IP list with the failed count.
  status        Blocked IP list summary.
Use "blockor -v|--version" for version info.
Use "blockor command -h|--help" for more info.
```


## Example

### To create blockor config file.
```
blockor init
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

### To delete an IP from blocked list
```
blockor delete 192.168.56.2
```

