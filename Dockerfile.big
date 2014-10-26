FROM brimstone/kali:metasploit

RUN apt-get update \
 && apt-get install -y beef-xss mitmproxy \

 && apt-get clean \
 && rm -rf /var/lib/apt/lists \
 && mkdir /pentest

WORKDIR /pentest

RUN git clone --recursive https://github.com/secretsquirrel/BDFProxy.git bdfproxy \
 && cd bdfproxy \
 && git submodule foreach git pull origin master
