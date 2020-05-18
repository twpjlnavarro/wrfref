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
export NCARG_ROOT=/wrf/lib/ncl
export PATH=$NCARG_ROOT/bin:$PATH
