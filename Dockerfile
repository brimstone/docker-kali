FROM debian:buster
SHELL ["/bin/bash", "-c"]

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
    less vim build-essential libssl-dev \
    libpq-dev libreadline5 libsqlite3-dev libpcap-dev \
    git-core autoconf curl zlib1g-dev libxml2-dev \
    libxslt1-dev libyaml-dev ruby ruby-dev nmap \
    python-pefile net-tools iputils-ping iptables \
    rsync openssh-client \
	netcat-traditional \
    pciutils kmod wget ftp \
    moreutils upx file \
 && apt clean \
 && rm -rf /var/lib/apt/lists

RUN git clone https://github.com/brimstone/SecLists /pentest/seclists --depth 1 \
 && rm -rf /pentest/seclists/.git \
 && wget https://github.com/Charliedean/NetcatUP/raw/master/netcatup.sh -O /bin/netcatup.sh

COPY bashrc /root/.bashrc

COPY lists /pentest/lists

COPY bin/* /usr/local/bin/

COPY share /pentest/share

COPY ssh_config /etc/ssh/ssh_config

RUN chown root:root /etc/ssh/ssh_config \
 && mkdir /root/.ssh \
 && chmod 700 /root/.ssh

WORKDIR /pentest

ENV USER=root

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/brimstone/docker-kali" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"
