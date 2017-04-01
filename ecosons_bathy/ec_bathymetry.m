%[err,err_desc]=ec_bathymetry()
%shows the bathymetry menu
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_bathymetry
 err=0;
 err_desc='';
 
 sel=gmmenu('Bathymetry:',...
            'Bottom detection',...                %1
	    'One-step bathymetry computation',... %2
            'Tide correction',...                 %3
            'Bathymetry subsampling',...          %4
            'Bathymetry resampling',...           %5
            'Restore sonar bathymetry',...        %6
            'Quit');                              %7

 switch( sel )
 
  case 1 %Bottom detection
   [err, err_desc]=ec_bathymetry_bottom;
   
   if( err==0 )
    %create a bathymetry object 
    [err, err_desc]=ec_bathymetry_bathymetry;
   endif
   
  case 2 %One-step bathymetry computation
   [err, err_desc]=ec_bathymetry_onestep;
  
  case 3 %Tide corrected bathymetry
   [err, err_desc]=ec_bathymetry_tidecorrection;

  case 4 %Bathymetry subsampling
   [err, err_desc]=ec_bathymetry_subsampling;

  case 5 %Bathymetry resampling
   [err, err_desc]=ec_bathymetry_resampling;

  case 6 %Restore sonar bathymetry
   [err, err_desc]=ec_bathymetry_bathymetry;

  otherwise
   err=-1;
   return;
 endswitch
 
endfunction

