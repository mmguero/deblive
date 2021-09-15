FROM tianon/qemu:native

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/deblive'
LABEL org.opencontainers.image.source='https://github.com/mmguero/deblive'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/deblive'
LABEL org.opencontainers.image.description='Customized Debian live image in qemu'

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# configure unprivileged user and runtime parameters
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "deblive"
ENV PGROUP "deblive"
ENV PUSER_PRIV_DROP false

ARG QEMU_CPU=4
ARG QEMU_RAM=4096
ARG QEMU_CDROM="/deblive/deblive.iso"
ARG QEMU_BOOT="order=d"
ENV QEMU_CPU $QEMU_CPU
ENV QEMU_RAM $QEMU_RAM
ENV QEMU_CDROM $QEMU_CDROM
ENV QEMU_BOOT $QEMU_BOOT

ARG HTTP_SERVER_PORT=8000
ENV HTTP_SERVER_PORT $HTTP_SERVER_PORT

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD docker/supervisord.conf /etc/supervisord.conf

RUN apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      procps \
      psmisc \
      python3-minimal \
      supervisor && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
        useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /nonexistant ${PUSER} && \
        usermod -a -G tty ${PUSER} && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    mkdir /deblive && \
      chmod 755 /deblive && \
      chown ${DEFAULT_UID}:${DEFAULT_GID} /deblive && \
    apt-get -y autoremove -qq && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD deblive-*.log /deblive/
ADD deblive-*.iso /deblive/deblive.iso
ADD https://www.debian.org/favicon.ico /deblive/

EXPOSE 22
EXPOSE 5900
EXPOSE $HTTP_SERVER_PORT

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]

