%[err, err_desc]=ec_plot_interpolation
%
function [err, err_desc]=ec_plot_interpolation

 err=0;
 err_desc='';

 %type of representation
 sel=gmmenu('Representation:',...
	    'Colored map representation',...  %1
	    '3-D elevation map',...           %2
            'Contour map',...                 %3
	    'Quit' ...                        %4
	    );
 
 %quit before computation
 if( sel==4 )
  err=-1;
  return;
 endif
 
 %perform interpolation
 [Is,utmCoords,gX_min,gX_max,gY_min,gY_max,znCoord]=ec_ops_interpolation;
 meshX=linspace(gX_min,gX_max,size(Is,2));
 meshY=linspace(gY_max,gY_min,size(Is,1));
 
 %different representations
 switch(sel)

  case 1 %Colored map representation
  
   imagesc(meshX,meshY, -Is);
   
  case 2 %3-D elevation map
   
   %create XY-mesh
   [meshXX,meshYY]=meshgrid(meshX,meshY);
 
   %plot 3-D bathymetry
   mesh(meshXX,meshYY,-Is);
   
  case 3 %Contour map
  
   d_min=min(Is(:));
   d_max=max(Is(:));
   
   %ask for bathymetric lines depths
   disp( ['Interpolation depths range from ' num2str(d_min) 'm to ' num2str(d_max)] )
   bathylines=gminput('Input depths of bathymetric lines (m): ');
   if( length(bathylines)==0 )
    bathylines=[floor(d_min):5:floor(d_max)];
   endif
   
   %plot contours
   contour(meshX,meshY, -Is, -bathylines);
   
 endswitch
 
 %set coordinate axes
 if(utmCoords)
  disp(['UTM-zone: ' num2str(znCoord)]);
  xlabel('UTM-X (m)');
  ylabel('UTM-Y (m)');
 else
  xlabel('lon (m)');
  ylabel('lat (m)');
 endif

 %elevations (-depth)
 zlabel('z (m)');

 %posibility to export image data
 ask=gminput('Export figure data? (y/N) ', 's');
 if( length(ask)~=0 && (ask(1)=='y' || ask(1)=='Y') )
 
  [err, err_desc]=ec_export_interpolation(Is,utmCoords,gX_min,gX_max,gY_min,gY_max,znCoord);
 
 endif
 
endfunction
