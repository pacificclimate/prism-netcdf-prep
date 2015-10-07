#!/bin/bash

#Want to convert the output PRISM ASCII grids to a georeferenced format/netcdfs

for infile in /home/data/projects/PRISM/bc_climate/bc_8110_maps/grids/bc_*8110.*
do
  echo $infile
  gdal_translate -of netCDF -a_srs '+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs' $infile $infile.nc
  mv -v $infile.nc /home/data/projects/PRISM/bc_climate/bc_8110_maps/grids/netcdfs/
done


#Precip prep and metadata
indir=/home/data/projects/PRISM/bc_climate/bc_8110_maps/grids/netcdfs/
F=${indir}bc_ppt_8110.nc.prep
ncecat -O --netcdf4 -u time $indir*ppt*.nc $F
ncrename -O -v Band1,pr $F
ncatted -O -a long_name,pr,m,c,"Precipitation Climatology" \
-a long_description,pr,a,c,"Climatological mean of monthly total precipitation" \
-a standard_name,pr,a,c,"lwe_thickness_of_precipitation_amount" \
-a units,pr,a,c,"mm" \
-a cell_methods,pr,a,c,"time: sum within months time: mean over years" $F
ncatted -O -a axis,lat,c,c,Y $F
ncatted -O -a axis,lon,c,c,X $F
ncap2 -O -s 'defdim("bnds",2)' $F $F
#make an r code file to run the time addition then execute it



#Tmax prep and metadata
F=${indir}bc_tmax_8110.nc.prep
ncecat -O --netcdf4 -u time $indir*tmax*.nc $F
ncrename -O -v Band1,tmax $F
ncatted -O -a long_name,tmax,m,c,"Temperature Climatology (Max.)" \
-a long_description,tmax,a,c,"Climatological mean of monthly mean maximum daily temperature" \
-a standard_name,tmax,a,c,air_temperature \
-a units,tmax,a,c,"celsius" \
-a cell_methods,tmax,a,c,"time: maximum within days time: mean within months time: mean over years" $F
ncatted -O -a axis,lat,c,c,Y $F
ncatted -O -a axis,lon,c,c,X $F
ncap2 -O -s 'defdim("bnds",2)' $F $F

#Tmin prep and metadata
F=${indir}bc_tmin_8110.nc.prep
ncecat -O --netcdf4 -u time $indir*tmin*.nc $F
ncrename -O -v Band1,tmin $F
ncatted -O -a long_name,tmin,m,c,"Temperature Climatology (Min.)" \
-a long_description,tmin,a,c,"Climatological mean of monthly mean minimum daily temperature" \
-a standard_name,tmin,a,c,air_temperature \
-a units,tmin,a,c,"celsius" \
-a cell_methods,tmin,a,c,"time: minimum within days time: mean within months time: mean over years" $F
ncatted -O -a axis,lat,c,c,Y $F
ncatted -O -a axis,lon,c,c,X $F
ncap2 -O -s 'defdim("bnds",2)' $F $F


Rscript add_time_dim.r /home/data/projects/PRISM/bc_climate/bc_8110_maps/grids/netcdfs/bc_ppt_8110.nc.prep 1981 2010
Rscript add_time_dim.r /home/data/projects/PRISM/bc_climate/bc_8110_maps/grids/netcdfs/bc_tmin_8110.nc.prep 1981 2010
Rscript add_time_dim.r /home/data/projects/PRISM/bc_climate/bc_8110_maps/grids/netcdfs/bc_tmax_8110.nc.prep 1981 2010

for F in $(ls $indir*.nc.prep)
do
   ncatted -O -a long_name,time,c,c,time -a calendar,time,c,c,gregorian $F
   ncatted -O -a climatology,time,c,c,"climatology_bounds" $F
done

ncap2 -O -s 'tmax=tmax/100;' ${indir}bc_tmax_8110.nc.prep ${indir}bc_tmax_8110.nc.prep
ncap2 -O -s 'tmin=tmin/100;' ${indir}bc_tmin_8110.nc.prep ${indir}bc_tmin_8110.nc.prep

mv ${indir}bc_ppt_8110.nc.prep pr_monClim_PRISM_historical_run1_198101-201012.nc
mv ${indir}bc_tmax_8110.nc.prep tmax_monClim_PRISM_historical_run1_198101-201012.nc
mv ${indir}bc_tmin_8110.nc.prep tmin_monClim_PRISM_historical_run1_198101-201012.nc