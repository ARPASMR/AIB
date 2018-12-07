#! /usr/bin/env python
# -*- coding: utf-8 -*-
#   Gter Copyleft 2018
#   Roberto Marzocchi, Lorenzo Benvenuto


import os,sys,re #,shutil,glob
#import time
#import urllib
import datetime
import subprocess


# absolute path mediano
path="/home/meteo/programmi/interpolazione_statistica/oi_ascii/archivio_ascii"
path_d="{0}/ascii2grads".format(path)

yesterday = datetime.date.today()-datetime.timedelta(hours=int(24))

print yesterday


yd=yesterday.strftime("%Y%m%d")


data_start="{0}12UTCplus1.txt".format(yd)

print data_start

crea_dummy="python {1}/crea_dummy.py  -s {0} -t 24 -h 1 -p dummy".format(data_start,path_d)

p=subprocess.Popen(crea_dummy, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)


#temperatura
#t2m_g.dat 
#t2m_g.ctl 
#con variabili 
#DUMMY: xb 0 99 T background field 
#DA ASCII: xa 0 99 T analysis field 
#DA ASCII: xidi 0 99 integral data influence 



#dummy version
#temperatura="python {0}/ascii2grads.py  -i {0}/dummy_{1} -t 24 -h 1 -v {2}/temperatura/TEMP2m,{2}/temperatura_IDI/T2mIDI -z xb,xa,xidi -o t2m_g -p {2}/grads_file".format(path_d,data_start,path)

#versione pulita
temperatura="python {0}/ascii2grads.py  -i {1}/temperatura/TEMP2m_{2} -t 24 -h 1 -v {1}/temperatura_IDI/T2mIDI -z xa,xidi -o t2m_g -p {1}/grads_file".format(path_d,path,data_start)



print temperatura

p=subprocess.Popen(temperatura, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)

#print "Fin qua OK"


#wind 

#dummy version
#wind="python {0}/ascii2grads.py  -i {0}/dummy_{1} -t 24 -h 1 -v {0}/dummy,{0}/dummy,{0}/dummy,{0}/dummy,{0}/dummy,{0}/dummy,{2}/vento/VU,{2}/vento/VV,{0}/dummy,{0}/dummy,{0}/dummy,{2}/vento_IDI/VVIDI -z dummy,dummy,dummy,dummy,dummy,dummy,dummy,ahu,ahv,dummy,dummy,dummy,xidi -o wind -p {2}/grads_file".format(path_d,data_start,path)


#versione pulita
wind="python {0}/ascii2grads.py  -i {1}/vento/VU_{2} -t 24 -h 1 -v {1}/vento/VV,{1}/vento_IDI/VVIDI -z ahu,ahv,xidi -o wind_g -p {1}/grads_file".format(path_d,path,data_start)


print wind

p=subprocess.Popen(wind, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)



#rh
#dummy version
#rh="python {0}/ascii2grads.py  -i {0}/dummy_{1} -t 24 -h 1 -v {0}/dummy,{0}/dummy,{2}/umiditarelativa/RH,{2}/umiditarelativa_IDI/RHIDI,{0}/dummy -z dummy,dummy,dummy,rha,xidi,dummy -o rhtd -p {2}/grads_file".format(path_d,data_start,path)

#versione pulita 
rh="python {0}/ascii2grads.py  -i {1}/umiditarelativa/RH_{2} -t 24 -h 1 -v {1}/umiditarelativa_IDI/RHIDI -z rha,xidi -o rhtd_g -p {1}/grads_file".format(path_d,path,data_start)


print rh

p=subprocess.Popen(rh, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)


#rain
rain="python {2}/ascii2grads.py  -i {0}/precipitazione/PR_{1} -t 24 -h 1 -v {0}/precipitazione_IDI/PRIDIW,{0}/precipitazione_IDI/PRIDID -z xpa,xidiw,xidid -o raintana11_g -p {0}/grads_file".format(path,data_start,path_d)

print rain

p=subprocess.Popen(rain, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)


#rain_cumulata
rain_cum="python {2}/ascii2grads_cumulata.py  -i {0}/precipitazione/PR_{1} -t 24 -h 1 -z rain -o cumraintana11_g -p {0}/grads_file".format(path,data_start,path_d)

print rain_cum

p=subprocess.Popen(rain_cum, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)


print "\n\n################################"
print "Remove dummy"
# remove dummy
rm_dummy="python {0}/rm_dummy.py".format(path_d)
p=subprocess.Popen(rm_dummy, stdout=subprocess.PIPE, shell=True)
out, err = p.communicate() 
result = out.split('\n')
for lin in result:
    if not lin.startswith('#'):
        print(lin)