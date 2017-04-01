%[Is,I,av,se,lat_min,lat_max,lon_min,lon_max]=trinterpola(lat,lon,P, wRm,cellSz)
%lat, lon: coordenadas de los puntos
%P: valor en el punto lat, lon que se va a interpolar
%wRm: radio del filtro de pesos (en metros)
%cellSz: tamaño de una celda del mapa (en metros)
%Is: mapa interpolado
%I: mapa de los puntos antes de la interpolación
%av, se: valor medio y desviación típica del error de interpolación
%lat_min,lat_max,lon_min,lon_max: límites del mapa (con un error inferior a una celda)
function [Is,I,av,se,lat_min,lat_max,lon_min,lon_max]=trinterpmap(lat,lon,P, wRm,cellSz)

 earthR=(6378137.0+6356752.314)/2;

 %Image dimensions
 lat_min=NaN;
 lat_max=NaN;
 lon_min=NaN;
 lon_max=NaN;

 for n=1:length(lat)

  if( isnan(lat_min) || lat(n)<lat_min )
   lat_min=lat(n);
  endif
  if( isnan(lat_max) || lat(n)>lat_max )
   lat_max=lat(n);
  endif
  if( isnan(lon_min) || lon(n)<lon_min )
   lon_min=lon(n);
  endif
  if( isnan(lon_max) || lon(n)>lon_max )
   lon_max=lon(n);
  endif

 endfor

 lonscale=cos((pi/360)*(lat_max+lat_min));
 sizeY=round((pi/180)*(lat_max-lat_min)*(earthR/cellSz));
 sizeX=round((pi/180)*lonscale*(lon_max-lon_min)*(earthR/cellSz));

 cI=zeros(sizeY, sizeX);
 I =zeros(sizeY, sizeX);
 ct=0;

 for n=1:length(lat)
  if( ~isnan(lon(n)) && ~isnan(lat(n)) && ~isnan(P(n)) )
 
   j=round(1+(lon(n)-lon_min)/(lon_max-lon_min)*(sizeX-1));
   i=round(1+(lat_max-lat(n))/(lat_max-lat_min)*(sizeY-1));
  
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
  lat_min=NaN;
  lat_max=NaN;
  lon_min=NaN;
  lon_max=NaN;
  return;
 endif

 I(cI>0)=I(cI>0)./cI(cI>0);
 
 wRs=wRm/cellSz;
 hr=3*wRs;
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
