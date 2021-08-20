%[err,err_desc]=ec_bathymetry_resampling()
%replaces the bathymetry by a resampled simulation
%no arguments required
%returns error code and description
%CALLS: utils/csvreadcols.m, procs/resampleBathymetry.m, utils/extractCols.m
function [err, err_desc]=ec_bathymetry_resampling
 global BATHYMETRY
 err=0;
 err_desc='';

 %terrain slope
 smth=gmmenu('Select slope computation:',...
             'External GIS application', ...  %1
       	     'Kernel derivative method', ...  %2
             'No slope computation',...       %3
             'Quit'...                        %4
	           );

 %apply slope method
 switch(smth)
  case 1 %External GIS application
   %csv file name
   col_fn=gminput('GIS output CSV: ', 's');

   %file contains headers
   col_hdr=gminput('Column headers? (Y/n) ', 's');
   if( length(col_hdr)==0 || col_hdr(1)=='y' || col_hdr(1)=='Y' )
    col_hdr=true;
   else
    col_hdr=false;
   endif
   
   %column IDs
   if(col_hdr)
    col_id=gminput('Ping ID column: ', 's');
    col_slp=gminput('Slope column: ', 's');
    col_ang=gminput('Slope direction colum: ', 's');
    col_tang=gminput('Transect direction column: ', 's');
   else
    col_id=gminput('Ping ID column no.: ');
    col_slp=gminput('Slope column no.: ');
    col_ang=gminput('Slope direction colum no.: ');
    col_tang=gminput('Transect direction column no.: ');
   endif
   
   %angle units
   col_deg=gminput('Angular unit (DEG/rad)? ', 's');
   if( length(col_deg)==0 || col_deg(1)=='d' || col_deg(1)=='D' )
    degf=pi/180;
   else
    degf=1.0;
   endif

   %slope in percent
   col_slpf=gminput('Slope measured (default %/per unit)? ', 's');
   if( length(col_slpf)==0 || col_slpf(1)=='%' )
    slpf=0.01;
   else
    slpf=1.0;
   endif
   
   %check parameters
   if( length(col_fn)==0 || length(col_id)==0 || length(col_slp)==0 || length(col_ang)==0 || length(col_tang)==0
    || length( glob(col_fn) )==0 )
    err=1;
    err_desc='Invalid parameters';
    return;
   endif
   
   %load CSV
   [cols, hdrs]=csvreadcols(col_fn, col_hdr);
   
   %extract cols
   ecols=extractCols(hdrs,cols,...
                     col_id, col_slp, col_ang, col_tang);

   
   %sort per col_id
   [ecols{1}, idx]=sort(ecols{1});
   ecols{2}=ecols{2}(idx);
   ecols{3}=ecols{3}(idx);
   ecols{4}=ecols{4}(idx);
   
   %create slopes object with the same structure as bathymetry
   SLOPES={};
   nid=1;
   id=0;
   for nt=1:length(BATHYMETRY)
    
    for n=1:length(BATHYMETRY{nt}.time)
    
     id=id+1;
     
     if( nid<=length(ecols{1}) && id==ecols{1}(nid) )

      SLOPES{nt}.slope(n)=slpf*ecols{2}(nid);
      SLOPES{nt}.slope_dir(n)=degf*ecols{3}(nid);
      SLOPES{nt}.trans_dir(n)=degf*ecols{4}(nid);
      SLOPES{nt}.cang(n)=cos(degf*(ecols{3}(nid)-ecols{4}(nid)));

      nid=nid+1;
           
     else
     
      SLOPES{nt}.slope(n)=0;
      SLOPES{nt}.slope_dir(n)=-1;
      SLOPES{nt}.trans_dir(n)=-1;
      SLOPES{nt}.cang(n)=0.5;

     endif
    
    endfor
   
   endfor
   
  case 2 %Kernel derivative method

   krn_rad=gminput('Kernel radius for slopes calculation (m): ');
   
   if( length(krn_rad)==0 )
    err=1;
    err_desc='Invalid parameters';
    return;
   endif 

   %compute slopes from bathymetry data
   SLOPES=slopesFromBathymetry(BATHYMETRY, krn_rad);
   
  case 3 %No slope computation
  
   SLOPES={};

   for nt=1:length(BATHYMETRY)
    
    SLOPES{nt}.slope=zeros(1,length(BATHYMETRY{nt}.time));
    SLOPES{nt}.cang=0.5*ones(1,length(BATHYMETRY{nt}.time));
   
   endfor

  otherwise %Quit
   err=-1;
   return;

 endswitch
  
 %input resampling parameters
 srad=gminput('Gaussian resampling radius (standard deviation, 5 m): ');
 if( length(srad)==0 )
  srad=5;
 endif

 nrsp=gminput('Number of simulated samples per point (10): ');
 if( length(nrsp)==0 )
  nrsp=10;
 endif

 %ask the user whether to save computed slopes
 qst=gminput('Export computed slopes? (y/N) ', 's');
 if( length(qst)>0 && (qst(1)=='y' || qst(1)=='Y') )
  [err, err_desc]=ec_export_slopes(SLOPES);
 endif

 %perform resampling
 BATHYMETRY=resampleBathymetry(BATHYMETRY, SLOPES, srad, nrsp);

endfunction

