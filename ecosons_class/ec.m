%[err,desc]=ec(...)
%ecosons menu call procedure
%the optional arguments contain the succesive menu options selected
%returns the error code and its description
%CALLS: ec_config.m, utils/gmmenu.m
function [err, desc]=ec(varargin)
 global GMMENU_INPUT
 global SONAR_DATA SONAR_DATA_SELECTION
 global EC_PLOT_CHAR
 global BOTCLASS
 
 %if the most basic variables are not set, reset
 if( ~iscell(SONAR_DATA) )
  clear SONAR_DATA
  clear SONAR_DATA_SELECTION

  global SONAR_DATA SONAR_DATA_SELECTION EC_PLOT_CHAR
  
  SONAR_DATA={};
  SONAR_DATA_SELECTION=0;
  EC_PLOT_CHAR='.';

 endif
 
 if( length(BATHYMETRY)==0 )
  clear EC_PLOT_CHAR
  clear BOTCLASS

  global BOTCLASS EC_PLOT_CHAR
  
  BOTCLASS={};
  
  if( ~ischar(EC_PLOT_CHAR) )
   EC_PLOT_CHAR='.';
  endif
  
 endif


 GMMENU_INPUT=varargin;
 
 do
 
  sel=gmmenu('Ecosons_bathy menu',...  %menu title
   'Load transects/survey',...         %1
   'Select working transect',...       %2
   'Bottom classification toolkit',... %3
   'Plot',...                          %4
   'Export',...                        %5
   'Other',...                         %6
   'Quit');                            %7

  err=0;
  desc='';
  
  switch sel
   case 1 %Load transects/survey

    [err, desc]=ec_load;
    if( err==0 )
     disp(desc);
    endif

   case 2 %Select working transect

    [err, desc]=ec_select;
    if( err>0 )
     disp(desc);
    endif

   case 3 %Bottom classification

    [err, desc]=ec_botclass;
    if( err>0 )
     disp(desc);
    endif

   case 4 %Plot
  
    [err, desc]=ec_plot;
    if( err>0 )
     disp(desc);
    endif


   case 5 %Export
  
    [err, desc]=ec_export;
    if( err>0 )
     disp(desc);
    endif

   case 6 %Other
  
    [err, desc]=ec_other;
    if( err>0 )
     disp(desc);
    endif

   otherwise %Quit
    err=-1;
    
  endswitch

 until( err>0 || length(GMMENU_INPUT) == 0 );

 GMMENU_INPUT={};

endfunction

