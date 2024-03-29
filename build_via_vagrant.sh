#!/bin/bash

SCRIPT_PATH="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function vm_state() {
  vagrant status --machine-readable | grep ",state," | egrep -o '([a-z_]*)$'
}

function vm_is_running() {
  STATE="$(vm_state)"
  if [[ "$STATE" == "running" ]] ; then
    return 0
  else
    return 1
  fi
}

function vm_execute() {
  echo "Running $1" >&2
  vagrant ssh --no-tty --command "$1"
}

function cleanup_envs {
  rm -f "$SCRIPT_PATH"/environment.chroot
}

unset FORCE_PROVISION
unset CONFIG_DIR
while getopts 'fd:' OPTION; do
  case "$OPTION" in
    f)
      FORCE_PROVISION=0
      ;;
    d)
      CONFIG_DIR="$OPTARG"
      ;;
    ?)
      echo "script usage: $(basename $0) [-f] -d config_dir" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ -z $CONFIG_DIR ]] || [[ ! -d $CONFIG_DIR ]] ; then
  echo "script usage: $(basename $0) [-f] -d config_dir" >&2
  exit 1
fi

pushd "$SCRIPT_PATH"/vagrant

VM_NAME="$(grep "config.vm.box" Vagrantfile | tr -d "[:space:]" | sed "s/.*=//")"

if [[ -n $FORCE_PROVISION ]]; then
  echo "Destroying build machine to force provisioning..." >&2
  vagrant destroy -f
  sleep 1
fi

# make sure the VM is up and running, or start it otherwise
if ! vm_is_running; then
  echo "Starting build machine..." >&2
  vagrant up
  NEED_SHUTDOWN=true
  sleep 1
fi
until vm_is_running; do
  echo "Waiting for $VM_NAME..." >&2
  sleep 1
done
echo "$VM_NAME is running!" >&2

# make sure we can connect via SSH
echo "Checking SSH availability..." >&2
until vm_execute 'sudo whoami' | grep -q "root" ; do
  echo "Waiting for SSH availability..." >&2
  sleep 1
done
echo "SSH available." >&2

# pass a few things across to the vagrant environment
cleanup_envs
[[ ${#GITHUB_TOKEN} -gt 1 ]] && echo "GITHUB_TOKEN=$GITHUB_TOKEN" >> "$SCRIPT_PATH"/environment.chroot
echo "VCS_REVSION=$( git rev-parse --short HEAD 2>/dev/null || echo master )" >> "$SCRIPT_PATH"/environment.chroot

trap cleanup_envs EXIT

vm_execute "sudo bash -c \"whoami && cd /iso-build && pwd && ./build.sh \\\"$CONFIG_DIR\\\"\""

if [[ -n $NEED_SHUTDOWN ]]; then
  echo "Shutting down $VM_NAME..." >&2
  vagrant halt
  sleep 1
  while vm_is_running; do
    echo "Waiting for $VM_NAME to shutdown..." >&2
    sleep 1
  done
  echo "$VM_NAME is stopped." >&2
fi

popd