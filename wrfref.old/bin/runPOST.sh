#!/bin/bash

exec &> $HOME/log/${stamp}.runPOST.log

#-- System configuration
lscpu  >& $HOME/log/${stamp}.lscpu.log

#-- namelist
cp $HOME/wps/namelist.wps  $HOME/log/${stamp}.namelist.wps
cp $HOME/wrf/namelist.input $HOME/log/${stamp}.namelist.input

#-- clean
rm $HOME/wps/GRIB*
rm $HOME/out/GFS*
rm $HOME/wrf/wrfbdy* $HOME/wrf/wrfinput* 
rm $HOME/out/met_em* $HOME/out/wrfrst*

#--
cd $HOME/out
ln -sf wrfout_d01_${wps_start_date} wrfd01.nc
ln -sf wrfout_d02_${wps_start_date} wrfd02.nc
ln -sf wrfout_d03_${wps_start_date} wrfd03.nc

#--
echo $(date +"%T") wrfout_to_cf.ncl...
# exec &>> $HOME/log/${stamp}.ncl.log
ncl 'dir_in="/home/twpu01/out/"' 'file_in="wrfd01.nc"' 'dir_out="/home/twpu01/out/"' 'file_out="wrfd01cf.nc"' $HOME/tools/wrfout_to_cf.ncl 
ncl 'dir_in="/home/twpu01/out/"' 'file_in="wrfd02.nc"' 'dir_out="/home/twpu01/out/"' 'file_out="wrfd02cf.nc"' $HOME/tools/wrfout_to_cf.ncl
ncl 'dir_in="/home/twpu01/out/"' 'file_in="wrfd03.nc"' 'dir_out="/home/twpu01/out/"' 'file_out="wrfd03cf.nc"' $HOME/tools/wrfout_to_cf.ncl 

#-- animate.ncl
echo $(date +"%T") animate.ncl...
cd $HOME/out
ncl $HOME/tools/animate_3_3.ncl 
convert -delay 50 animate*png wrfd01.gif
rm animate*png
