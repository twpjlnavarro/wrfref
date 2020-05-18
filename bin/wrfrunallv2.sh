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

start_date="$Ys-$ms-${ds}_${hs}:00:00"
stop_date="$Ye-$me-${de}_${he}:00:00"
max_dom=1
max_dom=2

#-- Coordenadas del centro del dominio 1
ref_lat=41.9860072; ref_lon=-4.5649220   #-- Palencia (-4.5649220, 41.9860072)
ref_lat=18.4718609; ref_lon=-69.8923187  #-- Santo Domingo
ref_lat=41.783; ref_lon=1.848            #-- Catalonia (1.848, 41.783)
ref_lat=39.5; ref_lon=-2.5               #-- Spain (-2.5, 39.5)

#-- Begin map_proj mercator or lambert
map_proj=mercator
map_proj=lambert
truelat1=${ref_lat}
truelat2=${ref_lat}
stand_lon=${ref_lon}
dx=10000; dy=10000   #-- Cell size in meters
#-- End map_proj mercator or lambert

#-- Begin map_proj lat-lon
map_proj=rotated_ll
map_proj=lat-lon
pole_lat=90.0; pole_lon=0.0; stand_lon=0.0
dx=0.15; dy=0.09     #-- Cell size in degrees
#-- End map_proj lat-lon

e_we=101; e_sn=$e_we              #-- Number of cells
pgr02=4                  #-- parent_grid_ratio
ips02=$(echo "x=($e_we*(($pgr02-1)/(2*$pgr02*$pgr02))); scale=0; $pgr02*(x/1)+1" | bc -l)
jps02=$ips02    #-- i_parent_start
pgr03=3                  #-- parent_grid_ratio
ips03=$(echo "x=($e_we*(($pgr03-1)/(2*$pgr03*$pgr03))); scale=0; $pgr03*(x/1)+1" | bc -l)
jps03=$ips03    #-- j_parent_start

cd $HOME/wps
#--------Begin here document-----------#
cat >namelist.wps <<-eodoc
	!-------------------------------------------------------------------------
	&share
	 wrf_core = 'ARW',
	 max_dom = $max_dom,
	 start_date = '$start_date', '$start_date', '$start_date',
	 end_date   = '$stop_date', '$stop_date', '$stop_date',
	 interval_seconds = 10800
	 io_form_geogrid = 2,
	 opt_output_from_geogrid_path = '$HOME/out',
	/

	&geogrid
	 parent_id         =   1,   1,  2,
	 parent_grid_ratio =   1,  $pgr02,  $pgr03,
	 i_parent_start    =   1,  $ips02,  $ips03,
	 j_parent_start    =   1,  $jps02,  $jps03,,
	 e_we              =  $e_we, $e_we, $e_we,
	 e_sn              =  $e_we, $e_sn, $e_sn,
	 geog_data_res = 'default','default','default',
	 dx = $dx,
	 dy = $dy,
	 map_proj = '$map_proj',
	 ref_lat   =  $ref_lat,
	 ref_lon   =  $ref_lon,
	 truelat1  =  $truelat1,
	 truelat2  =  $truelat2,
	 stand_lon =  $stand_lon,
	 pole_lat =  $pole_lat,
	 pole_lon =  $pole_lon,
	 geog_data_path = '$HOME/geog/',
	 opt_geogrid_tbl_path = '$HOME/wps/',
	/

	&ungrib
	 out_format = 'WPS',
	 prefix = '$HOME/out/GFS',
	/

	&metgrid
	 fg_name = '$HOME/out/GFS',
	 io_form_metgrid = 2, 
	 opt_output_from_metgrid_path = '$HOME/out/',
	 opt_metgrid_tbl_path = '$HOME/wps',
	/
	!-------------------------------------------------------------------------
eodoc
#----------End here document-----------#
cp namelist.wps $HOME/log

#---------------------------------------------------
#-- namelist.input
#---------------------------------------------------

echo $(date +"%T") namelist.input...…

start_year=$Ys
start_month=$ms
start_day=$ds
start_hour=$hs
end_year=$Ye
end_month=$me
end_day=$de
end_hour=$he
(( run_hours = he - hs ))

#-- Begin Lambert y Mercator
dxx=$dx; dyy=$dy       #--  dx y dy en metros. 
#-- End Lambert y Mercator

#-- Begin Lat-lon
#-- En lat-lon dx varia con la latitud, ¿entonces?
#-- ... pues parece ser que es la dimension de la celda si estuviese en el ecuador
pi=$(printf "%s%.5s\n" 3. 1415926535897932384626433832795)
rd=6370             #-- Radio de la Tierra
dxx=$(echo "$dx*2*4*a(1)*$rd/360*1000" | bc -l)
dyy=$(echo "$dy*2*4*a(1)*$rd/360*1000" | bc -l)
#-- End Lat-lon

dxx02=$(echo "$dxx/$pgr02" | bc -l)
dxx03=$(echo "$dxx02/$pgr03" | bc -l)
dyy02=$(echo "$dyy/$pgr02" | bc -l)
dyy03=$(echo "$dyy02/$pgr03" | bc -l)

#-- time_step
(( $(echo "$dxx < $dyy" | bc -l) )) && small=$dxx || small=$dyy
time_step=$( echo "scale=0; 6*$small/1000" | bc -l)


