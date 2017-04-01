%
%
function [cols, headers]=tsvreadcols(fname, hdr)

 f=fopen(fname, 'r');
 
 %column cells
 sss={};

 nr=0; %row
 ncmx=0; %max columns

 while(~feof(f))
 
  nr=nr+1;
 
  nc=0; %column
  
  s=fgets(f);
  ss=split(s, "\t");

  for n=1:size(ss,1)
   nc=nc+1;
   sss{nc}(nr, 1:length(ss(n,:)))=ss(n,:);
  endfor
 
  if(nc>ncmx)
   ncmx=nc;
  endif
 
 endwhile

 %get headers
 headers={};
 if( hdr )
  for n=1:ncmx
   headers{n}=strtrim(sss{n}(1,:));
   sss{n}=sss{n}(2:end,:);
  endfor
 else
  for n=1:ncmx
   headers{n}=n;
  endfor
 endif

 %get converted rows
 for n=1:ncmx
  cols{n}=str2double(sss{n});
  if( length(cols{n})==0 )
   cols{n}=sss{n};
  endif
 endfor


endfunction


