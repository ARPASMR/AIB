#!/bin/bash
# << createXML.sh >>
# History
# 2012-05-14 Cristian Lussana. Original Code.
# 2012-05-25 Davide Grimaldelli. Quasi-Original Code.
#------------------------------------------------------------------------------
# Main directory
DIRMAIN=/home/meteo/programmi/fwi_grid/xml
DIRSPED=/home/meteo/programmi/fwi_grid/spedizioni
# Date 
YESTERDAY=`date --date "1 day ago" +%Y%m%d`
YESTERDAY1=`date --date "1 day ago" +%d\\\/%m\\\/%Y`
TODAY=`date +%Y%m%d`
TODAY1=`date +%d\\\/%m\\\/%Y`
TOMORROW=`date --date "1 day" +%Y%m%d`
TOMORROW1=`date --date "1 day" +%d\\\/%m\\\/%Y`
AFTERTOMORROW=`date --date "2 day" +%Y/%m/%d`
AFTERTOMORROW1=`date --date "2 day" +%d\\\/%m\\\/%Y`
# files
FILEMODELLO=$DIRMAIN/fwi_warning_areas_lombardia_YYYYMMDD.xml
FILEIN_YESTERDAY=/home/meteo/programmi/fwi_grid/spedizioni/creaxvigalp_$YESTERDAY.txt
FILEIN_TODAY=/home/meteo/programmi/fwi_grid/spedizioni/creaxvigalp_$TODAY.txt
FILEIN_TOMORROW=/home/meteo/programmi/fwi_grid/spedizioni/creaxvigalp_$TOMORROW.txt
FILEOUT=$DIRMAIN/fwi_warning_areas_lombardia_$TODAY.xml

FTP=/usr/bin/ftp
# files
FTP_LOG=/home/meteo/tmp/FTP_alp.log
#vars
FTP_SERV=alpffirs.eu
FTP_USR=anonymous
FTP_PWD=anonymous
#FTP_DIR=nomeserio



# Display date/time variables
echo "`date` - CreateXML.sh --->"
echo "date/time variables:"
echo "YESTERDAY="$YESTERDAY
echo "YESTERDAY1="$YESTERDAY1
echo "TODAY="$TODAY
echo "TODAY1="$TODAY1
echo "TOMORROW="$TOMORROW
echo "TOMORROW1="$TOMORROW1
#echo "AFTERTOMORROW="$AFTERTOMORROW
#echo "AFTERTOMORROW1="$AFTERTOMORROW1
#
# Elaborations
rm $FILEOUT

# Create Output file and Modify date/time
sed -e 's/YESTERDAY/'$YESTERDAY1'/g' $FILEMODELLO > $FILEOUT 
sed -e 's/TODAY/'$TODAY1'/g' -i $FILEOUT 
sed -e 's/TOMORROW/'$TOMORROW1'/g' -i $FILEOUT 
sed -e 's/AFTERTOM/'$AFTERTOMORROW1'/g' -i $FILEOUT 


# read FILEIN_YESTERDAY and change the correspondent record in FILEOUT 
i=0

{ 
  while read RIGA
  do
    i=$(( i+1 ))
 
    if [ "$i" -eq 1 ]; then sed -e 's/VAR_YY_F01/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 2 ]; then sed -e 's/VAR_YY_F02/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 3 ]; then sed -e 's/VAR_YY_F03/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 4 ]; then sed -e 's/VAR_YY_F04/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 5 ]; then sed -e 's/VAR_YY_F05/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 6 ]; then sed -e 's/VAR_YY_F06/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 7 ]; then sed -e 's/VAR_YY_F07/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 8 ]; then sed -e 's/VAR_YY_F08/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 9 ]; then sed -e 's/VAR_YY_F09/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 10 ]; then sed -e 's/VAR_YY_F10/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 11 ]; then sed -e 's/VAR_YY_F11/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 12 ]; then sed -e 's/VAR_YY_F12/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 13 ]; then sed -e 's/VAR_YY_F13/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 14 ]; then sed -e 's/VAR_YY_F14/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 15 ]; then sed -e 's/VAR_YY_F15/'$RIGA'/g' -i $FILEOUT; fi
  done
} < $FILEIN_YESTERDAY


