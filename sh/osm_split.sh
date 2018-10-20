#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

mkdir -p /osm/cfg/data
mkdir -p /osm/cfg/download
mkdir -p /osm/cfg/img
mkdir -p /osm/cfg/input
mkdir -p /osm/cfg/joblog
mkdir -p /osm/cfg/poly


inputpbf=/not_exist_this_files_config_problem.osm.pbf

if   [ -f "/osm/import/${GDNAME}.osm.pbf" ] || [ -L "/osm/import/${GDNAME}.osm.pbf" ];
then
    inputpbf=/osm/import/${GDNAME}.osm.pbf
    echo "Found: ${inputpbf}"

elif [ -f "/osm/import/${CONTINENT_LONG}.osm.pbf" ] || [ -L "/osm/import/${CONTINENT_LONG}.osm.pbf" ];
then
    inputpbf=/osm/import/${CONTINENT_LONG}.osm.pbf
    echo "Found: ${inputpbf}"

elif [ -f "/osm/import/${CONTINENT_LONG}-latest.osm.pbf" ] || [ -L "/osm/import/${CONTINENT_LONG}-latest.osm.pbf" ];
then
    inputpbf=/osm/import/${CONTINENT_LONG}-latest.osm.pbf
    echo "Found: ${inputpbf}"

elif [ -f "/osm/import/planet.osm.pbf" ] || [ -L "/osm/import/planet.osm.pbf" ];
then
    inputpbf=/osm/import/planet.osm.pbf
    echo "Found: ${inputpbf}"
else
    echo "NOT Found any OSM input file!!! ...  error"
    exit 404
fi

echo "Backup input file osm fileinfo for audit"
osmium fileinfo ${inputpbf} > /osm/cfg/input/input_osm_fileinfo.txt

if [  "${CONTINENT_LONG}" = "antarctica" ]; then
    echo "antarctica - copy file"
    cp ${inputpbf} /osm/cfg/input/area.osm.pbf
else
    echo "Start osmium extract with -- 'simple' strategy in one pass..."
    time osmium extract ${inputpbf} \
            --overwrite \
            --verbose \
            --strategy simple \
            --polygon  /osm/cfg/poly/poly.osm.pbf \
            --output   /osm/cfg/input/area.osm.pbf
fi

chmod 644 /osm/cfg/input/area.osm.pbf

echo "End of osm_split.sh"
