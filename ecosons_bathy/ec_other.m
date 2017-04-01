%[err,err_desc]=ec_other()
%???
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_other
 err=0;
 err_desc='';

 sel=gmmenu('Other operations:',...
            'Set plot char',...                %1
	    'Set canonical sound velocity',... %2
	    'Plot data from file',...          %3
	    'Save SONAR_DATA', ...             %4
	    'Restore SONAR_DATA', ...          %5
	    'Save BATHYMETRY', ...             %6
	    'Restore BATHYMETRY', ...          %7
            'About ecosons_bathy',...          %8
            'Quit'...                          %9
            );

 switch(sel)
  
  case 1 %Set plot char
   global EC_PLOT_CHAR 

   CHRS=['.^+x*o-'];

   %plot symbol
   selc=gmmenu('Select plot symbol:',...
    '.  (dots)',...     %1
    '^  (impulses)',... %2
    '+  (symbol)',...   %3
    'x  (symbol)',...   %4
    '*  (symbol)',...   %5
    'o  (symbol)',...   %6
    '-  (line)',...     %7
    '+- (line-point)'...%8
    );
   if( selc<8 )
    EC_PLOT_CHAR=CHRS(selc);
   else
    EC_PLOT_CHAR='+-';
   endif

   %symbol color
   selc=gmmenu('Select plot color:',...
    'black',...   %1
    'red',...     %2
    'green',...   %3
    'blue',...    %4
    'magenta',... %5
    'cyan',...    %6
    '(default)'...%7
    );
   if( selc<7 )
    EC_PLOT_CHAR=[EC_PLOT_CHAR, num2str(selc-1)];
   endif
  
  
  case 2 %Set canonical sound velocity
   global SONAR_DATA
   global SONAR_DATA_SELECTION
   
   if( ~iscell(SONAR_DATA) )
    err=1;
    err_desc='Only available for echograms';
    return;
   endif    

   cw=gminput('Input canonical sound velocity (1500 m/s): ');
   if( length(cw)~=1 )
    cw=1500;
   endif
   
   for sds=SONAR_DATA_SELECTION
    dta=SONAR_DATA{sds};
    lgt=length(dta.Q);
    for n=1:lgt
     dta.Q(n).soundVelocity=cw;
    endfor

    SONAR_DATA{sds}=dta;
   endfor
   
  case 3 %Plot data from file
   global EC_PLOT_CHAR 

   if( ~ischar(EC_PLOT_CHAR) )
    EC_PLOT_CHAR='*';
   endif

   fname=gminput('Input data file name: ', 's');
   if( length(fname)==0 )
    err=-1;
    return;
   else
    fname=strtrim(fname);
   endif

   %select format
   fmt=gmmenu('Data file type:',...
              'CSV (comma separated values)', ... %1
	      'TSV (tab separated values)',...    %2
	      'Quit'...                           %3
	      );

   %file contains headers
   col_hdr=gminput('Column headers? (Y/n) ', 's');
   if( length(col_hdr)==0 || col_hdr(1)=='y' || col_hdr(1)=='Y' )
    col_hdr=true;
   else
    col_hdr=false;
   endif

   %column IDs
   if(col_hdr)
    col_X=gminput('X column: ', 's');
    col_Y=gminput('Y column: ', 's');
   else
    col_X=gminput('X column no.: ');
    col_Y=gminput('Y column no.: ');
   endif

   %file data is categorized
   col_iscat=gminput('Data is categorized? (N/y) ', 's');
   if( length(col_iscat)==0 || ~( col_iscat(1)=='Y' || col_iscat(1)=='y') )
    col_iscat=false;
   else
    col_iscat=true;

    if(col_hdr)
     col_cat=gminput('Category column: ', 's');
     col_cat=strtrim(col_cat);
    else
     col_cat=gminput('Category column no.: ');
    endif

   endif

   %load data
   switch(fmt)
    case 1 %CSV
    
     [cols, headers]=csvreadcols(fname, col_hdr);
    
    case 2 %TSV
   
     [cols, headers]=tsvreadcols(fname, col_hdr);
     
    otherwise
     err=-1;
     return;
     
   endswitch
   
   %plot all the data
   if( col_iscat )
    xyz=extractCols(headers, cols, col_X, col_Y, col_cat);
    plot3(xyz{:}, EC_PLOT_CHAR);
   else
    xy=extractCols(headers,  cols, col_X, col_Y);
    plot(xy{:}, EC_PLOT_CHAR);
   endif

  case 4 %Save SONAR_DATA

   global SONAR_DATA
   global SONAR_DATA_SELECTION
   
   if( ~iscell(SONAR_DATA) )
    err=1;
    err_desc='Only available for echograms';
    return;
   endif    
  
   fname=gminput('SONAR DATA file name (default: SONAR_DATA.mat): ', 's');
   if( length(fname)==0 )
    fname='SONAR_DATA.mat';
   else
    fname=strtrim(fname);
   endif
   save('-binary', fname, 'SONAR_DATA', 'SONAR_DATA_SELECTION');
  
  case 5 %Restore SONAR_DATA
   global SONAR_DATA
   global SONAR_DATA_SELECTION
  
   fname=gminput('SONAR DATA file name (default: SONAR_DATA.mat): ', 's');
   if( length(fname)==0 )
    fname='SONAR_DATA.mat';
   else
    fname=strtrim(fname);
   endif
   load('-binary', fname, 'SONAR_DATA', 'SONAR_DATA_SELECTION');
   
  case 6 %Save BATHYMETRY
   global BATHYMETRY

   if( ~strcmp( class(BATHYMETRY), 'cell') )
    err=2;
    err_desc='No bathymetry generated';
    return;
   endif    

   fname=gminput('BATHYMETRY file name (default: BATHYMETRY.mat): ', 's');
   if( length(fname)==0 )
    fname='BATHYMETRY.mat';
   else
    fname=strtrim(fname);
   endif
   save('-binary', fname, 'BATHYMETRY');
  
  case 7 %Restore BATHYMETRY
   global BATHYMETRY

   fname=gminput('BATHYMETRY file name (default: BATHYMETRY.mat): ', 's');
   if( length(fname)==0 )
    fname='BATHYMETRY.mat';
   else
    fname=strtrim(fname);
   endif
   load('-binary', fname, 'BATHYMETRY');

  case 8 %About ecosons_bathy
   disp(['Ecosons is free software released under GNU-GPL license']);
   disp([' (see http://www.gnu.org/copyleft/gpl.html)']);
   disp(['Octave version ' version() ' (required >=3.0.1)']);
   disp(['Ecosons for Octave: ' ec_config('ecosons_version')]);
   disp(['Bathymetry toolkit: ' ec_config('ecosons_bathy_version')])
   disp(['http://www.kartenn.net']);

  otherwise %Quit
   err=-1;
   return;

 endswitch

endfunction
