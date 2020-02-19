#!/bin/bash

# force-navigate to script directory
SCRIPT_PATH="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$SCRIPT_PATH" >/dev/null 2>&1

docker build -t vboxguest-build:latest .

popd >/dev/null 2>&1
