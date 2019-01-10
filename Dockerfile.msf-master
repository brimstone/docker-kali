FROM brimstone/kali:base

RUN apt update \
 && apt install -y --no-install-recommends \
	postgresql \
 && apt clean \
 && rm -rf /var/lib/apt/lists

# Metasploit Install
RUN gem install wirble sqlite3 \
 && gem install bundler -v 1.16.1

RUN sed -i 's/md5$/trust/g' /etc/postgresql/*/main/pg_hba.conf \
 && /etc/init.d/postgresql start \
 && su -c "createuser msf -S -R -D \
 && createdb -O msf msf" postgres

ENV LHOST= \
    MSF_DATABASE_CONFIG=/pentest/metasploit-framework/config/database.yml

COPY msf/bin/* /usr/local/bin/

# Update metasploit the hard way, using git master
# Stolen from https://github.com/hackerhouse-opensource/hacklab/blob/master/Dockerfile
RUN git clone https://github.com/rapid7/metasploit-framework \
 && cd metasploit-framework \
 && bundle install

RUN echo "127.0.0.1:5432:msf:msf:msf" > /root/.pgpass \
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

RUN ln -s /pentest/metasploit-framework/msfconsole /usr/bin \
 && ln -s /pentest/metasploit-framework/msfvenom /usr/bin

RUN msfcache build

RUN rm -rf /root/.msf4 \
 && git clone https://github.com/brimstone/metasploit-modules /root/.msf4

EXPOSE 80 443 4444
