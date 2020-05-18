#!/bin/bash 

#-- Environment setup 
cd $HOME/wrf

#-- Run real.exe
echo $(date +"%T") real.exe...
time ./real.exe >& $HOME/log/${stamp}.real.log

#-- Run wrf.exe
echo $(date +"%T") wrf.exe...
time ./wrf.exe >& $HOME/log/${stamp}.wrf.log
