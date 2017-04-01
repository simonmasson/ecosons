%[err,err_desc]=ec_plot()
%???
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_plot
 global BATHYMETRY
 err=0;
 err_desc='';

 sel=gmmenu('Select plot:',...
            'Echogram + bottom detection',...  %1
            'Transects', ...                   %2
            '3-D bathymetry', ...              %3
            'Bathymetry transect crosses', ... %4
            'Interpolated bathymetry',...      %5
            'Quit'...                          %6
            );

 switch(sel)
 
  case 1 %Echogram + bottom detection
  
   [err, err_desc]=ec_plot_echobottom;
  
  case 2 %Transects

   [err, err_desc]=ec_plot_transects;
  
  case 3 %3-D bathymetry
  
    [err, err_desc]=ec_plot_bathymetry;
  
  case 4 %Bathymetry transect crosses

   [err, err_desc]=ec_plot_bathycross;

  case 5 %Interpolated bathymetry

   [err, err_desc]=ec_plot_interpolation;

  otherwise
   err=-1;
   return;
 endswitch

endfunction
