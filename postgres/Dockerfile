FROM brimstone/kali

RUN apt-get update \
 && apt-get install -y postgresql \

 && apt-get clean \
 && rm -rf /var/lib/apt/lists \
 && echo "listen_addresses = '0.0.0.0'" >> /etc/postgresql/9.1/main/postgresql.conf

USER postgres

RUN /usr/lib/postgresql/9.1/bin/postgres -D /var/lib/postgresql/9.1/main -c config_file=/etc/postgresql/9.1/main/postgresql.conf \
 & sleep 2 \
 && createuser msf -S -R -D \
 && createdb -O msf msf \
 && echo "host    msf             msf             0/0                     trust" >> /etc/postgresql/9.1/main/pg_hba.conf

ENTRYPOINT ["/usr/lib/postgresql/9.1/bin/postgres"]
CMD ["-D", "/var/lib/postgresql/9.1/main", "-c", "config_file=/etc/postgresql/9.1/main/postgresql.conf"]
