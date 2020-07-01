test -r ~/.alias && . ~/.alias
PS1='GRASS 7.4.0 (WGS84):\w > '
grass_prompt() {
	LOCATION="`g.gisenv get=GISDBASE,LOCATION_NAME,MAPSET separator='/'`"
	if test -d "$LOCATION/grid3/G3D_MASK" && test -f "$LOCATION/cell/MASK" ; then
		echo [Maschere raster 2D e 3D presenti]
	elif test -f "$LOCATION/cell/MASK" ; then
		echo [Maschera raster presente]
	elif test -d "$LOCATION/grid3/G3D_MASK" ; then
		echo [Maschera raster 3D presente]
	fi
}
PROMPT_COMMAND=grass_prompt
export PATH="/usr/lib/grass74/bin:/usr/lib/grass74/scripts:/home/roberto/.grass7/addons/bin:/home/roberto/.grass7/addons/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export HOME="/home/roberto"
