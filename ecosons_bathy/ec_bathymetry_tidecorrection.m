%[err,err_desc]=ec_bathymetry_tidecorrection()
%applies tide correction to an acoustic bathymetry
%no arguments required
%returns error code and description
%CALLS: formats/parseFnameDate.m
function [err, err_desc]=ec_bathymetry_tidecorrection
 global BATHYMETRY
 err=0;
 err_desc='';

 dtf=gmmenu('Date format:',...
            'Filename format (eg. Lxxxx-DyyyyMMdd-Ttttttt-SSSSS)',...     %1
            'Input DD-MM-YYYY for every transect',...                     %2
            'Input YYYY-MM-DD for every transect',...                     %3
            'Input [yyyy, mm, dd] for every transect',...                 %4
            'Quit'...                                                     %5
            );

 %empty pattern (to be filled the first time used)
 patt='';

 %immediate quit
 if(dtf==5)
  err=-1;
  return;
 endif

 tdi=gmmenu('Tide information:',...
            'Input tide times and heights',...                      %1
            'Input day tide height filename (hh, mm; hgt (m))',...  %2
	    'Automatically choose a tide height file',...           %3
            'Quit'...                                               %4
            );
 %empty pattern (to be filled the first time used)
 tdi_patt='';

 %immediate quit
 if(tdi==4)
  err=-1;
  return;
 endif


 %DTES: tfname, date[yy,mm,dd], times, heigts
 DTES={};


 %run along transects getting the dates and tide parameters
 for nt=1:length(BATHYMETRY)
  BTnm=BATHYMETRY{nt}.name;

  switch(dtf) %use selected date input method
   case 1 %Filename
    if( length(patt)==0 )
     patt=gminput('Filename pattern (eg. Lxxxx-DyyyyMMdd-Ttttttt-SSSSS): ', 's');
     if( length(patt)==0 )
      patt='Lxxxx-DyyyyMMdd-Ttttttt-SSSSS';
     endif

     patt=strtrim(patt); %remove leading or trailing blanks

    endif
    [yy,mm,dd]=parseFnameDate(BTnm, patt);
    disp(['Date ' num2str(yy) '-' num2str(mm) '-' num2str(dd)]);
   case 2 %DD-MM-YYYY
    s=gminput(['Date of "', BTnm, '" (DD-MM-YYYY): '], 's');
    [yy,mm,dd]=parseDDMMYYYY(s);
   case 3 %YYYY-MM-DD
    s=gminput(['Date of "', BTnm, '" (YYYY-MM-DD): '], 's');
    [yy,mm,dd]=parseYYYYMMDD(s);
   case 4 %[yyyy,mm,dd]
    ss=gminput(['Date of "', BTnm, '" [YYYY, MM, DD]: ']);
    yy=ss(1);
    mm=ss(2);
    dd=ss(3);
   otherwise %Quit
    err=-1;
    return;
  endswitch
  
  kwn=false; %check if info for this date is already in
  for n=1:(nt-1)
   if( DTES{n}.date==[yy, mm, dd] )
    kwn=true;
    DTES{nt}=DTES{n};
    break;
   endif
  endfor

  if( ~kwn ) %input tide data for this date

   DTES{nt}.date=[yy, mm, dd];
   
   switch(tdi) %use selected tidal information source
    case 1 %Input tide times and heights
     DTES{nt}.tfname=[]; %no file name provided
     DTES{nt}.times=[];
     DTES{nt}.heights=[];

     n=0;
     tmes=[];
     hgts=[];
     do
      tt=gminput('Time [hh, mm, ss] (empty ends): ');
      if( length(tt)>0 )
       n=n+1;
       if( length(tt)==1 )
        tmes(n)=tt(1);
       elseif( length(tt)==2 )
        tmes(n)=tt(1)+tt(2)/60;
       else
        tmes(n)=tt(1)+tt(2)/60+tt(3)/3600;
       endif
       hgts(n)=gminput('Tide height (m): ');
      else
       if(n<2)
        disp('At least high and low tides are needed');
       endif
      endif
     until( n>=2 && length(tt)==0 );

     %sort times
     [tmes, idx]=sort(tmes);
     hgts=hgts(idx);

     DTES{nt}.times=tmes;
     DTES{nt}.heights=hgts;

    case 2 %Input tide height filename
     do
      s=gminput('File with tide heights (hh, mm, hgt): ', 's');
      s=strtrim(s); %remove leading or trailing blanks
      
      if( length( glob(s) )~=1 )
       disp('A correct filename must be given. Retry.');
      endif
     until( length( glob(s) )==1 );
     DTES{nt}.tfname=s;

    case 3 %Input tide height from date-named file
     if( length(tdi_patt)==0 )
      do
       tdi_patt=gminput('Pattern of the date-tide filename (eg. tides-yyyyMMdd.txt): ', 's');
       tdi_patt=strtrim(tdi_patt);
      until( length(tdi_patt)>0 );
     endif
     
     %replace substrings in filename pattern
     s=strrep(tdi_patt, 'yyyy', sprintf('%0.4d', yy));
      s=strrep(s, 'yy', sprintf('%0.2d', mod(yy,100)));
     s=strrep(s, 'MM', sprintf('%0.2d', mm));
     s=strrep(s, 'dd', sprintf('%0.2d', dd));

     %check if the file exists
     if( length(glob(s))==0 )
      err=1;
      err_desc=['Error: tides file ' s ' not found'];
      return;
     endif
     
     DTES{nt}.tfname=s;

    otherwise %Quit
     err=-1;
     return;
   endswitch

  endif

 endfor

 %apply bathymetry correction
 for nt=1:length(BATHYMETRY)

  disp(['Correcting ' BATHYMETRY{nt}.name]);
  
  if( length( DTES{nt}.tfname )>0 )
   BATHYMETRY{nt}.depth=tidecorrectDay(BATHYMETRY{nt}.depth, BATHYMETRY{nt}.time, DTES{nt}.tfname);
  else
   BATHYMETRY{nt}.depth=tidecorrect(BATHYMETRY{nt}.depth, BATHYMETRY{nt}.time, DTES{nt}.times, DTES{nt}.heights );
  endif
  
 endfor


endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yy, mm, dd]=parseYYYYMMDD(nme)

%YYYY-MM-DD
 yy=str2num(nme(1:4));
 mm=str2num(nme(6:7));
 dd=str2num(nme(9:10));

endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yy, mm, dd]=parseDDMMYYYY(nme)

%DD-MM-YYYY
 yy=str2num(nme(7:10));
 mm=str2num(nme(4:5));
 dd=str2num(nme(1:2));

endfunction

