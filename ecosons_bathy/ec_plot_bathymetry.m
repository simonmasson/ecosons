%[err, err_desc]=ec_plot_bathymetry
%plots a 3-D map of the transects
%err, err_desc: 
function [err, err_desc]=ec_plot_bathymetry
 global EC_PLOT_CHAR

 err=0;
 err_desc='';
 
 %build data
 [ntr, utmCoords, xCoord, yCoord, znCoord, depth, bTime]=ec_ops_bathymetry;
 if( length(ntr)==0 )
  err=1;
  err_desc='No valid data source';
  return;
 endif

 %categorize
 categy=unique(ntr);
 
 %plot transects
 vargs={};
 for n=1:length(categy)
  vargs{4*n-3}=xCoord(ntr==categy(n));
  vargs{4*n-2}=yCoord(ntr==categy(n));
  vargs{4*n-1}=-depth(ntr==categy(n));
  vargs{4*n  }=EC_PLOT_CHAR;
 endfor

 plot3(vargs{:});

 %axes
 if( utmCoords )
  xlabel(['UTM-X (' num2str(znCoord) ')']);
  ylabel('UTM-Y');
 else
  xlabel('longitude');
  ylabel('latitude');
 endif
 zlabel('height');

 %posibility to export image data
 ask=gminput('Export figure data? (y/N) ', 's');
 if( length(ask)~=0 && (ask(1)=='y' || ask(1)=='Y') )
 
  [err, err_desc]=ec_export_bathymetry(ntr, utmCoords, xCoord, yCoord, znCoord, depth, bTime);
 
 endif


endfunction
