%cdepth=tidecorrect(sdepth, hmax,tmax, hmin,tmin)
% corrects depths through trigonometrical interpolation of tide heigths
% sdepth: sonar depths
% tmes: sonar measurement times
% hmax: tide max height
% tmax: time of tide max height
% hmin: tide min height
% tmin: time of tide min height
% cdepth: corrected depths
function cdepth=tidecorrect(sdepth, tmes, ttmes, thgts)

 %initialize
 cdepth=sdepth;

 %extrapolate before
 ii=( tmes < ttmes(1) );
 cdepth(ii)=sdepth(ii)-(thgts(2)-0.5*(thgts(2)-thgts(1))*(1+cos(pi*(tmes(ii)-ttmes(1))/(ttmes(2)-ttmes(1)))));

 %interpolate between
 for n=1:(length(ttmes)-1)

  ii=( ttmes(n) <= tmes ) | ( tmes<=ttmes(n+1) );
  cdepth(ii)=sdepth(ii)-(thgts(n+1)-0.5*(thgts(n+1)-thgts(n))*(1+cos(pi*(tmes(ii)-ttmes(n))/(ttmes(n+1)-ttmes(n)))));

 endfor

 %extrapolate after
 ii=( ttmes(end) < tmes );
 cdepth(ii)=sdepth(ii)-(thgts(end)-0.5*(thgts(end)-thgts(end-1))*(1+cos(pi*(tmes(ii)-ttmes(end-1))/(ttmes(end)-ttmes(end-1)))));

endfunction

