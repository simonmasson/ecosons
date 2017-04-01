%[err,err_desc]=ec_bathymetry_subsampling()
%inputs bathymetry subsampling parameters
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_bathymetry_subsampling
 global BATHYMETRY
 err=0;
 err_desc='';

 %new subsampled bathymetry
 BAT={};

 %input search radius
 sradius=gminput('Search radius (m) (default 10 m): ');
 if( length(sradius)==0 )
  sradius=10.0;
 endif

 %invalid search radius (abort mechanism)
 if( sradius<=0 )
  err=1;
  err_desc='Invalid search radius; aborting';
  return;
 endif

 %perform per-transect subsampling
 for nt=1:length(BATHYMETRY)

  BAT{nt}.name=BATHYMETRY{nt}.name;

  if( length(BATHYMETRY{nt}.depth)>0 )
   [slat,slon,stme,sdep]=radialSubsampling(sradius, BATHYMETRY{nt}.latitude, BATHYMETRY{nt}.longitude, BATHYMETRY{nt}.time, BATHYMETRY{nt}.depth);
  else
   slat=[];
   slon=[];
   stme=[];
   sdep=[];
  endif
  
  BAT{nt}.latitude=slat;
  BAT{nt}.longitude=slon;
  BAT{nt}.time=stme;
  BAT{nt}.depth=sdep;

 endfor

 %replace the bathymetry
 BATHYMETRY=BAT;

endfunction


