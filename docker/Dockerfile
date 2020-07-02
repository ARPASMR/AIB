FROM debian:buster-slim

# System update
RUN apt -y update && \
    apt -y upgrade

# Development packages
RUN apt -y install g++ gfortran grass libboost1.67-all-dev libgfortran-7-dev libgfortran-8-dev

RUN apt -y install vim

COPY src /development

RUN cd /development/fortran/lib && \
    gfortran -c GrADSlib_new.f90 && \
    gfortran -c calendar.f90 && \
    cd /development/fortran/analysis && \
    gfortran  fwigrid_ana_3.01.f90 ../lib/calendar.o ../lib/GrADSlib_new.o -I../lib -L../lib  -o fwigrid_ana

CMD /bin/bash

