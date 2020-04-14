# kali
A Docker image for various bits of Kali Linux

[![](https://img.shields.io/docker/stars/brimstone/kali.svg)](https://hub.docker.com/r/brimstone/kali 'DockerHub')

## Example: Basic Usage
Get up and going fast for a CTF:
```
docker run --rm -ti --net host -e LHOST=tun0 brimstone/kali:c2 msf
```

This will start `msfconsole` with a postgresql server, ready to rock.

## Tags
### latest [![](https://images.microbadger.com/badges/image/brimstone/kali:latest.svg)](https://microbadger.com/images/brimstone/kali "Get your own image badge on microbadger.com")
All other tags derive from this base.

#### Example: bash
```
docker run --rm -it --net host brimstone/kali
```

### c2 [![](https://images.microbadger.com/badges/image/brimstone/kali:c2.svg)](https://microbadger.com/images/brimstone/kali "Get your own image badge on microbadger.com")
Contains C2 tools like pupy, shellz, metasploit.

#### Example: Armitage
```
docker run --rm -it --net host -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix brimstone/kali armitage
```

### crack [![](https://images.microbadger.com/badges/image/brimstone/kali:crack.svg)](https://microbadger.com/images/brimstone/kali "Get your own image badge on microbadger.com")
Contains cracking tools, passwords mostly.


### gui [![](https://images.microbadger.com/badges/image/brimstone/kali:gui.svg)](https://microbadger.com/images/brimstone/kali "Get your own image badge on microbadger.com")
Contains tools that need a GUI.

#### Example: Zaproxy
```
docker run --rm -it --net host -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix brimstone/kali zaproxy
```

### web [![](https://images.microbadger.com/badges/image/brimstone/kali:web.svg)](https://microbadger.com/images/brimstone/kali "Get your own image badge on microbadger.com")
Contains tools for exploiting web applications.

### wifi [![](https://images.microbadger.com/badges/image/brimstone/kali:wifi.svg)](https://microbadger.com/images/brimstone/kali "Get your own image badge on microbadger.com")
Contains tools for wifi attacks, 802.11 and otherwise.
