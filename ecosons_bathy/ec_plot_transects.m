%[err, err_desc]=ec_plot_transects
%plots a 2-D map of the transects
%err, err_desc: 
function [err, err_desc]=ec_plot_transects
 global EC_PLOT_CHAR

 err=0;
 err_desc='';
 
 %build data
 [ntr, utmCoords, xCoord, yCoord, znCoord]=ec_ops_transects;
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
  vargs{3*n-2}=xCoord(ntr==categy(n));
  vargs{3*n-1}=yCoord(ntr==categy(n));
  vargs{3*n  }=EC_PLOT_CHAR;
 endfor

 plot(vargs{1}, vargs{2:end});
 
 %axes
 if( utmCoords )
  xlabel(['UTM-X (' num2str(znCoord) ')']);
  ylabel('UTM-Y');
 else
  xlabel('longitude');
  ylabel('latitude');
 endif

 %posibility to export image data
 ask=gminput('Export figure data? (y/N) ', 's');
 if( length(ask)~=0 && (ask(1)=='y' || ask(1)=='Y') )
 
  [err, err_desc]=ec_export_transects(ntr, utmCoords, xCoord, yCoord, znCoord);
 
 endif


endfunction
