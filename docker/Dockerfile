FROM debian:buster-slim

# System update
RUN apt -y update && \
    apt -y upgrade

# Development packages
RUN apt -y install g++ gfortran grass libboost1.67-all-dev

CMD /bin/bash
