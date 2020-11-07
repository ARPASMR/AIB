#!/bin/bash

DOCKER_RUN="docker run -it --rm --name aib-shell-"`date "+%s"`

echo $DOCKER_RUN

if [ "$1" == "v" ]; then
  echo "Work with volume"
  $DOCKER_RUN -v fwi_share:/fwi aib /bin/bash
else 
  if [ "$1" == "dbg" ]; then
    $DOCKER_RUN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt apparmor=unconfined -v fwi_share:/fwi aib /bin/bash
  else
    $DOCKER_RUN aib /bin/bash
  fi
fi
