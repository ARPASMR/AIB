
if [ "$1" == "v" ]; then
  echo "Work with volume"
  docker run -it --rm --name aib-shell -v /home/dockadmin/data/fwi:/fwi aib /bin/bash
else
  docker run -it --rm --name aib-shell aib /bin/bash
fi
