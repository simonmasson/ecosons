% Performs a min.sqr. trigonometric interpolation
% xp=triginterp(t,x, tp)
% t: independent variable ("time")
% x: values evaluated at t
% tp: interpolation abscissae
% xp: interpolated values
% T: interpolation period (default length(t)*(max(t)-min(t))/(length(t)-1))
function xp=triginterp(t,x, tp, T)
_eps=1e-10;

 %ensure data in rows
 if( size(t,2)==1 )
  t=t';
 endif
 if( size(x,2)==1 )
  x=x';
 endif
 if( size(tp,2)==1 )
  tt=tp';
 else
  tt=tp;
 endif

 %remove NaNs
 sel=(~isnan(t) & ~isnan(x) );
 t=t( sel );
 x=x( sel );

 %default period
 if( nargin<4 )
  T=length(t)*(max(t)-min(t))/(length(t)-1);
 endif

 %average and residue
 A0=mean(x);
 rx=x-A0;
 
 An=zeros(size(t'));
 Bn=zeros(size(t'));

 for n=1:length(t)
 
  %harmonic frequencies
  wfr=2*pi*n/T;
  cs=cos(wfr*t);
  sn=sin(wfr*t);

  %trigonometric regresion sums
  Scx=rx*cs';
  Ssx=rx*sn';
  Sc2=cs*cs';
  Ss2=sn*sn';
  Ssc=sn*cs';

  %regression coefficients
  An(n)=(Ssc*Ssx-Ss2*Scx)/(Ssc**2-Sc2*Ss2+_eps);
  Bn(n)=(Ssc*Scx-Sc2*Ssx)/(Ssc**2-Sc2*Ss2+_eps);

  %residue
  rx=rx-(An(n)*cos(wfr*t)+Bn(n)*sin(wfr*t));

 endfor

 %interpolation formula
 xp=A0;
 for n=1:length(t)
  wfr=2*pi*n/T;
  xp=xp+An(n)*cos(wfr*tp)+Bn(n)*sin(wfr*tp);
 endfor

endfunction
