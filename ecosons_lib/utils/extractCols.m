%ecols=extractCols(hdrs, cols, varargin)
%extracts columns from a cell arrangement of data columns
%hdrs: cells with header names
%cols: cells with data arrays
%varagin: names of hdrs corresponding to the columns to extract
function ecols=extractCols(hdrs, cols, varargin)

 ecols={};
 nc=0; 
 for n=1:length(varargin)

  for m=1:length(hdrs)
   if( (isnumeric(varargin{n}) && isnumeric(hdrs{m}) && varargin{n}==hdrs{m})
    || (ischar(varargin{n}) && ischar(hdrs{m}) && strcmp(varargin{n}, hdrs{m})) )
    nc=nc+1;
    ecols{nc}=cols{m};
    break;
   endif
  
  endfor
  
 endfor

endfunction

