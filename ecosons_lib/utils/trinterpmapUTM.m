%[Is,I,av,se,gX_min,gX_max,gY_min,gY_max]=trinterpmapUTM(gX,gY,P, wRm,cellSz)
%gX, gY: UTM coordinates of the points (meters)
%P: value to be interpolated at gX, gY
%wRm: weight filter radius (meters)
%cellSz: cell size (en meters)
%Is: interpolated map
%I: map with the original points
%av, se: mean value and deviation of the interpolation error
%gX_min,gX_max,gY_min,gY_max: map bounds (with sub-cell precission)
function [Is,I,av,se,gX_min,gX_max,gY_min,gY_max]=trinterpmapUTM(gX,gY,P, wRm,cellSz)

 %Image dimensions
 gY_min=NaN;
 gY_max=NaN;
 gX_min=NaN;
 gX_max=NaN;

 for n=1:length(gY)

  if( isnan(gY_min) || gY(n)<gY_min )
   gY_min=gY(n);
  endif
  if( isnan(gY_max) || gY(n)>gY_max )
   gY_max=gY(n);
  endif
  if( isnan(gX_min) || gX(n)<gX_min )
   gX_min=gX(n);
  endif
  if( isnan(gX_max) || gX(n)>gX_max )
   gX_max=gX(n);
  endif

 endfor

 sizeY=round((gY_max-gY_min)/cellSz);
 sizeX=round((gX_max-gX_min)/cellSz);

 cI=zeros(sizeY, sizeX);
 I =zeros(sizeY, sizeX);
 ct=0;

 for n=1:length(gY)
  if( ~isnan(gX(n)) && ~isnan(gY(n)) && ~isnan(P(n)) )
 
   j=round(1+(gX(n)-gX_min)/(gX_max-gX_min)*(sizeX-1));
   i=round(1+(gY_max-gY(n))/(gY_max-gY_min)*(sizeY-1));
  
   cI(i,j)=cI(i,j)+1;
   I(i,j) =I(i,j)+P(n);
   ct=ct+1;
  endif
 
 endfor 

 if( ct==0 )
  I(:)=NaN;
  Is=I;
  av=NaN;
  se=NaN;
  gY_min=NaN;
  gY_max=NaN;
  gX_min=NaN;
  gX_max=NaN;
  return;
 endif

 I(cI>0)=I(cI>0)./cI(cI>0);
 
 wRs=wRm/cellSz;
 hr=round(3*wRs);
 hat=zeros(2*hr+1,2*hr+1);
 for i=-hr:hr
  for j=-hr:hr
   hat(hr+i+1,hr+j+1)=1/(1+(i*i+j*j)/wRs**2);
  end
 end
 hat(hat<1/(1+(hr/wRs)**2))=0;
 hat=hat/sum(hat(:));

 cIs=conv2(cI>0, hat);
 Is =conv2(I,   hat);
 Is =Is./cIs;
 
 Is = Is(hr:end-hr-1, hr:end-hr-1);
 cIs=cIs(hr:end-hr-1, hr:end-hr-1);
 Is(cIs==0)=NaN;
 
 av=mean(Is(cI>0)-I(cI>0));
 se=std(Is(cI>0)-I(cI>0));

endfunction
