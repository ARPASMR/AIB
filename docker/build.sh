#!/bin/bash
if [ "$1" = "local" ]; then
	echo "Building locally --> no proxy setup"
	docker build -t aib -f ./Dockerfile.local
else
	echo "Building with arpa proxy setup"
	docker build -t aib .
fi

