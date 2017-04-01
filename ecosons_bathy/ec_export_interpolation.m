%

function [err, err_desc]=ec_export_interpolation(Is,utmCoords,gX_min,gX_max,gY_min,gY_max,znCoord)
 err=0;
 err_desc='';
 
 sel=gmmenu('Export format: ',...
            'ENVI format',...              %1
            'ArcMap ESRI ASCII format',... %2
            'Quit'...                      %3
	    );
 if( sel==3 )
  err=-1;
  return;
 endif

 %interpolate if no interpolation is provided
 if( nargin~=7 )
  [Is,utmCoords,gX_min,gX_max,gY_min,gY_max,znCoord]=ec_ops_interpolation;
 endif

 %selected format
 switch(sel)

  case 1 %ENVI format
   
   %ask for a filename
   fn=gminput('Output ENVI base file name (default interpolation): ', 's');
   if( length(fn)==0 )
    fn='interpolation';
   endif

   %export image in the appropriate coordinate system
   if( utmCoords )
    img2enviUTM(fn, Is, gX_min,gX_max,gY_min,gY_max,znCoord, {'Bathymetry'} );
   else
    %lon: X, lat: Y
    img2envi(fn, Is, gY_min,gY_max,gX_min,gX_max, {'Bathymetry'} );
   endif

  case 2 %ArcMap ESRI ASCII format

   %ask for a filename
   fn=gminput('Output ESRI-ASCII file name (default interpolation.grd): ', 's');
   if( length(fn)==0 )
    fn='interpolation.grd';
   endif
  
   %coordinate system is inmaterial here
   if( utmCoords )
    img2esriascii(fn, Is, gX_min,gX_max,gY_min,gY_max);
   else
    %lon: X, lat: Y
    %?img2esriascii(fn, Is, gY_min,gY_max,gX_min,gX_max);
    img2esriascii(fn, Is, gX_min,gX_max,gY_min,gY_max);
   endif
   
 endswitch
  
endfunction
