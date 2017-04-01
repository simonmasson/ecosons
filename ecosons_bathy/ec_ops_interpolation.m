%

function [Is,utmCoords,gX_min,gX_max,gY_min,gY_max,znCoord]=ec_ops_interpolation
 global BATHYMETRY

 %local variables
 lat=[];
 lon=[];
 depth=[];
 for nt=1:length(BATHYMETRY)
  lat=[lat BATHYMETRY{nt}.latitude];
  lon=[lon BATHYMETRY{nt}.longitude];
  depth=[depth BATHYMETRY{nt}.depth];
 endfor

 %interpolation radius
 cellSz=gminput('Output map cell size (default, 10 m): ');
 if( length(cellSz)==0 )
  cellSz=10;
 endif 

 %interpolation radius
 wRm=gminput('Interpolation radius (default, 10 m): ');
 if( length(wRm)==0 )
  wRm=10;
 endif 

 %convert to UTM? (default no)
 ask=gminput('Use UTM coordinates? (y/N) ', 's');
 if( length(ask)~=0 && ( ask(1)=='y' || ask(1)=='Y' ) )
  
  %use UTM
  utmCoords=true;
  znCoord=round((lon(1)+183)/6); %use first point zone
  [xCoord, yCoord, znCoord]=latlon2utmxy(znCoord, lat,lon);
  
  [Is,I,av,se,gX_min,gX_max,gY_min,gY_max]=trinterpmapUTM(xCoord,yCoord,depth, wRm,cellSz);
  
 else
 
  %use lat-lon
  utmCoords=false;
  znCoord=0;
  [Is,I,av,se,gY_min,gY_max,gX_min,gX_max]=trinterpmap(lat,lon,depth, wRm,cellSz);
 
 endif

 %report interpolation quality
 disp([ 'Bathymetry mean deviation:  ' num2str(av) ' m']);
 disp([ 'Bathymetry standard error: ' num2str(se) ' m']);

endfunction
