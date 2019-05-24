FROM debian:stretch

ARG BUILD_DATE
ARG VCS_REF

RUN apt update \
 && apt install -y --no-install-recommends \
	gnupg2 dirmngr \
 && apt clean \
 && rm -rf /var/lib/apt/lists

COPY kali.pub /etc/apt/kali.pub

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" \
    > /etc/apt/sources.list.d/kali.list \
 && echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" \
    >> /etc/apt/sources.list.d/kali.list \
 && apt-key add /etc/apt/kali.pub \
 && apt update \
 && apt install -y --no-install-recommends \
    less vim build-essential libreadline-dev libssl-dev libpq5 \
    libpq-dev libreadline5 libsqlite3-dev libpcap-dev \
    subversion git-core autoconf pgadmin3 curl zlib1g-dev libxml2-dev \
    libxslt1-dev xtightvncviewer libyaml-dev ruby ruby-dev nmap beef-xss \
    mitmproxy python-pefile net-tools iputils-ping iptables \
    sqlmap bettercap bdfproxy rsync enum4linux openssh-client \
	mfoc mfcuk libnfc-bin hydra nikto weevely netcat-traditional \
    aircrack-ng pyrit cowpatty pciutils kmod wget unicornscan ftp wfuzz \
    python-pip moreutils upx john \
 && apt clean \
 && rm -rf /var/lib/apt/lists \
 && curl https://github.com/brimstone/gobuster/releases/download/1.3-opt/gobuster \
    -Lo /usr/bin/gobuster \
 && chmod 755 /usr/bin/gobuster

# I'm trying to split up this layer so it's more palatable to download
RUN apt update \
 && apt install -y --no-install-recommends \
	burpsuite openjdk-8-jre zaproxy exploitdb \
 && apt clean \
 && rm -rf /var/lib/apt/lists

RUN git clone https://github.com/brimstone/SecLists /pentest/seclists --depth 1 \
 && rm -rf /pentest/seclists/.git \
 && git clone https://github.com/FireFart/msfpayloadgenerator /pentest/msfpayloadgenerator --depth 1 \
 && rm -rf /pentest/msfpayloadgenerator/.git \
 && wget https://github.com/Charliedean/NetcatUP/raw/master/netcatup.sh -O /bin/netcatup.sh \
 && git clone https://github.com/derv82/wifite /opt/wifite --depth 1 \
 && ln -s /opt/wifite/wifite.py /sbin/wifite

# empire
RUN apt update \
 && apt install -y --no-install-recommends \
    python-iptools python-netifaces python-pydispatch python-zlib-wrapper \
    python-m2crypto python-macholib python-xlrd python-xlutils python-dropbox \
    python-pyminifier \
 && apt clean \
 && rm -rf /var/lib/apt/lists \
 && git clone -b dev https://github.com/EmpireProject/Empire /pentest/empire \
 && cd /pentest/empire \
 && printf "\n" | python setup/setup_database.py \
 && chmod 755 empire \
 && mkdir lib/modules/python/brimstone

COPY empire/* /pentest/empire/lib/modules/python/brimstone

# pupy
RUN apt update \
 && apt install -y --no-install-recommends \
    python-dev python-setuptools \
 && apt clean \
 && rm -rf /var/lib/apt/lists \
 && git clone --recursive https://github.com/n1nj4sec/pupy /pentest/pupy \
 && cd /pentest/pupy \
 && cd pupy \
 && pip install -r requirements.txt \
 && cd /pentest/pupy/pupy \
 && wget https://github.com/n1nj4sec/pupy/releases/download/latest/payload_templates.txz \
 && tar xvf payload_templates.txz \
 && rm payload_templates.txz

# msf python
RUN apt update \
 && apt install -y --no-install-recommends \
    python3-pip python3-setuptools \
 && apt clean \
 && rm -rf /var/lib/apt/lists \
 && pip3 install pymetasploit3

COPY bashrc /root/.bashrc

COPY lists /pentest/lists

COPY bin/* /usr/local/bin/

COPY share /pentest/share

COPY ssh_config /etc/ssh/ssh_config

RUN chown root:root /etc/ssh/ssh_config \
 && mkdir /root/.ssh \
 && chmod 700 /root/.ssh

WORKDIR /pentest

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/brimstone/docker-kali" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"
