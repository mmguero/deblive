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

if [ ! -d "/usr/share/live/build/hooks" ]; then
  echo "/usr/share/live/build/hooks does not exist, install live-build before proceeding" 1>&2
  exit $BUILD_ERROR_CODE
fi

RUN_PATH="$(pwd)"
SCRIPT_PATH="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$CONFIG_PATH" >/dev/null 2>&1

source ./vars.txt

if [ -z "$BUILD_DIR" ]; then
  WORKDIR="$(mktemp -d -t deblive-XXXXXX)"
else
  WORKDIR="$(mktemp -d -p "$BUILD_DIR" -t deblive-XXXXXX)"
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

  mkdir -p ./output "./work/$IMAGE_NAME-Live-Build"
  pushd "./work/$IMAGE_NAME-Live-Build" >/dev/null 2>&1
  rsync -a "$CONFIG_PATH/config" .

  ls "$SCRIPT_PATH"/shared/bin/*.sh >/dev/null 2>&1 && \
    mkdir -p ./config/includes.chroot/usr/local/bin && \
    cp -v "$SCRIPT_PATH"/shared/bin/*.sh ./config/includes.chroot/usr/local/bin/

  mkdir -p ./config/hooks/live
  pushd ./config/hooks/live
  ln -v -s -f /usr/share/live/build/hooks/live/* ./
  popd >/dev/null 2>&1

  mkdir -p ./config/hooks/normal
  pushd ./config/hooks/normal
  ln -v -s -f /usr/share/live/build/hooks/normal/* ./
  rm -f ./0910-remove-apt-sources-lists
  popd >/dev/null 2>&1

  # make sure we install the firmwares, etc.
  for PKG in firmware-linux \
             firmware-linux-free \
             firmware-linux-nonfree \
             firmware-misc-nonfree \
             firmware-amd-graphics \
             firmware-iwlwifi \
             firmware-atheros; do
    echo "$PKG" >> ./config/package-lists/firmwares.list.chroot
  done

  # write out some version stuff specific to this installation version
  echo "BUILD_ID=\"$(date +'%Y-%m-%d')-${IMAGE_VERSION}\""                      > ./config/includes.chroot/etc/.os-info
  echo "VARIANT=\"${IMAGE_NAME} (${IMAGE_DISTRIBUTION}) v${IMAGE_VERSION}\""   >> ./config/includes.chroot/etc/.os-info
  echo "VARIANT_ID=\"${IMAGE_NAME}\""                                          >> ./config/includes.chroot/etc/.os-info
  echo "ID_LIKE=\"debian\""                                                    >> ./config/includes.chroot/etc/.os-info
  echo "HOME_URL=\"https://github.com/mmguero/deblive\""                       >> ./config/includes.chroot/etc/.os-info
  echo "DOCUMENTATION_URL=\"https://github.com/mmguero/deblive\""              >> ./config/includes.chroot/etc/.os-info
  echo "SUPPORT_URL=\"https://github.com/mmguero/deblive\""                    >> ./config/includes.chroot/etc/.os-info
  echo "BUG_REPORT_URL=\"https://github.com/mmguero/deblive\""                 >> ./config/includes.chroot/etc/.os-info

  chown -R root:root *

  echo "live-build version: $(lb --version)"
  lb config \
    --image-name "$IMAGE_NAME" \
    --debian-installer live \
    --debian-installer-gui false \
    --debian-installer-distribution $IMAGE_DISTRIBUTION \
    --distribution $IMAGE_DISTRIBUTION \
    --iso-application "$IMAGE_NAME" \
    --iso-publisher "$IMAGE_PUBLISHER $(date +'%Y-%m-%d %H:%M:%S')" \
    --linux-packages "linux-image linux-headers" \
    --linux-flavours "amd64:amd64" \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components username=user nosplash elevator=deadline systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory swapaccount=1 cgroup.memory=nokmem random.trust_cpu=on" \
    --memtest none \
    --chroot-filesystem squashfs \
    --backports $APT_BACKPORTS \
    --security $APT_SECURITY \
    --updates $APT_UPDATES \
    --source false \
    --apt-secure $CHECKSUM_RELEASE \
    --apt-indices false \
    --apt-source-archives false \
    --archive-areas 'main contrib non-free' \
    --debootstrap-options "--include=apt-transport-https,bc,ca-certificates,gnupg,debian-archive-keyring,fasttrack-archive-keyring,jq,openssl --no-merged-usr" \
    --apt-options "--yes --allow-downgrades --allow-remove-essential --allow-change-held-packages -oAcquire::Check-Valid-Until=false -oAPT::Default-Release=bookworm"

  lb build 2>&1 | tee "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log"
  if [ -f "$IMAGE_NAME-amd64.hybrid.iso" ]; then
    mv "$IMAGE_NAME-amd64.hybrid.iso" "$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION.iso" && \
      echo "Finished, created \"$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION.iso\""
    BUILD_ERROR_CODE=0
  else
    echo "Error creating ISO, see log file"
    BUILD_ERROR_CODE=2
  fi
  if [ -f "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log" ]; then
    mv "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log" "$RUN_PATH/" && \
      echo "Created \"$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION-build.log\""
  else
    echo "Error creating log file"
  fi

  popd >/dev/null 2>&1
  popd >/dev/null 2>&1

else
  echo "Unable to create temporary directory \"$WORKDIR\""
fi

popd  >/dev/null 2>&1

exit $BUILD_ERROR_CODE
