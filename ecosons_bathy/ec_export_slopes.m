%[err, err_desc]=ec_export_slopes(SLOPES)
%
%SLOPES
function [err, err_desc]=ec_export_slopes(SLOPES)
 global BATHYMETRY

 err=0;
 err_desc='';

 %perform the SLOPES computation if no object is provided
 if( nargin==0 )
  
  krn_rad=gminput('Kernel radius for slopes calculation (m): ');
   
  if( length(krn_rad)==0 )
   err=1;
   err_desc='Invalid parameters';
   return;
  endif 

  %compute slopes from bathymetry data   
  SLOPES=slopesFromBathymetry(BATHYMETRY, krn_rad);

 endif

 %Export slopes
 fn=gminput('Output SLOPES file (default slopes.dat): ', 's');
 if( length(fn)==0 )
  fn='slopes.dat';
 endif
 
 f=fopen(fn, 'w');
 if( f<0 )
  err=2;
  err_desc=['Unable to open ' fn ' for writing SLOPES'];
  return;
 endif
 
 fprintf(f, 'ID\tlat\tlon\tdepth\tslope\tangle\tcourse\tcosine\n');
 id=0;
 for nt=1:length(BATHYMETRY)
    
  for n=1:length(BATHYMETRY{nt}.time)
   
   id=id+1;
   fprintf(f, '%d\t%0.7f\t%0.7f\t%g\t%g\t%g\t%g\t%g\n',...
               id, BATHYMETRY{nt}.latitude(n), BATHYMETRY{nt}.longitude(n), BATHYMETRY{nt}.depth(n), ...
               SLOPES{nt}.slope(n), SLOPES{nt}.slope_dir(n), SLOPES{nt}.trans_dir(n), SLOPES{nt}.cang(n) );
   
   endfor
   
 endfor

 fclose(f);
 

endfunction

