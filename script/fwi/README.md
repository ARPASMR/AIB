# Istruzioni per lanciare la procedura su Milanone
---------------------------------------------------

1) rimuovere i file di controllo con la data odierna dalla cartella /home/meteo/tmp

ls *YYYYMMDD
end_forecast.YYYYMMDD  end_grass.YYYYMMDD  end_isaia.YYYYMMDD

rm *YYYYMMDD

2) cerco nel crontab le istruzioni per lanciare lo script

crontab -l 

### RG  <--------------------------------------------------------------------------------------------------------INIZIO
#       esecuzione script di vari autori per calcolo FWI su grigliato
5,37 5,6,7,9 * * * /home/meteo/script/fwi/alfuoco_roberto_dmod.sh > /home/meteo/log/fwigrid_`/bin/date +\%Y\%m\%d\%H\%M`.log 2>&1
### RG  <--------------------------------------------------------------------------------------------------------FINE

e lanciare le istruzioni (al 2020-03-17 la seguente)

/home/meteo/script/fwi/alfuoco_roberto_dmod.sh > /home/meteo/log/fwigrid_`/bin/date +\%Y\%m\%d\%H\%M`.log

3) dopo un po verifico da qua http://10.10.0.14/forecast/fwi/ che le mappe siano aggiornate 

