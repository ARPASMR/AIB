#!/bin/bash
#Author: Andrew E Long 
#        aelon@sph.umich.edu
# ael, Mon Nov 16 08:54:15 EST 1998
# update by A. Prasad 20. Jan. 2000
#           aprasad/ne_de@fs.fed.us
# update by R. Nuske 21. Aug. 2006 
#           rnuske at gwdg.de



# Customize this:
#------------------------------------------------------------------------------

GISBASE=/usr/lib/grass74               # path to GRASS binaries and libraries
GISDBASE=$HOME/conversione_GRASS/GRASS7/grass_work  # path to grassdata



# Nothing to change below (I think)
#==============================================================================


# Usage Message
#------------------------------------------------------------------------------
if test $# -eq 0
then
    cat <<EOF

			    $0 usage:

batch-grass runs a command (or executes all commands in a file) in the
grass environment. It simply sets some environmental variables and executes
the commands.

	$0 location_name mapset command
	$0 location_name mapset -file filename

e.g.,

	$0 usgs PERMANENT -file make-quads

EOF
	exit 0
fi



# Some exports
#------------------------------------------------------------------------------
export GISBASE
export GISRC=$HOME/.grassrc7_batch               # path to GRASS settings file
export GIS_LOCK=$$                               # use PID as lock file number
export PATH=$GISBASE/bin:$GISBASE/scripts:$PATH
export LD_LIBRARY_PATH=$GISBASE/lib:$LD_LIBRARY_PATH



# generate GRASS settings file:
#------------------------------------------------------------------------------
cat << EOF > $GISRC
GISDBASE: $GISDBASE
LOCATION_NAME: $1
MAPSET: $2
EOF



# batch-grass core
#------------------------------------------------------------------------------
if test "$3" = "-file"
then
    cat $4 | sh
else
    # strip off the location and mapset,
    shift 2
    # then execute the command which remains:
    echo "$*" | sh
fi



# Cleanup and Exit    
#------------------------------------------------------------------------------
$GISBASE/etc/clean_temp                   # GRASS' cleanup routine
rm -rf /tmp/grass7-$USER-$GIS_LOCK        # remove session tmp directory
rm -f $GISRC

exit 0
