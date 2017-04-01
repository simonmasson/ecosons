%
function s=trims(s)

 while(length(s)>1 && s(1)==' ')
  s=s(2:end);
 endwhile
 
 while(length(s)>1 && s(end)==' ')
  s=s(1:end-1);
 endwhile
 
endfunction
