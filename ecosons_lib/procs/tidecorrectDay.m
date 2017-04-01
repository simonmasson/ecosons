%cdepth=tidecorrectDay(sdepth, fname)
% corrects depths through interpolation of recorded tide heigths
% sdepth: sonar depths
% tmes: sonar measurement times
% fname: data file name
function cdepth=tidecorrectDay(sdepth, tmes, fname)

 f=fopen(fname, 'r');
 fgets(f); %#line

 n=0;
 hr=[];
 mn=[];
 hcm=[];
 do
  n=n+1;
  [hr(n),mn(n),hcm(n), c]=fscanf(f, '%d\t%d\t%f', "C");
 until( c~=3 );

 tref=hr+mn/60;
 href=hcm; %assume meters
 
 fclose(f);

 %interpolated correction
 %ddepth=interp1(tref,href, tmes, 'cubic', 'extrap');
 ddepth=triginterp(tref,href, tmes);

 %apply correction
 cdepth=sdepth-ddepth;
 
endfunction


