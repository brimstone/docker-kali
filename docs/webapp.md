Generic Webapp Starting Points
==============================

Identify & Enumerate
--------------------

### Identify interesting files on the webserver not linked from the root
```
gobuster -u http://$IP  -w /usr/share/seclists/Discovery/Web_Content/raft-medium-files.txt -e -r -l
```

```
nikto -h $IP > nikto_results
```

Don't forget the obvious ones:
- robots.txt
- license.txt

### Wordpress Identification
```
wpscan --enumerate --threads 20 --batch --log --url http://$IP
```

### Wordpress Enum Users
After generating a users.txt and a pass.txt, give them all a try:
```
hydra -L users.txt -P pass.txt 192.168.100.181 http-form-post \
"/wp-login.php:log=^USER^&pwd=^PASS^:login_error""
```
```
wpscan --log --batch --url $IP  --wordlist ${PWD}/pass.txt --username admin --threads 20
```
