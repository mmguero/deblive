#!/bin/bash

BUILD_ERROR_CODE=1

set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit $BUILD_ERROR_CODE
fi

if [ -z "$1" ]; then
  echo "Usage: "${BASH_SOURCE[0]}" <configuration path>" 1>&2
  exit $BUILD_ERROR_CODE
else
  CONFIG_PATH="$( cd -P "$( dirname "$1"/blah )" && pwd )"
  if [ ! -f "$CONFIG_PATH/vars.txt" ] || [ ! -d "$CONFIG_PATH/config" ]; then
    echo "Usage: "$CONFIG_PATH" should contain vars.txt and config directory" 1>&2
    exit $BUILD_ERROR_CODE
  fi
fi

RUN_PATH="$(pwd)"
pushd "$CONFIG_PATH" >/dev/null 2>&1

source ./vars.txt

if [ -z "$BUILD_DIR" ]; then
  WORKDIR="$(mktemp -d -t sensor-XXXXXX)"
else
  WORKDIR="$(mktemp -d -p "$BUILD_DIR" -t sensor-XXXXXX)"
fi

function cleanup {
  # unmount any chroot stuff left behind after an error
  (umount -f $(mount | grep chroot | cut -d ' ' -f 3) >/dev/null 2>&1) && sleep 5

  # clean up the temporary build directory
  if ! rm -rf "$WORKDIR"; then
    echo "Failed to remove temporary directory '$WORKDIR'"
    exit $BUILD_ERROR_CODE
  fi
}

if [ -d "$WORKDIR" ]; then
  # ensure that if we "grabbed a lock", we release it (works for clean exit, SIGTERM, and SIGINT/Ctrl-C)
  trap "cleanup" EXIT

  pushd "$WORKDIR" >/dev/null 2>&1

  git clone --depth 1 --recursive https://github.com/mmguero/config.git ./config

  mkdir -p ./output "./work/$IMAGE_NAME-Live-Build"
  pushd "./work/$IMAGE_NAME-Live-Build" >/dev/null 2>&1
  rsync -a "$CONFIG_PATH/config" .

  if [ -d ./config/bash ]; then
    cp -f ./config/bash/rc ./config/includes.chroot/etc/skel/.bashrc
    cp -f ./config/bash/aliases ./config/includes.chroot/etc/skel/.bash_aliases
    cp -f ./config/bash/functions ./config/includes.chroot/etc/skel/.bash_functions
    cp -f -r ./config/bash/rc.d ./config/includes.chroot/etc/skel/.bashrc.d
  fi
  if [ -d ./config/git ]; then
    cp -f ./config/git/gitconfig ./config/includes.chroot/etc/skel/.gitconfig
    cp -f ./config/git/gitignore_global ./config/includes.chroot/etc/skel/.gitignore_global
  fi

  chown -R root:root *

  # put the date in the grub.cfg entries and configure an encryption option
  if [ -f ./config/includes.binary/boot/grub/grub.cfg ]; then
    sed -i "s/\(Install image\)/\1 $(date +'%Y-%m-%d %H:%M:%S')/g" ./config/includes.binary/boot/grub/grub.cfg
  fi

  lb config \
    --image-name "$IMAGE_NAME" \
    --debian-installer live \
    --debian-installer-gui false \
    --debian-installer-distribution $IMAGE_DISTRIBUTION \
    --distribution $IMAGE_DISTRIBUTION \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --bootloaders "syslinux,grub-efi" \
    --chroot-filesystem squashfs \
    --backports $APT_BACKPORTS \
    --security $APT_SECURITY \
    --updates $APT_UPDATES \
    --source false \
    --apt-indices none \
    --apt-source-archives false \
    --archive-areas 'main contrib non-free' \
    --parent-mirror-bootstrap http://ftp.us.debian.org/debian/ \
    --parent-mirror-binary http://httpredir.debian.org/debian/ \
    --mirror-bootstrap http://ftp.us.debian.org/debian/ \
    --mirror-binary http://httpredir.debian.org/debian/ \
    --archive-areas "main contrib non-free" \
    --debootstrap-options "--include=apt-transport-https,gnupg,ca-certificates,openssl" \
    --apt-options "--force-yes --yes"

  lb build 2>&1 | tee "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log"
  if [ -f "$IMAGE_NAME-amd64.hybrid.iso" ]; then
    mv "$IMAGE_NAME-amd64.hybrid.iso" "$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION.iso" && \
      echo "Finished, created \"$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION.iso\""
    BUILD_ERROR_CODE=0
  else
    echo "Error creating ISO, see log file"
    BUILD_ERROR_CODE=2
  fi
  mv "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log" "$RUN_PATH/"

  popd >/dev/null 2>&1
  popd >/dev/null 2>&1

else
  echo "Unable to create temporary directory \"$WORKDIR\""
fi

popd  >/dev/null 2>&1

exit $BUILD_ERROR_CODE
