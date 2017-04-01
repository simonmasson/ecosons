%[err, err_desc]=ec_plot_echobottom
%
%
function [err, err_desc]=ec_plot_echobottom
 global SONAR_DATA
 global SONAR_DATA_SELECTION
 global EC_PLOT_CHAR

 err=0;
 err_desc='';

 %check data availability
 if( ~iscell(SONAR_DATA) || length(SONAR_DATA)==0 )
  err=1;
  err_desc='No echogram available';
  return;
 endif

 %check selection
 if( length(SONAR_DATA_SELECTION)~=1 )
  err=1;
  err_desc='Only single transects can be selected for plots';
  return;
 endif
 
 %load selected transect
 dta=SONAR_DATA{SONAR_DATA_SELECTION};

 rg=gminput('Select ping range (default entire transect): ');
 if( length(rg)==0 )
  rg=[1:size(dta.P,1)];
 endif
 
 bn=gminput('Select bin range (default whole range): ');
 if( length(bn)==0 )
  bn=[1:size(dta.P,2)];
 endif

 %display echogram
 imagesc( rg,bn, dta.P(rg,bn)' );
 
 %if range is available, plot it
 if( isfield(dta, 'R') && length(dta.R>0) )
  %plot( [1:length(rg)], dta.R(rg)-bn(1), EC_PLOT_CHAR );
  hold on
  plot( [1:length(rg)], dta.R(rg)-min(bn(:)), '-' );
  hold off
 endif
 
 %set axes labels
 xlabel('Ping (#)');
 ylabel('Bin (#)')


 %posibility to export image data
 ask=gminput('Export figure data? (y/N) ', 's');
 if( length(ask)~=0 && (ask(1)=='y' || ask(1)=='Y') )
 
  [err, err_desc]=ec_export_echobottom;
 
 endif

endfunction
