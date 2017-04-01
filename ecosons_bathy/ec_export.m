%[err,err_desc]=ec_export()
%???
%no arguments required
%returns error code and description
%CALLS: 
function [err, err_desc]=ec_export
 global BATHYMETRY
 err=0;
 err_desc='';

 sel=gmmenu('Export:',...
            'Echogram bottom detection',...   %1
            'Bathymetry data',...             %2
            'Bathymetry slopes', ...          %3
            'Bathymetry transect crosses',... %4
            'Interpolated bathymetry',        %5
            'Current figure as image',...     %6
            'Quit'...                         %7
            );

 switch(sel)
 
  case 1 %Echogram + bottom detection
  
   [err, err_desc]=ec_export_echobottom;
 
  case 2 %Bathymetry data

   [err, err_desc]=ec_export_bathymetry;
   
  case 3 %Bathymetry slopes
  
   [err, err_desc]=ec_export_slopes;

  case 4 %Bathymetry transect crosses

   [err, err_desc]=ec_export_bathycross;

  case 5 %Interpolated bathymetry
  
   [err, err_desc]=ec_export_interpolation;

  case 6 %Current figure as image

   %format selection
   fmtext=['eps'; 'pdf'; 'emf'; 'fig'; 'png'; 'jpg'];
   fmt=gmmenu('Select image format:',...
              'EPS:  Encapsulated PostScript',...         %1
              'PDF:  Portable Document Format',...        %2
              'EMF:  Windows Enhanced Metafile',...       %3
              'FIG:  FIG Format',...                      %4
              'PNG:  Portable Network Graphics',...       %5
              'JPEG: Joint Photograph Experts Group',...  %6
	      'Quit'...
	      );
   if(fmt==7)
    err=-1;
    return;
   endif
   
   %file name (including extension!)
   fname=gminput('Output image file name: ', 's');
   if( length(fname)==0 )
    err=-1;
    return;
   endif

   %print out current figure
   print(fname, '-color', '-solid', '-landscape', [ '-d' fmtext(fmt,:) ] );
  
  otherwise %Quit
   err=-1;
   return;

 endswitch


endfunction
