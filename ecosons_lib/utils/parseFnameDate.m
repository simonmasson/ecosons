% [yy,mm,dd]=parseFnameDate(nm, lead_)
% yy, mm, dd: year (4 digits), month and day
% nm: filename
% lead_: number of characters preceeding the date Dyyyymmdd
function [yy,mm,dd]=parseFnameDate(nm, patt)

 if( length(nm)~=length(patt) )
  yy=-1;
  mm=-1;
  dd=-1;
  return;
 endif

 %year
 iy=index(patt, 'yyyy');
 if( iy>0 )
  yy=str2num(nm(iy:iy+3));
 else
  iy=index(patt, 'YYYY');
  if( iy>0 )
   yy=str2num(nm(iy:iy+3));
  else
   yy=NaN;
  endif
 endif

 %month
 im=index(patt, 'mm');
 if( im>0 )
  mm=str2num(nm(im:im+1));
 else
  im=index(patt, 'MM');
  if( im>0 )
   mm=str2num(nm(im:im+1));
  else
   mm=NaN;
  endif
 endif

 %day
 id=index(patt, 'dd');
 if( id>0 )
  dd=str2num(nm(id:id+1));
 else
  id=index(patt, 'DD');
  if( id>0 )
   dd=str2num(nm(id:id+1));
  else
   dd=NaN;
  endif
 endif

endfunction

