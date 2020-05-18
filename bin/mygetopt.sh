#!/bin/bash

echo $(date +"%T") $0 …

function usage() { 
	echo "Usage: $0 
		-f YYYYmmddhh       #- gfs forecast
		-s hh               #- start hour  {00,03,06...}
		-e hh               #- end hour {03,06,09...}
		" 1>&2; exit 1; 
		}

if [[ $# -eq 0 ]]; then usage ; fi

OPTIONS=$(getopt -o f:s:e: --long forecast:,start:,stop: -- "$@")
echo $OPTIONS
eval set -- "$OPTIONS"
while true; do
	case "$1" in
		-f | --forecast) tf=$2;  shift;shift;;
		-s | --start)    sts=$2; shift;shift;;
		-e | --stop)     ste=$2; shift;shift;;
		--)  break;;
		* )  usage ;;
	esac
done

echo $tf
echo $sts
echo $ste
