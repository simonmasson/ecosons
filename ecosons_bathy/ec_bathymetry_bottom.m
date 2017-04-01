%[err,err_desc]=ec_bathymetry_bottom()
%inputs bottom computation parameters
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_bathymetry_bottom
 global SONAR_DATA
 global SONAR_DATA_SELECTION
 err=0;
 err_desc='';

 %check data availability
 if( ~iscell(SONAR_DATA) || length(SONAR_DATA)==0 )
  err=1;
  err_desc='Error: no echograms defined';
  return;
 endif

 sel=gmmenu('Bottom algorithms:',... 
  'Averaged bounce',... %1
  'Max+threshold',...   %2
  'Quit'...             %3
  );

 %input bottom line (max+threshold) procedure parameters
 switch sel

  case 1 %Averaged bounce

  %near field (surface reberberation; no depth smaller)
  dep0=gminput('Near field approx. (default 1.0 m): ');
  if( length(dep0)!=1 )
   dep0=1.0;
  endif

  %apply algorithm
  for sds=SONAR_DATA_SELECTION
   dta=SONAR_DATA{sds};
  
   dta.R=getAverageHit(dta.P, dta.Q, dep0);
   
   SONAR_DATA{sds}=dta;

  endfor

  case 2 %Max+threshold

   %main threshold
   ndB =gminput('First threshold (default 30 dB):  ');
   if( length(ndB)!=1 )
    ndB=30;
   endif

   %second threshold
   nndB=gminput('Second threshold (default 60 dB): ');
   if( length(nndB)!=1 )
    nndB=60;
   endif

   %check thresholds
   if( ~(length(ndB)==1 && length(nndB)==1 && ndB<nndB) )

    err=1;
    err_desc='Invalid threshold selection';

    return;
   endif

   %near field (surface reberberation; no depth smaller)
   dep0=gminput('Near field approx. (default 1.0 m): ');
   if( length(dep0)!=1 )
    dep0=1.0;
   endif

   %apply algorithm
   for sds=SONAR_DATA_SELECTION
    dta=SONAR_DATA{sds};

    dta.R=getFirstHit(dta.P, dta.Q, dep0, ndB, nndB);
    
    SONAR_DATA{sds}=dta;
   endfor

  otherwise %Quit
   err=-1;
   return;

 endswitch


 %smoothing algorithm: ping radius and threshold deviation
 smoothR=gminput('Range smoothing radius (no. pings; default no smoothing): ');
 if( length(smoothR)==1 )
  smoothS=gminput('Smoothing sigmas (default, 3): ');
  if( length(smoothS)~=1 )
   smoothS=3.0;
  endif

  %run filtering
  for sds=SONAR_DATA_SELECTION
   dta=SONAR_DATA{sds};

   %apply smoothing if requested
   if( length(smoothR)==1 )
    dta.R=smoothRange(dta.R, smoothR, smoothS);
   endif
    
   SONAR_DATA{sds}=dta;
  endfor

 endif




endfunction