cd $HOME/wrf
#--------Begin here document-----------#
cat >namelist.input <<-eodoc
	 &time_control
	 run_days                            = 0,
	 run_hours                           = $run_hours,
	 run_minutes                         = 0,
	 run_seconds                         = 0,
	 start_year                          = $start_year, $start_year, $start_year,
	 start_month                         = $start_month, $start_month, $start_month,
	 start_day                           = $start_day, $start_day, $start_day,
	 start_hour                          = $start_hour, $start_hour, $start_hour,
	 end_year                            = $end_year, $end_year, $end_year,
	 end_month                           = $end_month, $end_month, $end_month,
	 end_day                             = $end_day, $end_day, $end_day,
	 end_hour                            = $end_hour, $end_hour, $end_hour,
	 interval_seconds                    = 10800
	 input_from_file                     = .true.,.true.,.true.,
	 history_interval                    = 60, 60, 60,
	 frames_per_outfile                  = 96, 96, 96,
	 restart                             = .false.,
	 restart_interval                    = 720,
	 io_form_history                     = 2
	 io_form_restart                     = 2
	 io_form_input                       = 2
	 io_form_boundary                    = 2
	 auxinput1_inname                    = "$HOME/out/met_em.d<domain>.<date>"
	 history_outname                     = "$HOME/out/wrfout_d<domain>_<date>"
	 rst_outname                         = "$HOME/out/wrfrst_d<domain>_<date>"
	 rst_inname                          = "$HOME/out/wrfrst_d<domain>_<date>"
	 /

	 &domains
	!-- time_step <= 5ó6*d01x(Km). Los dominios anidados se controlan por parent_time_step_ratio 
	 time_step                           = $time_step,
	 time_step_fract_num                 = 0,
	 time_step_fract_den                 = 1,
	!-- Aquí está la madre del cordero...
	 max_dom                             = $max_dom,
	 e_we                                = $e_we,  $e_we,   $e_we,
	 e_sn                                = $e_we,  $e_sn,   $e_sn,
	 e_vert                              = 33,    33,    33,
	 p_top_requested                     = 5000,
	 num_metgrid_levels                  = 34,
	 num_metgrid_soil_levels             = 4,
	 dx                                  = $dxx, $dxx02,  $dxx03,
	 dy                                  = $dyy, $dyy02,  $dyy03,
	 grid_id                             = 1,     2,     3,
	 parent_id                           = 0,     1,     2,
	 i_parent_start                      = 1,     $ips02,    $ips03,
	 j_parent_start                      = 1,     $jps02,    $jps03,
	 parent_grid_ratio                   = 1,     $pgr02,    $pgr03,
	 parent_time_step_ratio              = 1,     $pgr02,    $pgr03,
	 feedback                            = 1,
	 smooth_option                       = 0
	 /

	 &physics
	 physics_suite                       = 'CONUS'
	 mp_physics                          = -1,    -1,    -1,
	 cu_physics                          = -1,    -1,     0,
	 ra_lw_physics                       = -1,    -1,    -1,
	 ra_sw_physics                       = -1,    -1,    -1,
	 bl_pbl_physics                      = -1,    -1,    -1,
	 sf_sfclay_physics                   = -1,    -1,    -1,
	 sf_surface_physics                  = -1,    -1,    -1,
	 radt                                = 30,    30,    30,
	 bldt                                = 0,     0,     0,
	 cudt                                = 5,     5,     5,
	 icloud                              = 1,
	 num_land_cat                        = 21,
	 sf_urban_physics                    = 0,     0,     0,
	 /

	 &fdda
	 /

	 &dynamics
	 hybrid_opt                          = 2, 
	 w_damping                           = 0,
	 diff_opt                            = 1,      1,      1,
	 km_opt                              = 4,      4,      4,
	 diff_6th_opt                        = 0,      0,      0,
	 diff_6th_factor                     = 0.12,   0.12,   0.12,
	 base_temp                           = 290.
	 damp_opt                            = 3,
	 zdamp                               = 5000.,  5000.,  5000.,
	 dampcoef                            = 0.2,    0.2,    0.2
	 khdif                               = 0,      0,      0,
	 kvdif                               = 0,      0,      0,
	 non_hydrostatic                     = .true., .true., .true.,
	 moist_adv_opt                       = 1,      1,      1,     
	 scalar_adv_opt                      = 1,      1,      1,     
	 gwd_opt                             = 1,
	 /

	 &bdy_control
	 spec_bdy_width                      = 5,
	 specified                           = .true.
	 /

	 &grib2
	 /

	 &namelist_quilt
	 nio_tasks_per_group = 0,
	 nio_groups = 1,
	 /
eodoc
#----------End here document-----------#
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
ln -sf wrfout_d01_${start_date} wrfd01.nc
ln -sf wrfout_d02_${start_date} wrfd02.nc
ln -sf wrfout_d03_${start_date} wrfd03.nc


#---------------------------------------------------
#--  wrfout data extraction...
#---------------------------------------------------

#--echo $(date +"%T") wrfout_to_cf.ncl...
#--ncl 'dir_in="/home/twpu01/out/"' 'file_in="wrfd01.nc"' 'dir_out="/home/twpu01/out/"' 'file_out="wrfd01cf.nc"' $HOME/tools/wrfout_to_cf.ncl 

echo $(date +"%T") $0 finished!
