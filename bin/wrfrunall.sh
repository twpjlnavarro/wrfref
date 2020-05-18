#!/bin/bash


echo $(date +"%T") $0 …

function usage() { 
	echo "Usage: $0 
		-f YYYYmmddhh       #- gfs forecast
		-s hh               #- start hour  {00,03,06...}
		-e hh               #- end hour {03,06,09...}
		" 1>&2; exit 1; 
		}

while getopts "f:s:e:" OPTION; do
	case $OPTION in
		f) tf=$OPTARG ;;
		s) sts=$OPTARG ;;
		e) ste=$OPTARG ;;
		*) usage ;;
	esac
done

Yf=${tf:0:4}  mf=${tf:4:2} df=${tf:6:2} hf=${tf:8:2}
ts=$(date -d "$Yf$mf$df + $sts hours" +"%Y%m%d%H")
Ys=${ts:0:4}  ms=${ts:4:2} ds=${ts:6:2} hs=${ts:8:2}
te=$(date -d "$Yf$mf$df + $ste hours" +"%Y%m%d%H")
Ye=${te:0:4}  me=${te:4:2} de=${te:6:2} he=${te:8:2}



#---------------------------------------------------
#-- Environment
#---------------------------------------------------

#-- netcdf
PATH=/wrf/lib/netcdf/bin:$PATH
#-- mpich
PATH=/wrf/lib/mpich/bin:$PATH
#-- jasper
PATH=/wrf/lib/grib2/bin:$PATH
export PATH

#-- netcdf
export NETCDF=/wrf/lib/netcdf
#-- libpng
export LD_LIBRARY_PATH=/wrf/lib/grib2/lib:$LD_LIBRARY_PATH
#-- wrf
ulimit -s unlimited
export MALLOC_CHECK=0
#-- ncl
export NCARG_ROOT=/opt/ncl-6.6.2
export PATH=$NCARG_ROOT/bin:$PATH


#---------------------------------------------------
#-- namelist.wps
#---------------------------------------------------

echo $(date +"%T") namelist.wps…

wps_start_date="$Ys-$ms-${ds}_${hs}:00:00"
wps_stop_date="$Ye-$me-${de}_${he}:00:00"
wps_max_dom=3
wps_max_dom=1
wps_map_proj=mercator
wps_map_proj=lambert
#-- Palencia (-4.5649220, 41.9860072)
wps_ref_lat=41.9860072     
wps_ref_lon=-4.5649220
#-- Santo Domingo
wps_ref_lat=18.4718609     
wps_ref_lon=-69.8923187
#-- La Romana
wps_ref_lat=18.42733
wps_ref_lon=-68.972847
#-- Buenaventura (Colombia)
wps_ref_lat=3.5833299     
wps_ref_lon=-77
#-- Catalonia (1.848, 41.783)
wps_ref_lat=41.783     
wps_ref_lon=1.848
#-- Spain (-2.5, 39.5)
wps_ref_lat=39.5  
wps_ref_lon=-2.5
wps_truelat1=${wps_ref_lat}
wps_truelat2=${wps_ref_lat}
wps_stand_lon=${wps_ref_lon}

#-- Create namelist.wps from template
cd $HOME/wps
cp $HOME/etc/namelist.wps.template temp
sed "s/wps_start_date/$wps_start_date/g; 
     s/wps_end_date/$wps_stop_date/g;
     s/wps_map_proj/$wps_map_proj/g;
     s/wps_ref_lat/$wps_ref_lat/g;
     s/wps_ref_lon/$wps_ref_lon/g;
     s/wps_truelat1/$wps_truelat1/g;
     s/wps_truelat2/$wps_truelat2/g;
     s/wps_stand_lon/$wps_stand_lon/g;
     s/wps_max_dom/$wps_max_dom/g" temp > namelist.wps
rm temp
cp namelist.wps $HOME/log


#---------------------------------------------------
#-- namelist.input
#---------------------------------------------------

echo $(date +"%T") namelist.input...…

wrf_start_year=$Ys
wrf_start_month=$ms
wrf_start_day=$ds
wrf_start_hour=$hs
wrf_end_year=$Ye
wrf_end_month=$me
wrf_end_day=$de
wrf_end_hour=$he
(( wrf_run_hours = he - hs ))
wrf_max_dom=${wps_max_dom}

#-- Create namelist.input from template
cd $HOME/wrf
cp $HOME/etc/namelist.input.template temp
sed "s/wrf_start_year/$wrf_start_year/g;
     s/wrf_start_month/$wrf_start_month/g;
     s/wrf_start_day/$wrf_start_day/g;
     s/wrf_start_hour/$wrf_start_hour/g;
     s/wrf_end_hour/$wrf_end_hour/g;
     s/wrf_end_year/$wrf_end_year/g;
     s/wrf_end_month/$wrf_end_month/g;
     s/wrf_end_day/$wrf_end_day/g;
     s/wrf_run_hours/$wrf_run_hours/g;
     s/wrf_max_dom/$wrf_max_dom/g" temp > namelist.input
rm temp
cp namelist.input $HOME/log

#---------------------------------------------------
#-- WPS 
#---------------------------------------------------

cd $HOME/wps

#-- Run geogrid.exe
echo $(date +"%T") geogrid.exe... 
./geogrid.exe &> $HOME/log/geogrid.log
mv geogrid.log $HOME/log

#-- Run ungrib.exe
echo $(date +"%T") ungrib.exe... 
./link_grib.csh /wrf/data/gfs/gfs.${Yf}${mf}${df}/${hf}/
./ungrib.exe &> $HOME/log/ungrib.log
#mv ungrib.log $HOME/log

#-- Run metgrid.exe
echo $(date +"%T") metgrid.exe... 
./metgrid.exe &> $HOME/log/metgrid.log
#mv metgrid.log $HOME/log


#---------------------------------------------------
#-- WRF
#---------------------------------------------------

#-- Environment setup 
cd $HOME/wrf

#-- Run real.exe
echo $(date +"%T") real.exe...
./real.exe >& $HOME/log/real.log

#-- Run wrf.exe
echo $(date +"%T") wrf.exe...
./wrf.exe >& $HOME/log/wrf.log

#---------------------------------------------------
#--  Housekeeping
#---------------------------------------------------

#-- System configuration
lscpu  >& $HOME/log/lscpu.log


#-- clean
rm -f $HOME/wps/GRIB*
rm -f $HOME/out/GFS*
rm -f $HOME/wrf/wrfbdy* $HOME/wrf/wrfinput* 
rm -f $HOME/out/met_em* $HOME/out/wrfrst*

#--
cd $HOME/out
ln -sf wrfout_d01_${wps_start_date} wrfd01.nc
ln -sf wrfout_d02_${wps_start_date} wrfd02.nc
ln -sf wrfout_d03_${wps_start_date} wrfd03.nc


#---------------------------------------------------
#--  wrfout data extraction...
#---------------------------------------------------

#--echo $(date +"%T") wrfout_to_cf.ncl...
#--ncl 'dir_in="/home/twpu01/out/"' 'file_in="wrfd01.nc"' 'dir_out="/home/twpu01/out/"' 'file_out="wrfd01cf.nc"' $HOME/tools/wrfout_to_cf.ncl 

echo $(date +"%T") $0 finished!
