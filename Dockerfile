FROM debian:stretch

ARG BUILD_DATE
ARG VCS_REF
ARG DEPENDENCY_BUSTER

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/brimstone/docker-kali" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

ENV LHOST= \
    MSF_DATABASE_CONFIG=/usr/share/metasploit-framework/config/database.yml

COPY pax-pre-install /usr/local/sbin/pax-pre-install

RUN echo $DEPENDENCY_BUSTER > /dev/null

RUN /usr/local/sbin/pax-pre-install --install \
 && echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" \
    > /etc/apt/sources.list.d/kali.list \
 && echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" \
    >> /etc/apt/sources.list.d/kali.list \
 && apt-key adv --keyserver pgp.mit.edu --recv-keys ED444FF07D8D0BF6 \

 && apt update \

 && apt install -y --no-install-recommends \
    less vim build-essential libreadline-dev libssl-dev libpq5 \
    libpq-dev libreadline5 libsqlite3-dev libpcap-dev \
    subversion git-core autoconf pgadmin3 curl zlib1g-dev libxml2-dev \
    libxslt1-dev xtightvncviewer libyaml-dev ruby ruby-dev nmap beef-xss \
    mitmproxy postgresql python-pefile net-tools iputils-ping iptables \
    sqlmap bettercap bdfproxy rsync enum4linux openssh-client \
	mfoc mfcuk libnfc-bin hydra gobuster nikto wpscan \
 && rm -rf /var/lib/apt/lists

# I'm trying to split up this layer so it's more palatable to download
RUN apt update \
 && apt install -y --no-install-recommends \
	burpsuite openjdk-8-jre zaproxy exploitdb \
 && rm -rf /var/lib/apt/lists

RUN gem install wirble sqlite3 bundler \
 && mkdir /pentest

RUN sed -i 's/md5$/trust/g' /etc/postgresql/9.6/main/pg_hba.conf \
 && /etc/init.d/postgresql start \
 && su -c "createuser msf -S -R -D \
 && createdb -O msf msf" postgres

# Update metasploit the hard way
# There's something dumb about what the package does to work with system ruby
RUN apt update \
 && apt install -y --no-install-recommends \
	metasploit-framework \
 && rm -rf /var/lib/apt/lists \
 && version="$(msfconsole -v 2>&1 | sed 's/^.*: //g;s/-.*$//')" \
 && echo "Checking out metasploit-framework version $version" \
 && git clone -b "$version" https://github.com/rapid7/metasploit-framework.git \
    /pentest/metasploit-framework \
 && mv /pentest/metasploit-framework/.git /usr/share/metasploit-framework/ \
 && rm -rf /pentest/metasploit-framework \
 && mv /usr/share/metasploit-framework /pentest/metasploit-framework \
 && ln -s /pentest/metasploit-framework /usr/share/ \
 && cd /pentest/metasploit-framework \
 && git config --global user.email "you@example.com" \
 && git config --global user.name "Your Name" \
 && git stash \
 && git checkout master \
 && git stash pop || true \
 && git checkout HEAD -- Gemfile.lock \
 && bundle install --no-deployment \
 && echo "Saving $(du -hs .git) by removing .git" \
 && rm -rf .git \
 && echo "production:" > $MSF_DATABASE_CONFIG \
 && echo " adapter: postgresql" >> $MSF_DATABASE_CONFIG \
 && echo " database: msf" >> $MSF_DATABASE_CONFIG \
 && echo " username: msf" >> $MSF_DATABASE_CONFIG \
 && echo " password: msf" >> $MSF_DATABASE_CONFIG \
 && echo " host: 127.0.0.1" >> $MSF_DATABASE_CONFIG \
 && echo " port: 5432" >> $MSF_DATABASE_CONFIG \
 && echo " pool: 75" >> $MSF_DATABASE_CONFIG \
 && echo " timeout: 5" >> $MSF_DATABASE_CONFIG \
 && curl -L https://raw.githubusercontent.com/darkoperator/Metasploit-Plugins/master/pentest.rb \
    > /pentest/metasploit-framework/plugins/pentest.rb

RUN curl http://fastandeasyhacking.com/download/armitage150813.tgz \
  | tar -zxC /pentest/

RUN git https://github.com/danielmiessler/SecLists /pentest/seclists --depth 0 \
 && rm -rf /pentest/seclists/.git

ADD bin/* /bin/

ADD loader /

RUN /loader cache build

ENTRYPOINT ["/loader"]
WORKDIR /pentest
