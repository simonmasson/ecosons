%iterative linear weighted minsqr
function [m,y0,r2]=linreg(X,Y)

 if( size(X,2) == 1 )
  X=X';
 endif
 
 if( size(Y,2) == 1 )
  Y=Y';
 endif

 chi2=1.0;
 arw=zeros(1,length(X));

 for niter=1:10
 
  w=chi2./(chi2+power(arw,2));
  Sw=sum(w);
  Sx=w*X';
  Sy=w*Y';
  Sxx=w*power(X,2)';
  Syy=w*power(Y',2);
  Sxy=w*(X'.*Y');

  y0=(Sxx*Sy-Sx*Sxy)/(Sw*Sxx-Sx*Sx);
  m =(Sw*Sxy-Sx*Sy)/(Sw*Sxx-Sx*Sx);
 
  chi2=y0*y0+(Syy+2*m*Sxy-2*y0*Sy+m*m*Sxx-2*y0*m*Sx)/Sw;
  arw=Y-(y0+m*X);

 endfor
 
 r2=(Sw*Sxy-Sx*Sy)**2/((Sw*Sxx-Sx*Sx)*(Sw*Syy-Sy*Sy));
 
endfunction
