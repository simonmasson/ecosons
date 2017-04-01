%[slat,slon,sdepth]=radialSubsampling(sradius, lat, lon, depth)
% subsamples a series of coordinates and depth values based on a search radius criterium
%slat, slon: subsampled (averaged) coordinates (latitude and longitude)
%stme: subsampled (averaged) times
%sdepth: subsampled (averaged) depths
%sradius: search radius
%lat, lon: input coordinates
%tme: measurement times
%depth: input depths
function [slat,slon,stme,sdepth]=radialSubsampling(sradius, lat, lon, tme, depth)

 %number of data
 nn=length(depth);
 if( nn==1 )
  slat=lat;
  slon=lon;
  stme=tme;
  sdepth=depth;
  return;
 else
  slat=[];
  slon=[];
  stme=[];
  sdepth=[];
 endif

 %squared search radius (meters)
 dd=sradius**2;

 %UTM coordinates (meters)
 [gpsx, gpsy]=latlon2utmxy(-1, lat,lon);
 
 %first point
 gpsxa=gpsx(1);
 gpsya=gpsy(1);

 pp=0;
 npingP=[];
 for p=1:nn

  %skip pings?
  rr=(gpsxa-gpsx(p))**2 + (gpsya-gpsy(p))**2;
  if( rr<dd )
   continue; %disregard a ping within less than sradius from the preceeding one
  elseif( ~isnan(rr) )
   gpsxa=gpsx(p);  %this is the next one; keep it for future reference
   gpsya=gpsy(p);
  else
   gpsxa=gpsx(p);  %invalid coordinates skip until next valid one (why keep them?)
   gpsya=gpsy(p);
   continue;
  endif

  %output point
  pp=pp+1;
 
  %average around this point
  ss=0;
  sslat=0;
  sslon=0;
  sstme=0;
  ssdep=[];
  for q=-50:50 %point neighbourhood
   pq=p+q;
   if( 0<pq && pq<=nn )
    rr=(gpsx(pq)-gpsx(p))**2 + (gpsy(pq)-gpsy(p))**2;

    %check distance
    if( rr<dd )
     ss=ss+1;
     sslat=sslat+lat(pq);
     sslon=sslon+lon(pq);
     sstme=sstme+tme(pq);
     ssdep=[ssdep, depth(pq)];
    endif

   endif

  endfor %averaging loop

  if( ss > 0 ) 
   %mean coordinates
   slat(pp)=sslat/ss;
   slon(pp)=sslon/ss;
   stme(pp)=sstme/ss;
 
   %rebust mean depth estimate (90%)
   [ssdep, _idx]=sort(ssdep, 'ascend');
   sdepth(pp)=ssdep(1+floor(length(ssdep)/10));
    
  else %this should never happen!
   slat(pp)=NaN*gpslat(p);
   slon(pp)=NaN*gpslon(p);
   stme(pp)=NaN;
   sdepth(pp)=NaN*depth(p);
  endif

 endfor

endfunction

