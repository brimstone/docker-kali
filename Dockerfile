FROM debian:stretch

ARG BUILD_DATE
ARG VCS_REF
ARG DEPENDENCY_BUSTER

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/brimstone/docker-kali" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

ENV LHOST= \
    MSF_DATABASE_CONFIG=/opt/metasploit-framework/embedded/framework/config/database.yml

COPY pax-pre-install /usr/local/sbin/pax-pre-install

RUN echo $DEPENDENCY_BUSTER > /dev/null

RUN /usr/local/sbin/pax-pre-install --install \
 && echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" \
    > /etc/apt/sources.list.d/kali.list \
 && echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" \
    >> /etc/apt/sources.list.d/kali.list \
 && for tries in 1 2 3 4; do \
      apt-key adv --keyserver pgp.mit.edu --recv-keys ED444FF07D8D0BF6 || sleep 2 \
  ; done \
 && apt update \
 && apt install -y --no-install-recommends \
    less vim build-essential libreadline-dev libssl-dev libpq5 \
    libpq-dev libreadline5 libsqlite3-dev libpcap-dev \
    subversion git-core autoconf pgadmin3 curl zlib1g-dev libxml2-dev \
    libxslt1-dev xtightvncviewer libyaml-dev ruby ruby-dev nmap beef-xss \
    mitmproxy postgresql python-pefile net-tools iputils-ping iptables \
    sqlmap bettercap bdfproxy rsync enum4linux openssh-client \
	mfoc mfcuk libnfc-bin hydra nikto wpscan weevely netcat-traditional \
    aircrack-ng pyrit cowpatty pciutils kmod wget unicornscan ftp \
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

RUN gem install wirble sqlite3 bundler \
 && mkdir /pentest

RUN sed -i 's/md5$/trust/g' /etc/postgresql/*/main/pg_hba.conf \
 && /etc/init.d/postgresql start \
 && su -c "createuser msf -S -R -D \
 && createdb -O msf msf" postgres

# Update metasploit the hard way
# There's something dumb about what the package does to work with system ruby
COPY msfinstall /usr/bin/msfinstall

RUN /usr/bin/msfinstall \
 && ln -s /opt/metasploit-framework /pentest/ \
 && echo "127.0.0.1:5432:msf:msf:msf" > /root/.pgpass \
 && chmod 600 /root/.pgpass \
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
    > /pentest/metasploit-framework/embedded/framework/plugins/pentest.rb

RUN curl http://fastandeasyhacking.com/download/armitage150813.tgz \
  | tar -zxC /pentest/

# Dradis breaks because of json 1.8.3 and ruby 2.4
#RUN apt update \
# && apt install -y --no-install-recommends \
#    libsqlite3-dev redis-server libmariadbclient-dev-compat \
# && git clone https://github.com/dradis/dradis-ce.git /pentest/dradis-ce/ -b release-3.7 --depth 1 \
# && cd /pentest/dradis-ce/ \
# && echo "gem 'dradis-pdf_export', '~> 3.7', github: 'dradis/dradis-pdf_export'" >> Gemfile.plugins.template \
# && bundle install --path /pentest/dradis-ce/ \
# && bin/setup \
# && wget https://dradisframework.com/academy/files/dradis-ce_compliance_package-oscp.v0.3.zip \
# && mkdir -p templates/notes templates/reports/html_export \
# && unzip -j dradis-ce_compliance_package-oscp.v0.3.zip dradis-ce_compliance_package-oscp.v0.3/dradis-export-oscp.zip -d public/ \
# && echo 'Maybe try the <a href="/dradis-export-oscp.zip">oscp project</a>?' >> app/views/upload/index.html.erb \
# && unzip -j dradis-ce_compliance_package-oscp.v0.3.zip dradis-ce_compliance_package-oscp.v0.3/\*txt -d templates/notes/ \
# && rm templates/notes/instructions.txt \
# && rm dradis-ce_compliance_package-oscp.v0.3.zip \
# && apt clean \
# && rm -rf /var/lib/apt/lists
# COPY dradis/oscp.html.erb /pentest/dradis-ce/templates/reports/html_export/

RUN git clone https://github.com/brimstone/SecLists /pentest/seclists --depth 1 \
 && rm -rf /pentest/seclists/.git \
 && git clone https://github.com/FireFart/msfpayloadgenerator /pentest/msfpayloadgenerator --depth 1 \
 && rm -rf /pentest/msfpayloadgenerator/.git \
 && wget https://github.com/Charliedean/NetcatUP/raw/master/netcatup.sh -O /bin/netcatup.sh \
 && git clone https://github.com/derv82/wifite /opt/wifite --depth 1 \
 && ln -s /opt/wifite/wifite.py /sbin/wifite

RUN wpscan --update

COPY bin/* /usr/local/bin/

COPY lists /pentest/

COPY scripts/msfconsole.rc /root/.msf4/msfconsole.rc

COPY share /pentest/

RUN msfcache build

EXPOSE 80 443 4444

WORKDIR /pentest
