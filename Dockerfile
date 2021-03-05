FROM debian:bullseye
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/entrypoint"]

ARG BUILD_DATE
ARG VCS_REF

COPY provision /usr/local/bin/provision

RUN /usr/local/bin/provision base

COPY entrypoint /entrypoint

COPY bin/* /usr/local/bin/

COPY share /pentest/share

RUN wget https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64 \
    -O /pentest/share/busybox

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
