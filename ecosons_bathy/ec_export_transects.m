%[err, err_desc]=ec_export_transects(ntr, utmCoords, xCoord, yCoord, znCoord)
%exports 2-D map of the transects
%ntr: bathymetry/echosounder transect number
%utmCoords: whether coordinates are UTM or not
%xCoord,yCoord: UTM-X, UTM-Y or lon, lat coordinates
%znCoord: UTM-zone (ignored if lat,lon)
%err, err_desc:
function [err, err_desc]=ec_export_transects(ntr, utmCoords, xCoord, yCoord, znCoord)
 err=0;
 err_desc='';

 %if data is not pre-calculated
 if( nargin==0 )
  [ntr, utmCoords, xCoord, yCoord, znCoord]=ec_ops_transects;
  if( length(ntr)==0 )
   err=1;
   err_desc='No valid data source';
   return;
  endif
 endif

 %output file name
 foutn=gminput('Output file name (default transects.dat): ', 's');
 if( length(foutn)==0 )
  foutn='transects.dat';
 endif
 
 %point subsampling
 n_step=gminput('Point subsampling (default 1): ');
 if( length(n_step)==0 )
  n_step=1;
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
  fprintf(fout, "#ID\tT_NUM\tUTM-X(%d)\tUTM-Y\n", znCoord(1));
 else
  fprintf(fout, "#ID\tT_NUM\tLAT\tLON\n");
 endif

 for n=1:n_step:length(ntr)

  fprintf(fout, '%d',   n);      %ID
  fprintf(fout, '\t%d', ntr(n)); %T_NUM

  %coords
  if(utmCoords)
   fprintf(fout, '\t%0.2f\t%0.2f', xCoord(n), yCoord(n)); %UTM-X, UTM-Y
  else
   fprintf(fout, '\t%0.6f\t%0.6f', yCoord(n), xCoord(n)); %LAT, LON
  endif
  
  fprintf(fout, '\n');
 
 endfor

 %close file stream
 fclose(fout); 

endfunction
