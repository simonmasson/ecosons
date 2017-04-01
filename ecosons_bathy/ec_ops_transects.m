%[ntr, utmCoords, xCoord, yCoord, znCoord]=ec_ops_transects
%
%
function [ntr, utmCoords, xCoord, yCoord, znCoord]=ec_ops_transects
 global SONAR_DATA
 global SONAR_DATA_SELECTION
 global BATHYMETRY

 %null values
 ntr=[];
 utmCoords=false;
 xCoord=[];
 yCoord=[];
 znCoord=[];

 %select or check data source
 if( iscell(SONAR_DATA) && length(SONAR_DATA)>0 && length(BATHYMETRY)>0 )
  sel=gmmenu('Select data source:',...
             'SONAR DATA selection',... %1
             'BATHYMETRY data',...      %2
             'Quit'...                  %3
             );
  if( sel==3 )
   return;
  endif
 elseif( iscell(SONAR_DATA) && length(SONAR_DATA)>0 )
  sel=1;
 elseif( length(BATHYMETRY)>0 )
  sel=2;
 else
  return;
 endif

 lat=[];
 lon=[];
  
 switch(sel)
 
  case 1 %SONAR_DATA selection
   nn=0;
   for sds=SONAR_DATA_SELECTION
    dta=SONAR_DATA{sds};
    
    for n=1:length(dta.G)
     if( dta.G(n).time >= 0 )
      nn=nn+1;
      ntr(nn)=sds;
      lat(nn)=dta.G(n).latitude;
      lon(nn)=dta.G(n).longitude;
     endif
    endfor
   
   endfor
  
  case 2 %BATHYMETRY data

   nn=1;
   for sds=1:length(BATHYMETRY)
    ll=length(BATHYMETRY{sds}.time);
    ntr(nn:nn+ll-1)=sds;
    lat(nn:nn+ll-1)=BATHYMETRY{sds}.latitude;
    lon(nn:nn+ll-1)=BATHYMETRY{sds}.longitude;
    nn=nn+ll;
   endfor
  
 endswitch
 
 %convert to UTM? (default no)
 ask=gminput('Use UTM coordinates? (y/N) ', 's');
 if( length(ask)~=0 && ( ask(1)=='y' || ask(1)=='Y' ) )
  
  utmCoords=true;
  znCoord=round((lon(1)+183)/6); %use first point zone
  [xCoord, yCoord, znCoord]=latlon2utmxy(znCoord, lat,lon);
  
 else
  utmCoords=false;
  xCoord=lon;
  yCoord=lat;
  znCoord=NaN;
 endif

endfunction
