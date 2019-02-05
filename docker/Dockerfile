# harness for creating live-build images

ARG IMAGE_NAME=deblive
ARG IMAGE_VERSION=1.0.0
ARG IMAGE_DISTRIBUTION=unstable

FROM debian:$IMAGE_DISTRIBUTION-slim
LABEL maintainer "Seth Grover <Seth.Grover@inl.gov>"

ENV DEBIAN_FRONTEND noninteractive

ENV IMAGE_NAME $IMAGE_NAME
ENV IMAGE_VERSION $IMAGE_VERSION
ENV IMAGE_DISTRIBUTION $IMAGE_DISTRIBUTION

RUN sed -i "s/$IMAGE_DISTRIBUTION main/$IMAGE_DISTRIBUTION main contrib non-free/" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y rsync xorriso live-build live-boot live-config live-tools debootstrap syslinux squashfs-tools python-docutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD build.sh /live-build/build.sh

ENTRYPOINT  [ "/live-build/build.sh" ]
