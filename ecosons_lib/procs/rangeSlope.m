%Computes the range slope in terms of the indicated abscissae
%[ssl]=rangeSlope(sH, sX, ll)
% sH: the heights
% sH: the distance (or time)
% ll: the window radius of the averaging filter
% ssl: smoothed slope
%Note: the signal is robustly interpolated in the given interval
% around each point
function [ssl]=rangeSlope(sH, sX, ll)
 
 for n=1:size(sH,2)
  
  rg=max(1,n-ll):min(n+ll,size(sH,2));
  lr=length(rg);
  w=ones(1,lr)/lr;
  
  iter=1;
  do

   sx=w*(sX(rg)-sX(n))';
   sy=w*sH(rg)';
   sxx=(w.*(sX(rg)-sX(n)))*(sX(rg)-sX(n))';
   sxy=(w.*(sX(rg)-sX(n)))*sH(rg)';
  
   mr=(sxy-(sx*sy))/(sxx-(sx*sx));
   avg=(sy-mr*sx);

   w=1 ./( 1 + power( sH(rg) - (mr*(sX(rg)-sX(n))+avg), 2) );
   w=w/sum(w);
   
   iter=iter+1;
  until iter==20;
  
  ssl(n)=mr;
  
 endfor


endfunction

