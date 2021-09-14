FROM ubuntu:focal as build

ARG IMAGE_NAME=deblive
ARG IMAGE_VERSION=2.1.0
ARG IMAGE_DISTRIBUTION=bullseye
ARG IMAGE_PUBLISHER=mmguero
ARG APT_BACKPORTS=true
ARG APT_SECURITY=true
ARG APT_UPDATES=true

ENV IMAGE_NAME $IMAGE_NAME
ENV IMAGE_VERSION $IMAGE_VERSION
ENV IMAGE_DISTRIBUTION $IMAGE_DISTRIBUTION
ENV IMAGE_PUBLISHER $IMAGE_PUBLISHER
ENV APT_BACKPORTS $APT_BACKPORTS
ENV APT_SECURITY $APT_SECURITY
ENV APT_UPDATES $APT_UPDATES

COPY . /deblive

RUN apt-get -q update >/dev/null 2>&1 \
 && export KERNEL_TARGET="$(uname -r)" \
 && export GCC_TARGET="$(apt-cache depends gcc | grep 'Depends: gcc-' | cut -d'-' -f2)" \
 && cd /deblive \
 && sed -i "s/\(IMAGE_NAME=\).*/\1$IMAGE_NAME/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(IMAGE_VERSION=\).*/\1$IMAGE_VERSION/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(IMAGE_DISTRIBUTION=\).*/\1$IMAGE_DISTRIBUTION/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(IMAGE_PUBLISHER=\).*/\1$IMAGE_PUBLISHER/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(APT_BACKPORTS=\).*/\1$APT_BACKPORTS/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(APT_SECURITY=\).*/\1$APT_SECURITY/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(APT_UPDATES=\).*/\1$APT_UPDATES/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(KERNEL_TARGET=\).*/\1$KERNEL_TARGET/" $IMAGE_DISTRIBUTION/vars.txt \
 && sed -i "s/\(LINUX_COMPILER_GCC=\).*/\1$GCC_TARGET/" $IMAGE_DISTRIBUTION/vars.txt \
 && cat $IMAGE_DISTRIBUTION/vars.txt \
 && echo \
 && env DEBIAN_FRONTEND=noninteractive apt-get install -t focal-backports --no-install-recommends -y -q \
      build-essential \
      apt-transport-https \
      bc \
      ca-certificates \
      curl \
      debootstrap \
      genisoimage \
      git \
      gnupg2 \
      jq \
      live-build \
      rsync \
      software-properties-common \
      squashfs-tools \
      xorriso \
 && cd /deblive \
 && /usr/bin/env bash -x ./build.sh "$IMAGE_DISTRIBUTION" \
 && env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove \
 &&   apt-get clean \
 &&   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/* \
