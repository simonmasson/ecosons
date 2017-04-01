%[err,err_desc]=ec_botclass()
%shows the bathymetry menu
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_botclass
 err=0;
 err_desc='';
 
 sel=gmmenu('Bottom classification:',...
            'Echo alignment and subsampling',...  %1
            '1st echo extraction',...             %2
	    	'2nd echo extraction',...             %3
            'Echo correction',...                 %3
            'Echo classification',...             %4
            'Quit');                              %5

 switch( sel )
 
  case 1 %Echo alignment and subsampling
   [err, err_desc]=ec_echo_stat_align;
      
  case 2 %1st echo extraction
   [err, err_desc]=ec_echo_1st_extract;
  
  case 3 %2nd echo extraction
   [err, err_desc]=ec_echo_2nd_extract;

  case 4 %Echo correction
   [err, err_desc]=ec_echo_correct;

  case 5 %Echo classification
   [err, err_desc]=ec_echo_class;

  otherwise
   err=-1;
   return;
 endswitch
 
endfunction

