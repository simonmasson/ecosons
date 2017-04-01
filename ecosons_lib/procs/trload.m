function [lat,lon,P]=trload(fn, nlat,nlon,nP)

 f=fopen(fn, 'r');
 s=fgets(f); %header
 
 n=1;
 while( ~feof(f) )
 
  s=fgets(f);
  ss=split(s, "\t");
  
  lat(n)=str2num(ss(nlat,:));
  lon(n)=str2num(ss(nlon,:));
  P(n)  =str2num(ss(nP,  :));
  n=n+1;
 
 endwhile

 fclose(f);

endfunction

