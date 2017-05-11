Generic Linux Starting Points
=============================

Identify & Enumerate
--------------------

https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/

### suid binaries
```
find / -perm /6000 -type f 2>/dev/null
```
