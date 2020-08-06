#!/bin/bash
docker run -d --rm --name aib --hostname aib.docker.arpa.local --log-driver syslog -v /home/dockadmin/data/fwi:/fwi aib 
