%[err, err_desc]=ec_plot_echobottom
%
%
function [err, err_desc]=ec_export_echobottom
 global SONAR_DATA
 global SONAR_DATA_SELECTION

 err=0;
 err_desc='';

 if( ~iscell(SONAR_DATA) || length(SONAR_DATA)==0 )
  err=1;
  err_desc='No SONAR_DATA data or selection';
  return;
 endif
 
 %output file name
 foutn=gminput('Output file name (default echobottom.dat): ', 's');
 if( length(foutn)==0 )
  foutn='echobottom.dat';
 endif

 %ping skip
 n_step=gminput('Ping step (default 1): ');
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
 
 %ping id counter
 ping_id=0;
 
 %headers
 fprintf(fout, "#ID\tT_NUM\tT_NAME\tN_PING\tLAT\tLON\tDEPTH\n");
 
 %transects
 for sds=SONAR_DATA_SELECTION
  dta=SONAR_DATA{sds};

  if( isfield(dta, 'R') )
   for n=1:n_step:size(dta.P,1)
      
    %depth from sea surface (including exact -2 bins correction)
    depth=(0.5*dta.Q(n).soundVelocity*dta.Q(n).sampleInterval)*(dta.R(n)-2);
    
    ping_id=ping_id+1;
    
    fprintf(fout, '%d',   ping_id);
    fprintf(fout, '\t%d', sds);
    fprintf(fout, '\t%s', dta.name);
    fprintf(fout, '\t%d', n);
    %lat, lon
    if( dta.G(n).time > 0 )
     fprintf(fout, '\t%0.6f\t%0.6f', dta.G(n).latitude, dta.G(n).longitude);
    else
     fprintf(fout, '\t%g\t%g', NaN, NaN);
    endif
    %depth
    fprintf(fout, '\t%g', depth );

    fprintf(fout, '\n');
 
   endfor 
   
   %fprintf(fout, '\n\n'); %no blank lines
   
  endif
 endfor

 %close stream
 fclose(fout);
 
 
endfunction
