#!/bin/bash

export hh=${1-00}
export stamp=$(date +"%Y%m%d${hh}")
export stampgfs=$(date +"%Y%m%d")

#------
#-- WPS
#------
export wps_start_date=$(date +"%Y-%m-%d_${hh}:00:00")
export wps_stop_date=$(date --date="+1 day" +"%Y-%m-%d_${hh}:00:00")
export wps_stop_date=$(date --date="+2 day" +"%Y-%m-%d_${hh}:00:00")
export wps_max_dom=3
export wps_max_dom=2
export wps_map_proj=lambert
export wps_map_proj=mercator
#-- Palencia (-4.5649220, 41.9860072)
export wps_ref_lat=41.9860072     
export wps_ref_lon=-4.5649220
#-- Catalonia (1.848, 41.783)
export wps_ref_lat=41.783     
export wps_ref_lon=1.848
#-- La Romana
export wps_ref_lat=18.42733
export wps_ref_lon=-68.972847
#-- Santo Domingo
export wps_ref_lat=18.4718609     
export wps_ref_lon=-69.8923187
export wps_truelat1=${wps_ref_lat}
export wps_truelat2=${wps_ref_lat}
export wps_stand_lon=${wps_ref_lon}

#------
#-- WRF
#------
export wrf_start_year=$(date +"%Y")
export wrf_start_month=$(date +"%m")
export wrf_start_day=$(date +"%d")
export wrf_start_hour=$hh
export wrf_end_year=$(date --date="+1 day" +"%Y")
export wrf_end_month=$(date --date="+1 day" +"%m")
export wrf_end_day=$(date --date="+1 day" +"%d")
export wrf_run_hours=24
export wrf_end_year=$(date --date="+2 day" +"%Y")
export wrf_end_month=$(date --date="+2 day" +"%m")
export wrf_end_day=$(date --date="+2 day" +"%d")
export wrf_run_hours=48
export wrf_end_hour=$hh
export wrf_max_dom=${wps_max_dom}

