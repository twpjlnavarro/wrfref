#!/bin/bash

exec &>> $HOME/log/${stamp}.runALL.log

#-- Create namelist.wps from template
cd $HOME/wps
cp namelist.wps.template temp
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

#-- Create namelist.input from template
cd $HOME/wrf
cp namelist.input.template temp
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
