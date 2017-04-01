%
%
function [cols, headers]=csvreadcols(fname, hdr)

 %column cells
 sss={};
 ncmx=0; %max columns
 ssswd=[]; %column cells str. width

 %CSV separator
 csvsep='';

 f=fopen(fname, 'r');
 disp('Computing space needed...');
 nr=0; %row
 while(~feof(f))
  
  s=fgets(f);
  
  %determine CSV separator from majority rule
  if( length(csvsep)==0 )
   n1=sum( s(:)==',' );
   n2=sum( s(:)==';' );
   if( n2>=n1 )
    csvsep=';';
    disp('Assuming CSV separator is ";"');
   else
    csvsep=',';
   endif
  endif

  %compute number of rows
  nr=nr+1;

  %line as cells
  ssst=parseCSVline(s, csvsep);

  %compute max. columns
  if(length(ssst)>ncmx)
   ncmx=length(ssst);
  endif
  
  %compute column max. widths
  for c=1:length(ssst)
   if( c<=length(ssswd) )
    ssswd(c)=max(ssswd(c), length(ssst{c}));
   else
    ssswd(c)=length(ssst{c});
   endif
  endfor
   
 endwhile
 fclose(f);

 %allocate strings space
 for c=1:ncmx
  sss{c}=char( zeros(nr,ssswd(c)) );
  sss{c}(:)=' ';
 endfor

 %load file contents
 f=fopen(fname, 'r');
 disp(['Loading CSV ' num2str(nr) ' records...']);
 nr=0;
 while(~feof(f))
 
  nr=nr+1;
 
  %parse CSV line
  s=fgets(f);
  ssst=parseCSVline(s, csvsep);	

  for c=1:length(ssst)
   if( length(ssst{c})>0 )
    sss{c}(nr,1:length(ssst{c}))=ssst{c};
   else
    sss{c}(nr,1:3)='NaN';
   endif
  endfor
 
 endwhile
 fclose(f);


 %get headers
 headers={};
 if( hdr )
  for n=1:ncmx
   headers{n}=strtrim( sss{n}(1,:) );
   sss{n}=sss{n}(2:end,:);
  endfor
 else
  for n=1:ncmx
   headers{n}=n;
  endfor
 endif


 %get converted rows
 disp(['Extracting rows...']);
 for n=1:ncmx
  if( length(str2num(sss{n}(1,:)))>0 )
   cols{n}=str2num(sss{n});
  else
   cols{n}=sss{n};
  endif
 
 endfor

%headers
%cols

endfunction


%parse CSV line
function sss=parseCSVline(s, csvsep)
 sss={};
 nc=0;

 ss=split(s, ['"' csvsep]);
 for n=1:size(ss,1)
  if(ss(n,1)=='"' && ss(n,end)=='"')
   nc=nc+1;
   sss{nc}=strtrim(ss(n,2:end-1));
  elseif(ss(n,1)=='"')
   nc=nc+1;
   sss{nc}=strtrim(ss(n,2:end));
  else
   sc=split(ss(n,:), csvsep);
   for m=1:size(sc,1)
    nc=nc+1;
    sss{nc}=strtrim(sc(m,:));
   endfor
  endif
 endfor

endfunction

