%[err,err_desc]=ec_load()
%choses the echosounder type and format to be loaded
%no arguments required
%returns error code and description
%CALLS: utils/gmmenu.m, utils/ginput.m, formats/fmt_simradRAW.m
function [err, err_desc]=ec_load
 global SONAR_DATA;
 global SONAR_DATA_SELECTION;
 err=0;
 err_desc='';
 
 %file format (echosounder type)
 sel=gmmenu('Load data source format:',...
            'Simrad RAW',...   %1
            'Quit');           %final

 %channel selection
 switch( sel )
 
  case 1
   fmtfn=@fmt_simradRAW;
   channel=gminput('Select echosounder channel (default: 1):');
   if( length(channel)~=1 )
    channel=1;
   endif

  otherwise
   err=-1;
   return;
 endswitch
 
 %speed-up file loading
 smt=gminput('Use preloaded MAT files if available? (Y/n) ', 's');
 if( length(smt)==0 )
  smt=true;
 elseif( smt(1)=='Y' || smt(1)=='y' )
  smt=true;
 else
  smt=false;
 endif

 %multiple files by pattern
 patt=gminput('Input file(s) pattern: ', 's');
 f_dir_raw=glob( patt );
 
 if( length(f_dir_raw)==0 )
  err_desc='No file matched the pattern';
  err=1;
  return;
 endif

 %initialize
 SONAR_DATA={};
 SONAR_DATA_SELECTION=0;
 
 for n=1:length(f_dir_raw)
  
  fn=f_dir_raw{n};
  
  [fn_d,fn_n,fn_x]=fileparts(fn);

  if( smt )
   fnmat=fullfile(fn_d, [fn_n '.mat']);

   fnmat_dir=glob( fnmat );  
   if( length(fnmat_dir)==1 )
    load( fnmat, "P", "Q", "G");
   else
    [P, Q, G]=fmtfn(fn);
    save("-float-binary", "-zip", fnmat, "P", "Q", "G");
   endif
  else
   [P, Q, G]=fmtfn(fn);
  endif

  %store file data if channel is available  
  if( length(P)>=channel && length(P{channel})>0 )
   surv.name=fn_n;
   surv.P=P{channel};
   surv.Q=Q{channel};
   surv.G=G;
   
   SONAR_DATA={SONAR_DATA{:}, surv};
   SONAR_DATA_SELECTION=length(SONAR_DATA);
   
  else
   disp(['Error: ' fn_n ' does not have channel ' num2str(channel) ' data.']);
  endif

 endfor
 
endfunction

