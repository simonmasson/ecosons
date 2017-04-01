% Perform sums avoiding NaNs
function s=nnsum(x)

 if( min(size(x))==1 )
  s=sum( x( ~isnan(x) ) );
 else
  for n=1:size(x,2)
   xc=x(:,n);
   xm=~isnan(xc);
   if( any(xm) )
    s(n)=sum( xc( xm ) );
   else
    s(n)=NaN;
   endif
  endfor
 endif

endfunction
