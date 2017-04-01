%fn: ENVI filename (without extension)
%I: image 3-D matrix (multiband)
%lat_min,lat_max,lon_min,lon_max: image boundaries
%Idesc: image band descriptions
function img2envi(fn, I, lat_min,lat_max,lon_min,lon_max, Idesc)

 %single band
 if( length(size(I))==2 )
  _I=zeros(1,size(I,1),size(I,2));
  _I(1,:,:)=I;
  I=_I;
  clear _I;
 endif

 %image info
 nbands=size(I,1);
 height=size(I,2);
 width=size(I,3);
 dtype=-1;
  if(islogical(I))
   dtype=1; %8-bit byte
  elseif(isreal(I))
   dtype=4; %32-bit float
  elseif(iscomplex(I))
   dtype=6; %2x32-bit float
  endif

 %geographic location
 utmZ=31+floor((lon_min+lon_max)/12);
 if( (lat_min+lat_max)/2 < 0 )
  utmH='South';
 else
  utmH='North';
 endif
 [uX,uY,zn]=latlon2utmxy([utmZ,utmZ], [lat_min,lat_max], [lon_min,lon_max]);
 utmX=uX(1);
 utmY=uY(2);

 dx=(uX(2)-uX(1))/width;
 dy=(uY(2)-uY(1))/height;

 %header file
 f=fopen([fn, '.hdr'], 'w');

 fprintf(f, 'ENVI\n');
 fprintf(f, 'description = {\n');
 fprintf(f, ' %s }\n', '$Description');
 fprintf(f, 'samples = %d\n', width);
 fprintf(f, 'lines = %d\n', height);
 fprintf(f, 'bands = %d\n', nbands);
 fprintf(f, 'header offset = %d\n', 0);
 fprintf(f, 'file type = %s\n', 'ENVI Standard');
 fprintf(f, 'data type = %d\n', dtype);
 fprintf(f, 'interleave = %s\n', 'bsq');
 fprintf(f, 'sensor type = %s\n', 'Unknown');
 fprintf(f, 'byte order = %d\n', 0);
 fprintf(f, 'x start = %d\n', 1);
 fprintf(f, 'y start = %d\n', 1);
 fprintf(f, 'map info = {%s, %d,%d, %0.3f, %0.3f, %0.3f, %0.3f, %d, %s, WGS-84, units=Meters }\n', ...
                      'UTM', 1, 1, utmX, utmY, dx, dy, utmZ, utmH );
 fprintf(f, 'wavelength units = Unknown\n', 1);

 if( length(Idesc) > 0 )
  fprintf(f, 'band names = {\n');
   fprintf(f, '%s', Idesc{1});
  for nb=2:nbands
   fprintf(f, ', %s', Idesc{nb});
  endfor
   fprintf(f, '}');
 endif

 fclose(f);
 
 % Bands
 f=fopen(fn, 'wb');
 
 switch(dtype)
  case 1 %8-bit byte
   stype='uint8';
   asNaN=255;
  case 4 %32-bit float
   stype='float32';
   asNaN=NaN;
  case 6 %2x32-bit float
   stype='float32';
   asNaN=NaN;
  otherwise
   error("Invalid data type");
  endswitch

 Ib=zeros(size(I,2),size(I,3));
 for nb=1:nbands
  Ib(:)=I(nb,end:-1:1,:);
  if(~isnan(asNaN))
   Ib(isnan(Ib))=asNaN;
  endif
  fwrite(f, Ib', stype);
 endfor
 
 fclose(f);
 
endfunction
