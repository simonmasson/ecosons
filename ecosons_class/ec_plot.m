%[err,err_desc]=ec_plot()
%???
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_plot
 global BOTCLASS
 err=0;
 err_desc='';

 sel=gmmenu('Select plot:',...
            'Echogram + bottom detection',...  %1
            'Transects', ...                   %2
            'Multibeam view', ...              %3
            'Class histogram', ...             %4
            'Class classification', ...        %5
            'Class validation', ...            %6
            'Quit'...                          %7
            );

 switch(sel)
 
  case 1 %Echogram + bottom detection
  
   [err, err_desc]=ec_plot_echobottom;
  
  case 2 %Transects

   [err, err_desc]=ec_plot_transects;
  
  case 3 %Multibeam view

   [err, err_desc]=ec_plot_mbview;

  case 4 %Class histogram
  
    [err, err_desc]=ec_plot_class_stat;
  
  case 5 %Class classification

   [err, err_desc]=ec_plot_class_class;

  case 6 %Class validation

   [err, err_desc]=ec_plot_class_valida;

  otherwise
   err=-1;
   return;
 endswitch

endfunction
