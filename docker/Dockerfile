FROM oci.guero.top/qemu-live-iso:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/deblive'
LABEL org.opencontainers.image.source='https://github.com/mmguero/deblive'
LABEL org.opencontainers.image.title='oci.guero.top/deblive'
LABEL org.opencontainers.image.description='Customized Debian live image in qemu'

ARG QEMU_CPU=4
ARG QEMU_RAM=4096
ENV QEMU_CPU $QEMU_CPU
ENV QEMU_RAM $QEMU_RAM

ADD --chown=${DEFAULT_UID}:${DEFAULT_GID} deblive-*.log /image/
ADD --chown=${DEFAULT_UID}:${DEFAULT_GID} deblive-*.iso /image/live.iso
ADD --chown=${DEFAULT_UID}:${DEFAULT_GID} https://www.debian.org/favicon.ico /image/favicon.ico
