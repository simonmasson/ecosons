%Smooths out a signal and returns an (inverse) reliability measure
% the larger this measure is for a given bin, the more this bin
% departs from the smoothed signal
%[ssH, rl]=smoothRange(sH, ll, ff)
% sH: the signal to smooth out
% ll: the window radius of the averaging filter
% ff: the number of sigmas the signal is dismissed when it departs
%  from the averaged value
% ssH: smoothed signal
% rl: inverse reliability
%Note: the signal is robustly interpolated in the given interval
% around each point and from this approximation the standard deviation
% is computed
function [ssH, rl]=smoothRange(sH, ll, ff)
 
 ssH=sH;
 
 for n=1:size(sH,2)
  
  rg=max(1,n-ll):min(n+ll,size(sH,2));
  lr=length(rg);
  w=ones(1,lr)/lr;
  
  iter=1;
  do

   sx=sum( w.*(rg-n) );
   sy=sum( w.*sH(rg) );
   sxx=(w.*(rg-n))*(rg-n)';
   sxy=(w.*(rg-n))*sH(rg)';
  
   mr=(sxy-(sx*sy))/(sxx-(sx*sx));
   avg=(sy-mr*sx);

   w=1 ./( 1 + power( sH(rg) - (mr*(rg-n)+avg), 2) );
   w=w/sum(w);
   
   iter=iter+1;
  until iter==20;
  
  std=sqrt( power( sH(rg) - (mr*(rg-n)+avg), 2 ) * w' );
  
  if(std>0)
   rl(n)=abs(avg-sH(n))/std;
  else
   rl(n)=100;
  endif
  
  if( rl(n) > ff )
   ssH(n)=avg;
  endif
  
 endfor


endfunction

