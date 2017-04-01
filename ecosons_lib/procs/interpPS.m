function PS=interpPS(PS)
  lat=[];
  lon=[];
  tme=[];
  for n=1:length(PS)
   tme(n)=PS(n).time;
   if( tme(n) > 0 && ~(PS(n).latitude==0 && PS(n).longitude==0) )
    lat(n)=PS(n).latitude;
    lon(n)=PS(n).longitude;
   else
    tme(n)=NaN;
    lat(n)=NaN;
    lon(n)=NaN;
   endif
  endfor
  
  msk=find( diff(lat)!=0 | diff(lon)!=0 );
  tmeM=(tme(msk)+tme(msk+1))/2;
  latM=(lat(msk)+lat(msk+1))/2;
  lonM=(lon(msk)+lon(msk+1))/2;
  
  lat=interp1(tmeM, latM, tme, 'spline', 'extrap');
  lon=interp1(tmeM, lonM, tme, 'spline', 'extrap');

  for n=1:length(PS)
   PS(n).latitude=lat(n);
   PS(n).longitude=lon(n);
  endfor
  
endfunction
