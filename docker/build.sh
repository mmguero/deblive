BUILD_ERROR_CODE=1

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit $BUILD_ERROR_CODE
fi

set -e

RUN_PATH="$(pwd)"
SCRIPT_PATH="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$SCRIPT_PATH" >/dev/null 2>&1

WORKDIR="$(mktemp -d -t sensor-XXXXXX)"

function cleanup {
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
  rsync -a "$SCRIPT_PATH/config" .
  chown -R root:root *

  # make sure we install the kernel headers for building the pfring kernel module
  echo "linux-headers-$(uname -r)" > ./config/package-lists/kernel.list.chroot

  lb config \
    --debian-installer live \
    --debian-installer-gui false \
    --debian-installer-distribution $IMAGE_DISTRIBUTION \
    --bootappend-install "auto=true priority=critical locales=en_US.UTF-8 keyboard-layouts=us ipv6.disble=1" \
    --distribution $IMAGE_DISTRIBUTION \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --bootloaders "syslinux,grub-efi" \
    --chroot-filesystem squashfs \
    --apt-indices none \
    --apt-source-archives false \
    --security false \
    --updates false \
    --source false \
    --backports true \
    --archive-areas 'main contrib non-free' \
    --parent-mirror-bootstrap http://ftp.us.debian.org/debian/ \
    --parent-mirror-binary http://httpredir.debian.org/debian/ \
    --mirror-bootstrap http://ftp.us.debian.org/debian/ \
    --mirror-binary http://httpredir.debian.org/debian/ \
    --archive-areas "main contrib non-free" \
    --debootstrap-options "--include=apt-transport-https,gnupg,ca-certificates,openssl" \
    --apt-options "--force-yes --yes" \
    --bootappend-live "boot=live components persistence persistence-encryption=none,luks elevator=deadline cgroup_enable=memory swapaccount=1 ipv6.disble=1"

  lb build 2>&1 | tee "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log"
  if [ -f live-image-amd64.hybrid.iso ]; then
    mv live-image-amd64.hybrid.iso "$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION.iso" && \
      echo "Finished, created \"$RUN_PATH/$IMAGE_NAME-$IMAGE_VERSION.iso\""
    BUILD_ERROR_CODE=0
  else
    echo "Error creating ISO, see log file"
    mv "$WORKDIR/output/$IMAGE_NAME-$IMAGE_VERSION-build.log" "$RUN_PATH/"
    BUILD_ERROR_CODE=2
  fi

  popd >/dev/null 2>&1
  popd >/dev/null 2>&1

else
  echo "Unable to create temporary directory \"$WORKDIR\""
fi

popd  >/dev/null 2>&1

exit $BUILD_ERROR_CODE
