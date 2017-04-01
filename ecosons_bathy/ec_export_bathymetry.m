%[err, err_desc]=ec_plot_bathymetry(ntr, utmCoords, xCoord, yCoord, znCoord, depth)
%exports 2-D map of the transects
%ntr: bathymetry/echosounder transect number
%utmCoords: whether coordinates are UTM or not
%xCoord,yCoord: UTM-X, UTM-Y or lon, lat coordinates
%znCoord: UTM-zone (ignored if lat,lon)
%depth: depth
%err, err_desc:
function [err, err_desc]=ec_export_bathymetry(ntr, utmCoords, xCoord, yCoord, znCoord, depth, bTime)

 err=0;
 err_desc='';

 %if data is not pre-calculated
 if( nargin==0 )
  [ntr, utmCoords, xCoord, yCoord, znCoord, depth, bTime]=ec_ops_bathymetry;
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
 
 %export time
 e_time=gminput('Export time (y/N):', 's');
 e_time=( length(e_time)>0 && (e_time(1)=='y' || e_time(1)=='Y') );
 
 
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
  if(e_time)
   fprintf(fout, "#ID\tT_NUM\tTIME\tUTM-X(%d)\tUTM-Y\tdepth\n", znCoord(1));
  else
   fprintf(fout, "#ID\tT_NUM\tUTM-X(%d)\tUTM-Y\tdepth\n", znCoord(1));
  endif
 else
  if(e_time)
   fprintf(fout, "#ID\tT_NUM\tTIME\tLAT\tLON\tdepth\n");
  else
   fprintf(fout, "#ID\tT_NUM\tLAT\tLON\tdepth\n");
  endif
 endif

 for n=1:n_step:length(ntr)

  fprintf(fout, '%d',   n);      %ID
  fprintf(fout, '\t%d', ntr(n)); %T_NUM
  
  %time
  if(e_time)
   fprintf(fout, '\t%2.4f', bTime(n));
  endif
  
  %coords
  if(utmCoords)
   fprintf(fout, '\t%0.2f\t%0.2f', xCoord(n), yCoord(n)); %UTM-X, UTM-Y
  else
   fprintf(fout, '\t%0.6f\t%0.6f', yCoord(n), xCoord(n)); %LAT, LON
  endif

  fprintf(fout, '\t%g\n', depth(n));

 endfor

 %close file stream
 fclose(fout); 

endfunction
