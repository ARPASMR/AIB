FROM debian:buster-slim

# System update
RUN apt -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false -y update && \
    apt -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false -y upgrade

# Development packages
RUN apt -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false -y install \
        g++ gfortran grass libboost1.67-all-dev libgfortran-7-dev libgfortran-8-dev \
        smbclient

RUN apt -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false -y install vim

# create data folder for input & output
# this folder to be mounted on host or NFS
RUN mkdir -p /fwi/data/ini && \
    mkdir -p /fwi/data/meteo/ana && \
    mkdir -p /fwi/data/meteo/prev && \
    mkdir -p /fwi/data/modis_neve && \
    mkdir -p /fwi/data/immagini/png && \
    mkdir -p /fwi/data/immagini/ana && \
    mkdir -p /fwi/data/immagini/prev && \
    mkdir -p /fwi/data/immagini/meteo/ana/archivio && \
    mkdir -p /fwi/data/immagini/meteo/prev/archivio && \
    mkdir -p /fwi/data/spedizioni && \
    mkdir -p /fwi/data/modelli_vuoti

# create scripts folder containing bash and grass scripts
RUN mkdir -p /fwi/scripts/grass_work && \
    mkdir -p /fwi/scripts/fwi

# create bin folder containing FORTRAN 90 binary
RUN mkdir -p /fwi/bin

# copy bash & grass scripts
COPY scripts /fwi/scripts

COPY src /development

# scripts permissions
RUN chmod 755 /fwi/scripts/fwi/fwi_analisi.sh && \
    chmod 755 /fwi/scripts/grass_work/batch-grass7.sh

RUN cd /development/fortran/lib && \
    gfortran -c GrADSlib_new.f90 && \
    gfortran -c calendar.f90 && \
    cd /development/fortran/analysis && \
    gfortran  fwigrid_ana_3.01.f90 ../lib/calendar.o ../lib/GrADSlib_new.o -I../lib -L../lib  -o fwigrid_ana && \
    cp fwigrid_ana /fwi/bin

CMD /bin/bash

