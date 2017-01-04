FROM debian:jessie

ENV LHOST=

ENV MSF_DATABASE_CONFIG /usr/share/metasploit-framework/config/database.yml

COPY pax-pre-install /usr/local/sbin/pax-pre-install

RUN /usr/local/sbin/pax-pre-install --install \
 && echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" \
    > /etc/apt/sources.list.d/kali.list \
 && echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" \
    >> /etc/apt/sources.list.d/kali.list \
 && apt-key adv --keyserver pgp.mit.edu --recv-keys ED444FF07D8D0BF6 \

 && apt update \

 && apt install -y --no-install-recommends \
    less vim build-essential libreadline-dev libssl-dev libpq5 \
    libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-8-jre \
    subversion git-core autoconf pgadmin3 curl zlib1g-dev libxml2-dev \
    libxslt1-dev xtightvncviewer libyaml-dev ruby ruby-dev nmap beef-xss \
    mitmproxy postgresql python-pefile net-tools iputils-ping iptables \
    sqlmap zaproxy burpsuite bettercap bdfproxy exploitdb rsync \
	metasploit-framework \

 && gem install wirble sqlite3 bundler \
 && mkdir /pentest

RUN sed -i 's/md5$/trust/g' /etc/postgresql/9.6/main/pg_hba.conf \
 && /etc/init.d/postgresql start \
 && su -c "createuser msf -S -R -D \
 && createdb -O msf msf" postgres

RUN version="$(awk -F \" '/VERSION/ {print $2; exit}' /usr/share/metasploit-framework/lib/metasploit/framework/version.rb)" \
 && git clone -b "$version" https://github.com/rapid7/metasploit-framework.git \
    /pentest/metasploit-framework \
 && rsync -a /usr/share/metasploit-framework/ /pentest/metasploit-framework/ \
 && rm -rf /usr/share/metasploit-framework \
 && mv /pentest/metasploit-framework /usr/share/metasploit-framework \
 && ln -s /usr/share/metasploit-framework /pentest \
 && cd /usr/share/metasploit-framework \
 && git config --global user.email "you@example.com" \
 && git config --global user.name "Your Name" \
 && git stash \
 && git checkout master \
 && git stash pop \
 && bundle install \
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

ADD armitage /bin

ADD loader /

CMD ["/loader"]
WORKDIR /pentest
