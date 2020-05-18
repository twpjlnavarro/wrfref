#!/bin/bash

#-- declare -a horas=(000 003 006 009 012 015 018 021 024);
#--for ii in $(seq 0 8); do
declare -a horas=(000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048);
for ii in $(seq 0 16); do
#-- echo Would do \
curl --disable-epsv --create-dirs --connect-timeout 30 -m 3600 -u anonymous:USER_ID@INSTITUTION -o /wrf/data/gfs/gfs.${stamp}/gfs.t${hh}z.pgrb2.1p00.f${horas[$ii]} ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${stampgfs}/${hh}/gfs.t${hh}z.pgrb2.1p00.f${horas[$ii]}
done >& $HOME/log/${stamp}.runGFS.log
