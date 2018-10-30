FROM brimstone/kali:base

RUN apt update \
 && apt install -y --no-install-recommends \
	postgresql \
 && apt clean \
 && rm -rf /var/lib/apt/lists

# Metasploit Install
RUN gem install wirble sqlite3 bundler

RUN sed -i 's/md5$/trust/g' /etc/postgresql/*/main/pg_hba.conf \
 && /etc/init.d/postgresql start \
 && su -c "createuser msf -S -R -D \
 && createdb -O msf msf" postgres

ENV LHOST= \
    MSF_DATABASE_CONFIG=/opt/metasploit-framework/embedded/framework/config/database.yml

COPY msf/bin/* /usr/local/bin/

# Update metasploit the easy way, using the latest nightly
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
 && echo " timeout: 5" >> $MSF_DATABASE_CONFIG

RUN curl http://fastandeasyhacking.com/download/armitage150813.tgz \
  | tar -zxC /pentest/

RUN msfcache build

RUN rm -rf /root/.msf4 \
 && git clone https://github.com/brimstone/metasploit-modules /root/.msf4

EXPOSE 80 443 4444
