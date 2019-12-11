vengono utilizzati i seguenti file
* CSV2GrADS, dalla directory di milanone ./programmi/CSV2GrADS/CSV2GrADSv2/CSV2GrADS, _eseguibile FORTRAN_
* anagrafica.ctl e anagrafica.dat dalla directory di milanone ./programmi/geoinfo
* GRADS, dalla cartella di installazione /opt/bin/grads
* STNMAP, dalla cartella di installazione /opt/bin/stmap
* t2m11, rhtd11, wind11, plzln11, dalla cartella di milanone ./programmi/interpolazione/oi_fwi/applicativi _eseguibili FORTRAN_
* plotta_t2m.gs, plotta_vento.gs, plotta_hourlyrain_tana11.gs, plotta_dailyrain_tana11.gs, plotta_rh2m.gs, dalla cartella ./programmi/interpolazione_statistica/oi_fwi/mappe/script _script GrADS_
* fwigrid_ana_2.1, dalla cartella ./programmi/fwi_grid, _eseguibile FORTRAN (?)_
* fwidbmgr, dalla cartella ./dev/redist/fwidbmgr _eseguibile C++, documentazione in AIB_



UPDATE 2019
Nell'ottica della semplificazione dell'intera procedura FWI, questo script **non è più utilizzato** grazie agli script ascii2grids realizzatida Gter che vengono eseguiti da mediano (in crontab) e producono i file necessaari al funzionamento di FWI.
