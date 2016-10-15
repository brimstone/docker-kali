FROM debian:jessie

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" \
    > /etc/apt/sources.list.d/kali.list \
 && echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" \
    >> /etc/apt/sources.list.d/kali.list \
 && apt-key adv --keyserver pgp.mit.edu --recv-keys ED444FF07D8D0BF6 \

 && apt-get update

RUN apt-get install -y --no-install-recommends \
    less vim build-essential libreadline-dev libssl-dev libpq5 \
    libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre \
    subversion git-core autoconf pgadmin3 curl zlib1g-dev libxml2-dev \
    libxslt1-dev vncviewer libyaml-dev ruby ruby-dev nmap beef-xss \
    mitmproxy postgresql python-pefile net-tools iputils-ping iptables \
    sqlmap zaproxy burpsuite \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists \

 && gem install wirble sqlite3 bundler bettercap \
 && mkdir /pentest

RUN sed -i 's/md5$/trust/g' /etc/postgresql/9.6/main/pg_hba.conf \
 && /etc/init.d/postgresql start \
 && su -c "createuser msf -S -R -D \
 && createdb -O msf msf" postgres

env MSF_DATABASE_CONFIG /pentest/metasploit-framework/config/database.yml

RUN git clone --depth 1 https://github.com/rapid7/metasploit-framework.git \
    /pentest/metasploit-framework \
 && cd /pentest/metasploit-framework \
 && bundle install \
 && for MSF in $(ls msf*); do ln -s /pentest/metasploit-framework/$MSF \
    /usr/local/bin/$MSF;done \
 && echo "production:" > $MSF_DATABASE_CONFIG \
 && echo " adapter: postgresql" >> $MSF_DATABASE_CONFIG \
 && echo " database: msf" >> $MSF_DATABASE_CONFIG \
 && echo " username: msf" >> $MSF_DATABASE_CONFIG \
 && echo " password:" >> $MSF_DATABASE_CONFIG \
 && echo " host: 127.0.0.1" >> $MSF_DATABASE_CONFIG \
 && echo " port: 5432" >> $MSF_DATABASE_CONFIG \
 && echo " pool: 75" >> $MSF_DATABASE_CONFIG \
 && echo " timeout: 5" >> $MSF_DATABASE_CONFIG \
 && curl -L https://raw.githubusercontent.com/darkoperator/Metasploit-Plugins/master/pentest.rb \
    > /pentest/metasploit-framework/plugins/pentest.rb

RUN git clone --recursive https://github.com/secretsquirrel/BDFProxy.git \
    /pentest/bdfproxy \
 && cd /pentest/bdfproxy/bdf \
 && git pull origin master \
 && ./install.sh

ADD loader /
 
CMD ["/loader"]
WORKDIR /pentest
