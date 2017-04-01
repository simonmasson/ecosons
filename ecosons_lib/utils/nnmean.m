% Perform means avoiding NaNs
function s=nnmean(x)

 if( min(size(x))==1 )
  xm=~isnan(x);
  if( any(xm) )
   s=mean( x( xm ) );
  else
   s=NaN;
  endif
 else
  for n=1:size(x,2)
   xc=x(:,n);
   xm=~isnan(xc);
   if( any(xm) )
    s(n)=mean( xc( xm ) );
   else
    s(n)=NaN;
   endif
  endfor
 endif

endfunction
