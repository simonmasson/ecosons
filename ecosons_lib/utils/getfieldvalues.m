function v=getfieldvalues(s, f)
 if( isstruct(s) && exist('f') && isfield(s,f) )
  v=nan(length(s),1);
  for n=1:length(s)
   v(n)=getfield(s(n), f);
  endfor
 else
  v=[];
 endif
endfunction
