%[err,desc]=ec_select(...)
%selects the working transects
%returns the error code and its description
%CALLS: utils/gminput.m, utils/gmmenu.m
function [err, err_desc]=ec_select
 global SONAR_DATA
 global SONAR_DATA_SELECTION
 err=0;
 err_desc='';

 if( ~iscell(SONAR_DATA) || length(SONAR_DATA)==0 )
  err=1;
  err_desc='No data to select. Load a transect data first';
  return;
 endif

 sel=gmmenu('Choose selection method:',...
            'From transect list',...          %1
            'Nearest transect to a point',... %2
            'Quit'...                         %3
            );
 switch(sel)
  case 1 %From transect list

   for n=1:length(SONAR_DATA)
    disp( ['[', num2str(n), '] ', SONAR_DATA{n}.name] );
   endfor

   sel=gminput('Select named transect number: ');

   if( length(sel)>0 )
    if( ~isnan(sel) && 0<sel && sel<=length(SONAR_DATA) )
     SONAR_DATA_SELECTION=sel;
    else
     err=1;
     err_desc='Wrong selection';
     return
    endif
   endif

  case 2 %Nearest transect to a point

   latlon=gminput('Input latitude and longitude coordinates (as [lat, lon]): ');
   if( length(latlon)~=2 )
    err=1;
    err_desc='Wrong point specification';
    return;
   endif
    
   lat=latlon(1);
   lon=latlon(2);   

   nmaxtr=gminput('Input number of transects to select (default, 1): ');
   if( length(nmaxtr)~=1 )
    nmaxtr=1;
   endif

   disttr=NaN*zeros(1,nmaxtr);
   numbtr=NaN*zeros(1,nmaxtr);
   for n=1:length(SONAR_DATA)
    G=SONAR_DATA{n}.G;
    for p=1:length(G)
     if(G(p).time>0)
      d=(G(p).latitude-lat)**2+(G(p).longitude-lon)**2;
      if( any(numbtr==n) )
       if( d<disttr(numbtr==n) )
        ma=(numbtr~=n & disttr<d);
        mb=(numbtr~=n & disttr>d);
        disttr=[disttr(ma) d disttr(mb)];
        numbtr=[numbtr(ma) n numbtr(mb)];
       endif
      else
       if( any(d<disttr | isnan(disttr) ) )
        ma=(disttr<d);
        mb=(disttr>d)(1:end-1);
        disttr=[disttr(ma) d disttr(mb)];
        numbtr=[numbtr(ma) n numbtr(mb)];
       endif
      endif
     endif

     if( length(disttr)<nmaxtr )
      disttr=[disttr nan(1,nmaxtr-length(disttr))];
      numbtr=[numbtr nan(1,nmaxtr-length(numbtr))];
     endif

    endfor
   endfor

   numbtr
   SONAR_DATA_SELECTION=numbtr(~isnan(numbtr));

 endswitch

 disp( ['Selected: ', num2str(SONAR_DATA_SELECTION)] );

endfunction

