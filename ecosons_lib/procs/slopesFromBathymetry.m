%SLOPES=slopesFromBathymetry(BAT, krn_rad)
%computes slopes from bathymetry data along transects
%BAT: bathymetry object {latitude, longitude, depth}
%krad: kernel radius (convolution function used for the
%                      interpolation, in meters)
%SLOPES: slopes object {slope; cang: cosine formed by the slope
%                        and the transect directions }
function SLOPES=slopesFromBathymetry(BAT, krad)
 SLOPES={};

 utmZ=-1;
 
 %along transect implementation
 for nt=1:length(BAT)
 
  [x,y,zn]=latlon2utmxy(utmZ, BAT{nt}.latitude, BAT{nt}.longitude);
  if(nt==1)
   utmZ=zn(1);
  endif
  z=BAT{nt}.depth;

  gg=nan(size(z));
  tx=nan(size(z));
  ty=nan(size(z));
  for p=1:length(z)
   d=hypot(x-x(p),y-y(p));
   m=(d<krad & ~isnan(z));
   if( any(m) )
    zm=mean(z(m));
    zs=std(z(m));
    m=(m & abs(z-zm)<=2*zs);
    [~,pa]=max( d(m & [1:length(z)]<=p) );
    [~,pb]=max( d(m & [1:length(z)]>=p) );
    if( ~isempty(pb) && ~isempty(pa) )
     tx(p)=x(pb)-x(pa)+1e-10;
     ty(p)=y(pb)-y(pa)+1e-10;
     gg(p)=(z(pb)-z(pa))/hypot(tx(p),ty(p));
    endif
   endif
  endfor
  
  SLOPES{nt}.slope=gg;
  SLOPES{nt}.slope_dir= ...
  SLOPES{nt}.trans_dir=(180/pi)*atan2(tx,ty);
  SLOPES{nt}.cang=sqrt(0.5)*ones(size(z));
 
 endfor

endfunction

