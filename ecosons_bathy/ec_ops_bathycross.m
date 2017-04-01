%[TRANSECTCROSS, utmCoords]=ec_ops_bathycross
%
function [TRANSECTCROSS, utmCoords]=ec_ops_bathycross
 global BATHYMETRY

 %point subsampling to speed calculation
 dp=gminput('Point subsampling (default 5) ');
 if( length(dp)==0 )
  dp=5;
 endif

 %convert to UTM? (default no)
 ask=gminput('Use UTM coordinates? (y/N) ', 's');
 utmCoords=( length(ask)~=0 && ( ask(1)=='y' || ask(1)=='Y' ) );

 %calculate crosses
 TRANSECTCROSS=bathymetryCrosses(BATHYMETRY, dp);

 %perform conversion
 if( utmCoords && length(TRANSECTCROSS)~=0 )
  TRANSECTCROSS.utmZN=round((TRANSECTCROSS.lon1(1)+183)/6); %use first point zone
  [ TRANSECTCROSS.utmX1, TRANSECTCROSS.utmY1 ]=...
     latlon2utmxy(TRANSECTCROSS.utmZN, TRANSECTCROSS.lat1, TRANSECTCROSS.lon1);
  [ TRANSECTCROSS.utmX2, TRANSECTCROSS.utmY2 ]=...
     latlon2utmxy(TRANSECTCROSS.utmZN, TRANSECTCROSS.lat2, TRANSECTCROSS.lon2);
 endif

endfunction
