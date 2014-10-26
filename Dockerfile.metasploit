FROM brimstone/kali

RUN apt-get update \
 && apt-get install -y build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre subversion git-core autoconf pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev ruby1.9.3 ruby-dev nmap \

 && apt-get clean \
 && rm -rf /var/lib/apt/lists \


 && gem install wirble sqlite3 bundler \

 && git clone --depth 0 https://github.com/rapid7/metasploit-framework.git /pentest/metasploit-framework \
 && cd /pentest/metasploit-framework \
 && bundle install \
 && for MSF in $(ls msf*); do ln -s /pentest/metasploit-framework/$MSF /usr/local/bin/$MSF;done \
 && echo "production:" > /pentest/metasploit-framework/config/database.yml \
 && echo " adapter: postgresql" >> /pentest/metasploit-framework/config/database.yml \
 && echo " database: msf" >> /pentest/metasploit-framework/config/database.yml \
 && echo " username: msf" >> /pentest/metasploit-framework/config/database.yml \
 && echo " password:" >> /pentest/metasploit-framework/config/database.yml \
 && echo " host: postgres" >> /pentest/metasploit-framework/config/database.yml \
 && echo " port: 5432" >> /pentest/metasploit-framework/config/database.yml \
 && echo " pool: 75" >> /pentest/metasploit-framework/config/database.yml \
 && echo " timeout: 5" >> /pentest/metasploit-framework/config/database.yml

env MSF_DATABASE_CONFIG /pentest/metasploit-framework/config/database.yml

CMD ["msfconsole"]
