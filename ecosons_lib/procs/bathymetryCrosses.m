%TRANSECTCROSS=bathymetryCrosses(BAT, dp)
%
%CALLS: latlon2utmxy.m
function TRANSECTCROSS=bathymetryCrosses(BAT, dp)

 TRANSECTCROSS={};
 
 %local arrays
 Ccount=0;
 C1lat=[];
 C1lon=[];
 C2lat=[];
 C2lon=[];
 C1ntrsc=[];
 C2ntrsc=[];
 C1nping=[];
 C2nping=[];
 C12dz=[];

 %outer nested loop
 for dsn=1:length(BAT)
  for n=1:dp:(length(BAT{dsn}.time)-dp)

   p1 =[BAT{dsn}.latitude(n), BAT{dsn}.longitude(n)];
   p2 =[BAT{dsn}.latitude(n+dp), BAT{dsn}.longitude(n+dp)];
   p1p=[p1(2), -p1(1)];
   p2p=[p2(2), -p2(1)];
 
   %inner half loop
   for dsm=(dsn+1):length(BAT)
    for m=1:dp:(length(BAT{dsm}.time)-dp)

     q1 =[BAT{dsm}.latitude(m), BAT{dsm}.longitude(m)];
     q2 =[BAT{dsm}.latitude(m+dp), BAT{dsm}.longitude(m+dp)];
     q1p=[q1(2), -q1(1)];
     q2p=[q2(2), -q2(1)];

     rb=( (p2-p1)*(q2p-q1p)' );
     sb=( (q2-q1)*(p2p-p1p)' );
  
     %incidence condition
     if( rb~=0 & sb~=0 )

      ra=( (q1-p1)*(q2p-q1p)' );
      sa=( (p1-q1)*(p2p-p1p)' );
  
      r=ra/rb;
      s=sa/sb;
      
      %convexity condition  
      if( 0<r && r<1 && 0<s && s<1 )
       Ccount=Ccount+1; %store cross
       C1lat(Ccount)=(1-r)*BAT{dsn}.latitude(n)+r*BAT{dsn}.latitude(n+dp);
       C1lon(Ccount)=(1-r)*BAT{dsn}.longitude(n)+r*BAT{dsn}.longitude(n+dp);
       C2lat(Ccount)=(1-s)*BAT{dsm}.latitude(m)+s*BAT{dsm}.latitude(m+dp);
       C2lon(Ccount)=(1-s)*BAT{dsm}.longitude(m)+s*BAT{dsm}.longitude(m+dp);

       C1ntrsc(Ccount)=dsn; %store number of crossing transects
       C2ntrsc(Ccount)=dsm;
       C1nping(Ccount)=n;
       C2nping(Ccount)=m;

       C12dz(Ccount)=( (1-r)*BAT{dsn}.depth(n)+r*BAT{dsn}.depth(n+dp) ) - ...
                     ( (1-s)*BAT{dsm}.depth(m)+s*BAT{dsm}.depth(m+dp) );
      endif
 
     endif

    endfor
   endfor
  
  endfor
 endfor

 %store results in a single object
 if( Ccount>0 )
  TRANSECTCROSS.lon1=C1lon;
  TRANSECTCROSS.lat1=C1lat;
  TRANSECTCROSS.lon2=C2lon;
  TRANSECTCROSS.lat2=C2lat;
 
  TRANSECTCROSS.transect1=C1ntrsc;
  TRANSECTCROSS.transect2=C2ntrsc;
  TRANSECTCROSS.nping1=C1nping;
  TRANSECTCROSS.nping2=C2nping;
  TRANSECTCROSS.ddepth=C12dz;
 endif
 
endfunction

