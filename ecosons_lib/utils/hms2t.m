% Perform sums avoiding NaNs
function t=hms2t(hms)

 t=hms(1);
 if( length(hms)>1 )
  t=t+hms(2)/60;
 endif
 if( length(hms)>2 )
  t=t+hms(3)/3600;
 endif

endfunction
