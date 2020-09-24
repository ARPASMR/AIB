#!/bin/bash
docker --env HTTP_PROXY=$HTTP_PROXY --env HTTPS_PROXY=$HTTPS_PROXY --env NO_PROXY=$NO_PROXY build -t aib .
