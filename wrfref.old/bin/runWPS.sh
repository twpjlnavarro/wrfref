#!/bin/bash

#-- Environment setup
cd $HOME/wps

#-- Run geogrid.exe
echo $(date +"%T") geogrid.exe... 
./geogrid.exe &> /dev/null
mv geogrid.log $HOME/log/${stamp}.geogrid.log

#-- Run ungrib.exe
echo $(date +"%T") ungrib.exe... 
./link_grib.csh /wrf/data/gfs/gfs.${stamp}/
./ungrib.exe &> /dev/null
mv ungrib.log $HOME/log/${stamp}.ungrib.log

#-- Run metgrid.exe
echo $(date +"%T") metgrid.exe... 
./metgrid.exe &> /dev/null
mv metgrid.log $HOME/log/${stamp}.metgrid.log