# read FILEIN_TODAY and change the correspondent record in FILEOUT 
i=0

{ 
  while read RIGA
  do
    i=$(( i+1 ))
 
    if [ "$i" -eq 1 ]; then sed -e 's/VAR_TO_F01/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 2 ]; then sed -e 's/VAR_TO_F02/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 3 ]; then sed -e 's/VAR_TO_F03/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 4 ]; then sed -e 's/VAR_TO_F04/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 5 ]; then sed -e 's/VAR_TO_F05/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 6 ]; then sed -e 's/VAR_TO_F06/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 7 ]; then sed -e 's/VAR_TO_F07/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 8 ]; then sed -e 's/VAR_TO_F08/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 9 ]; then sed -e 's/VAR_TO_F09/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 10 ]; then sed -e 's/VAR_TO_F10/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 11 ]; then sed -e 's/VAR_TO_F11/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 12 ]; then sed -e 's/VAR_TO_F12/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 13 ]; then sed -e 's/VAR_TO_F13/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 14 ]; then sed -e 's/VAR_TO_F14/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 15 ]; then sed -e 's/VAR_TO_F15/'$RIGA'/g' -i $FILEOUT; fi
  done
} < $FILEIN_TODAY



# read FILEIN_TOMORROW and change the correspondent record in FILEOUT 
i=0

{ 
  while read RIGA
  do
    i=$(( i+1 ))

    if [ "$i" -eq 1 ]; then sed -e 's/VAR_TM_F01/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 2 ]; then sed -e 's/VAR_TM_F02/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 3 ]; then sed -e 's/VAR_TM_F03/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 4 ]; then sed -e 's/VAR_TM_F04/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 5 ]; then sed -e 's/VAR_TM_F05/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 6 ]; then sed -e 's/VAR_TM_F06/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 7 ]; then sed -e 's/VAR_TM_F07/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 8 ]; then sed -e 's/VAR_TM_F08/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 9 ]; then sed -e 's/VAR_TM_F09/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 10 ]; then sed -e 's/VAR_TM_F10/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 11 ]; then sed -e 's/VAR_TM_F11/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 12 ]; then sed -e 's/VAR_TM_F12/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 13 ]; then sed -e 's/VAR_TM_F13/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 14 ]; then sed -e 's/VAR_TM_F14/'$RIGA'/g' -i $FILEOUT; fi
    if [ "$i" -eq 15 ]; then sed -e 's/VAR_TM_F15/'$RIGA'/g' -i $FILEOUT; fi
  done
} < $FILEIN_TOMORROW



# Set to undefined value "-" all the others records in FILEOUT

sed -e 's/VAR_AT_F01/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F02/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F03/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F04/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F05/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F06/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F07/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F08/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F09/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F10/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F11/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F12/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F13/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F14/-/g' -i $FILEOUT
sed -e 's/VAR_AT_F15/-/g' -i $FILEOUT



# connessione ftp e trasferimento
#$FTP -n -v -d <<FINE1 > $FTP_LOG
#open $FTP_SERV
#quote user $FTP_USR
#quote pass $FTP_PWD
#lcd $DIRMAIN
##cd $FTP_DIR
#prompt
#mput $FILEOUT
#bye
#FINE1

/usr/bin/ncftpput -a -u anonymous alpffirs.eu / $FILEOUT

# controllo sulla connessione riuscita o meno
#  AUX=`grep "Not connected" $FTP_LOG | wc -l`
#  if [ "$AUX" -ne 0 ]
#  then
#    echo "ATTENZIONE: connessione al server FTP non riuscita"
#  else
#    echo "SUCCESSO: connessione al server FTP riuscita"
#  fi
#


exit 9
