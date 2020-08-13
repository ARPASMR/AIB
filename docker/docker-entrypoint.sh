#!/bin/bash

facility="FWI"

do_analisys=/fwi/script/analisi_fwi.sh

errtag="ERROR"
infotag=" INFO"
warntag=" WARN"
tracetag="TRACE"
debugtag="DEBUG"

### params
# 1: facility
# 2: level
# 3: string to be logged
function log {
	echo `date "+%Y-%m-%d %H:%M:%S"`" $1 - $2 - $3"
}

log $facility $infotag "FWI analisys started"

while [ true ]; do

	# get current hour and minute
	hour=`date --utc "+%H"`
	minute=`date "+%M"`

	log $facility $infotag "Current time: $hour:$minute"

	## cron string 5,37 5,6,7,9 * * *
	#  minute 5 and 37
	#  @ hour 5
	#  @ hour 6
	#  @ hour 7
	#  @ hour 9

	# if it's the right time execute analisi_fwi.sh
	if [ $hour -eq 5 ] || [ $hour -eq 6 ] || [ $hour -eq 7 ] || [ $hour -eq 9 ] ; then

		if [ $minute -eq 5 ] || [ $minute -eq 37 ] ; then
			log $facility $infotag "H: $hour - M: $minute --> do analisys"
			$do_analisys
		else
			log $facility $infotag "Sleeping 60s ..."
			sleep 60
		fi

	# else sleep 60s
	else
		log $facility $infotag "Sleeping 60s ..."
		sleep 60
	fi
done
