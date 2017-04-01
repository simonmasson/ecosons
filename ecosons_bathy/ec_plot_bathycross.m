%[err, err_desc]=ec_plot_bathycross
%
function [err, err_desc]=ec_plot_bathycross
 global TRANSECTCROSS

 err=0;
 err_desc='';

 [TRANSECTCROSS, utmCoords]=ec_ops_bathycross;
 if( length(TRANSECTCROSS)==0 )
  err=1;
  err_desc='Single transect or no BATHYMETRY data available';
  return;
 endif
 
 %compute masks
 adh=abs(TRANSECTCROSS.ddepth);
 msk02=( 0.25<adh & adh<0.50 );
 msk05=( 0.50<adh & adh<1.00 );
 msk10=( 1.00<adh & adh<2.00 );
 msk20=( adh>2.00 );
 if( utmCoords )
  plot(TRANSECTCROSS.utmX1(msk02), TRANSECTCROSS.utmY1(msk02), '+;dz=0.25-0.50;', ...
       TRANSECTCROSS.utmX1(msk05), TRANSECTCROSS.utmY1(msk05), 'x;dz=0.50-1.00;', ...
       TRANSECTCROSS.utmX1(msk10), TRANSECTCROSS.utmY1(msk10), '*;dz=1.00-2.00;', ...
       TRANSECTCROSS.utmX1(msk20), TRANSECTCROSS.utmY1(msk20), 'o;dz>     2.00;');
 else
  plot(TRANSECTCROSS.lon1(msk02), TRANSECTCROSS.lat1(msk02), '+;dz=0.25-0.50;', ...
       TRANSECTCROSS.lon1(msk05), TRANSECTCROSS.lat1(msk05), 'x;dz=0.50-1.00;', ...
       TRANSECTCROSS.lon1(msk10), TRANSECTCROSS.lat1(msk10), '*;dz=1.00-2.00;', ...
       TRANSECTCROSS.lon1(msk20), TRANSECTCROSS.lat1(msk20), 'o;dz>     2.00;');
 endif

 %posibility to export image data
 ask=gminput('Export figure data? (y/N) ', 's');
 if( length(ask)~=0 && (ask(1)=='y' || ask(1)=='Y') )
 
  [err, err_desc]=ec_export_bathycross(TRANSECTCROSS, utmCoords);
 
 endif

endfunction
