%MCBAT=resampleBathymetry(BAT, SLOPES)
%resamples a bathymetry using precomputed slopes
%BAT: bathymetry object
%SLOPES: slopes object {slope ; cang: cosine formed by the slope
%                        and the transect directions }
%srad: sampling radius (meters)
%nrsp: number of simulated samples per point
%Returns MCBAT: a new bathymetry object
function MCBAT=resampleBathymetry(BAT, SLOPES, srad, nrsp)

 %Earth radius (approx.)
 Rt=6367444.66;

 %conversion factors (for the lat-lon)
 dam=(180/pi)*1./6356752.314;
 db=tan(pi*3.5/180);

 %new simulated bathymetry
 MCBAT={};

 for nt=1:length(BAT)

  lt=length(BAT{nt}.time);

  MCBAT{nt}.name=BAT{nt}.name;
  if(lt==0)
   MCBAT{nt}.time=[];
   MCBAT{nt}.latitude=[];
   MCBAT{nt}.longitude=[];
   MCBAT{nt}.depth=[];
   continue;
  elseif(lt>1)
   MCBAT{nt}.time=interp1([0:lt-1]/(lt-1),...
                          BAT{nt}.time,...
                          [0:nrsp*lt-1]/(nrsp*lt-1));
  else
   MCBAT{nt}.time=BAT{nt}.time(1)*ones(1,nrsp);
  endif

  lat  =BAT{nt}.latitude;
  lon  =BAT{nt}.longitude;
  depth=BAT{nt}.depth;
  slope=SLOPES{nt}.slope;
  cang =SLOPES{nt}.cang;
  
  nn=1;
  mclat=[];
  mclon=[];
  mcdepth=[];
  for n=1:lt
  
   %cosine of the latitude
   clat=cos(pi*lat(n)/180);

   %Simulation radii
   rr=srad*sqrt(1-cang(n)**2); %ERRO 1
    
   %random numbers
   dxyz=rr*randn(3,nrsp);

   %take slope into account
   ddpt=slope(n)*dxyz(3,:);

   %replicate ping
   mclat(nn:nn+nrsp-1)  =lat(n)+dxyz(2,:)*dam;
   mclon(nn:nn+nrsp-1)  =lon(n)+dxyz(1,:)*dam/clat;
   mcdepth(nn:nn+nrsp-1)=depth(n)+0*ddpt(:); %!!!
   nn=nn+nrsp;

  endfor

  MCBAT{nt}.latitude=mclat;
  MCBAT{nt}.longitude=mclon;
  MCBAT{nt}.depth=mcdepth;
  
 endfor 

endfunction

