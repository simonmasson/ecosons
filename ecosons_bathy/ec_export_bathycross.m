%[err, err_desc]=ec_export_bathycross(TRANSECTCROSS, utmCoords)
%
function [err, err_desc]=ec_export_bathycross(TRANSECTCROSS, utmCoords)
 err=0;
 err_desc='';

 %compute transect crosses if none given
 if(nargin==0)
  [TRANSECTCROSS, utmCoords]=ec_ops_bathycross;
  if( length(TRANSECTCROSS)==0 )
   err=1;
   err_desc='No BATHYMETRY data available';
   return;
  endif
 endif
 

 %output file name
 foutn=gminput('Output file name (default bathycross.dat): ', 's');
 if( length(foutn)==0 )
  foutn='bathycross.dat';
 endif
 
 %open file stream
 fout=fopen(foutn, 'w');
 
 %check open
 if( fout<0 )
  err=2;
  err_desc=['File ' foutn ' could not be opened for writing'];
  return;
 endif
 
 %headers
 if(utmCoords)
  fprintf(fout, "#ID\tT_NUM1\tP_NUM1\tT_NUM2\tP_NUM2\tUTM-X(%d)\tUTM-Y\tErrZ\n", TRANSECTCROSS.utmZN);
 else
  fprintf(fout, "#ID\tT_NUM1\tP_NUM1\tT_NUM2\tP_NUM2\tLAT\tLON\tErrZ\n");
 endif

 for n=1:length(TRANSECTCROSS.ddepth)

  fprintf(fout, '%d',       n);      %ID
  fprintf(fout, '\t%d\t%d', TRANSECTCROSS.transect1(n), TRANSECTCROSS.nping1(n)); %T_NUM1, P_NUM1
  fprintf(fout, '\t%d\t%d', TRANSECTCROSS.transect2(n), TRANSECTCROSS.nping2(n)); %T_NUM2, P_NUM2

  %coords
  if(utmCoords)
   fprintf(fout, '\t%0.2f\t%0.2f', TRANSECTCROSS.utmX1(n), TRANSECTCROSS.utmY1(n)); %UTM-X, UTM-Y
  else
   fprintf(fout, '\t%0.6f\t%0.6f', TRANSECTCROSS.latitude1(n), TRANSECTCROSS.longitude1(n)); %LAT, LON
  endif
 
 fprintf(fout, '\t%g\n', TRANSECTCROSS.ddepth(n));
 
 endfor

 %close file stream
 fclose(fout); 

endfunction
