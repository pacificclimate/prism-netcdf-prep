# TODO: Add comment
# 
# Author: fanslow
###############################################################################


library(ncdf4)
interleave <- function(v1,v2)
{
    ord1 <- 2*(1:length(v1))-1
    ord2 <- 2*(1:length(v2))
    c(v1,v2)[order(c(ord1,ord2))]
}
build_PRISM_netcdf_timescale <- function(filename,minyear,maxyear) {
    meanyear <- as.integer(mean(c(maxyear,minyear)))+1
    print(filename)
    n <- nc_open(filename, write=TRUE)
    timevar <- ncvar_def('time', paste("days since ",as.character(minyear),"-01-01",sep=''), n$dim$time)
    n <- ncvar_add(n, timevar)
    dates = c(seq(as.Date(paste(as.character(meanyear),'-01-15',sep='')),by='months',length=12), as.Date(paste(as.character(meanyear),'-06-30',sep='')))
    basedate = as.Date(paste(as.character(minyear),"-01-01",sep=''))
    times = dates-basedate
    ncvar_put(n, timevar, times)
    
    bndsvar <- ncvar_def('climatology_bounds', '', list(n$dim$bnds,n$dim$time))
    n <- ncvar_add(n, bndsvar)
    clim_start <- c(seq(as.Date(paste(as.character(minyear),'-01-01',sep='')),by='months',length=12), as.Date(paste(as.character(minyear),'-01-01',sep='')))
    clim_end <- c(seq(as.Date(paste(as.character(maxyear),'-02-01',sep='')),by='months',length=12), as.Date(paste(as.character(maxyear+1),'-01-01',sep='')))
    ncvar_put(n, bndsvar, as.numeric(interleave(clim_start, clim_end)-as.Date("1981-01-01")))
    nc_close(n)
}
