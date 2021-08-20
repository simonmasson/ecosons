function v=getfieldvalues(s, f)
 if( isstruct(s) && exist('f') && isfield(s,f) )
  v=[s.(f)]';
 else
  v=[];
 endif
endfunction
