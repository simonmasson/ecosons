%Computes approximate distances to the first available point
% from an array of GPS+time coordinates
function d2o=gcoords2distances(G)

 Rt=6371008.7714;
 tt=nan*zeros(1,length(G));
 xlt=nan*zeros(1,length(G));
 xln=nan*zeros(1,length(G));
 for n=1:length(G)
  if( G(n).time>0 )
   tt(n)=G(n).time;
   xlt(n)=(pi/180)*G(n).latitude;
   xln(n)=(pi/180)*G(n).longitude;
  endif
 endfor
 [aux,n0]=min(tt);
 px0=sin(xlt(n0))*cos(xln(n0));
 py0=sin(xlt(n0))*sin(xln(n0));
 pz0=cos(xlt(n0));
 d2o=Rt*acos( sin(xlt).*(px0*cos(xln)+py0*sin(xln))+pz0*cos(xlt) );

endfunction


