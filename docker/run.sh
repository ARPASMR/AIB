#!/bin/bash

if [ "$1" == "prod" ]; then
  docker run -d --rm --name aib --hostname aib.docker.arpa.local --log-driver syslog -v fwi_share:/fwi aib 
else
  docker run -d --rm --name aib --hostname aib.docker.arpa.local --log-driver syslog -v /home/buck/dockerdata/fwi:/fwi aib 
fi
