%value=ec_config(key)
%ecosons configuration parameters
%current key can be: path (of installation), version,
%  features (arbitrary strings)
%returns the value of the key
function value=ec_config(key)
 global ECOSONS_BATHY_HOME

 switch key
 
  case 'path'
   value=which('ecosons');
    value=strrep(value, 'ecosons.m', '');
 
  case 'ecosons_version'
  
   value='20130504';

  case 'ecosons_bathy_version'
  
   value='20130325';
 
 endswitch


endfunction

