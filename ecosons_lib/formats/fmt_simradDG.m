%Reads a single-beam Simrad DG sonar file into memory
% [P HS PS At Al]=fmt_simradDG(fname, channel, mxp)
% P{}: channel cells with ping matrices: rows: ping no., columns: echo sample
% HS: channel cells with transducer headers
% PS: GPS + time data (time=-1: no data)
% At, Al: athwart- and along-ship electrical angles
% fname: DG file filename
% ops: configuration options not included in the DG file
%  (frequency, transmitPower, pulseLength, bandWidth, sampleInterval,
%   soundVelocity, absorptionCoefficient, temperature)
function [P,HS,PS,At,Al]=fmt_simradDG(fname, ops)

 %Initialize returned values
 P={};
 At={};
 Al={};
 HS={};
  lHS=struct('channel', 1, 'transducerDepth', 0, 'heave', 0, 'roll', 0, 'potch', 0);
  if( ~exist('ops') )
   lHS.frequency=200000;
   lHS.transmitPower=125; %Watt
   lHS.pulseLength=0.3e-3;
   lHS.bandWidth=NaN;
   lHS.sampleInterval=lHS.pulseLength/4;
   lHS.soundVelocity=1500;
   lHS.absorptionCoefficient=10; %dB/km
   lHS.temperature=NaN;
  else
   lHS.frequency=ifthel(ops, 'frequency', 200000);
   lHS.transmitPower=ifthel(ops, 'transmitPower', 1000);
   lHS.pulseLength=ifthel(ops, 'pulseLength', 0.3e-3);
   lHS.bandWidth=ifthel(ops, 'bandWidth', NaN);
   lHS.sampleInterval=ifthel(ops, 'sampleInterval', lHS.pulseLength/4);
   lHS.soundVelocity=ifthel(ops, 'soundVelocity', 1500);
   lHS.absorptionCoefficient=ifthel(ops, 'absorptionCoefficient', 10);
   lHS.temperature=ifthel(ops, 'temperature', NaN);
  endif

 PS=struct;
  lPS=struct('time', -1.0, 'latitude', NaN, 'longitude', NaN);

 %number of arguments
 request_As=(nargout>3);

 %open file
 sonarFile=fopen(fname, 'rb');

 %sizes
 max_channels=1;
 max_counts=[0];

 pass=0;
 while(pass < 2)
  pass=pass+1;
  fseek(sonarFile, 0, "bof");

  %Initialize counter
  nPings=zeros(1,max_channels);
  nPingsA=zeros(1,max_channels);

  while( ~feof(sonarFile) )
   dgrm=readDGTelegram(sonarFile);
   
   if( pass==1 )
   
    switch(dgrm.type)
     case 'W1'
      ch=1;
      nPings=nPings+1;
      if( length(dgrm.data) > max_counts(ch) )
       max_counts(ch)=length(dgrm.data);
       if(exist('opt') && isfield(opt, 'maxDepth'))
        if( isfield(opt, 'soundVelocity') )
         lHS.sampleInterval=opt.maxDepth/(max_counts(ch)*opt.soundVelocity);
        else
         lHS.sampleInterval=opt.maxDepth/(max_counts(ch)*1500);
        endif
        if( ~isfield(opt, 'pulseLength') )
         lHS.pulseLength=4*lHS.sampleInterval;
        endif
       endif
      endif
      
    endswitch

   else

    switch(dgrm.type)
     case 'GL'
      lPS=dgrm.gpos;
      lPS.time=dgrm.time;
      
     case 'W1'
      ch=1;
      nPings=nPings+1;
      l=length(dgrm.data.power);
      P{ch}(nPings(ch),1:l)=dgrm.data.power;
      
       lHS.offset=0;
       lHS.count=l;
      HS{ch}(nPings)=lHS;
       lPS.time=dgrm.time;
      PS(nPings)=lPS;
   
     case 'B1'
      ch=1;
      nPingsA=nPingsA+1;
      if( request_As )
       l=length(dgrm.data.angleAlongship);
       Al{ch}(nPingsA(ch),1:l)=dgrm.data.angleAlongship;
       At{ch}(nPingsA(ch),1:l)=dgrm.data.angleAthwartship;
      endif
   
    endswitch  

   endif
   
  endwhile
   
  if( pass == 1 )
   
   for ch=1:max_channels
    P{ch} =nan(nPings,max_counts(ch));
    if( request_As )
     Al{ch}=nan(nPings,max_counts(ch));
     At{ch}=nan(nPings,max_counts(ch));
    endif
   endfor
  
  endif
  
 endwhile

 fclose(sonarFile);

endfunction


function tgrm=readDGTelegram(f)

 tgrm=struct;
 %telegram length
 n=fread(f,1,'int32');
 if( length(n) == 0 )
  tgrm.length=0;
  tgrm.type='END0'; %no telegram available (END0 borrowed from RAW spec.)
  return;
 endif
 tgrm.length=n;

 %telegram header
 tgrm.type=fgets(f,2);
 
 %telegram time
 fgets(f,1);
 tme=fgets(f,8);
 fgets(f,1);
  %,HHMMSShh,%
 tgrm.time=str2num(tme(1:2))+str2num(tme(3:4))/60 ...
          +str2num(tme(5:6))/3600+str2num(tme(7:8))/360000;
		
 switch(tgrm.type)
	case 'PR'
		fgets(f,n-12);
	case 'PE'
		fgets(f,n-12);
	case 'CS'
		fgets(f,n-12);
	case 'GL' %geographical coordinates (projection??)
		glc=fgets(f,n-12);
		[geoY,geoH,geoX,geoHH, cc]=sscanf(glc, '%4f,%c,%4f,%c', 'C');
		if(cc==4)
			if( geoH == 'S' )
				geoY=-geoY;
			endif
			if( geoHH== 'W' )
				geoX=-geoX;
			endif
		else
			geoX=geoY=NaN;
		endif
		tgrm.gpos=struct('latitude', geoY, 'longitude', geoX);
	case 'ST'
		fgets(f,n-12)
	case 'D1'
		dph=fread(f,1,'float32');
		sbs=fread(f,1,'float32');
		tno=fread(f,1,'int32');
		fread(f,1,'float32'); %dummy
		
%		samp=struct;
%		samp.depth=dph;
%		samp.Ss=sbs;
%		samp.channel=tno;
%		tgrm.sample=samp;
	case 'E1'
		ntr=fread(f,1,'int32');
		a=fread(f, 5*ntr, 'float32'); %5*ntr or 5*30?
%		 trg=struct('dph', a(1:5:end),...
%		            'cts', a(2:5:end),...
%		            'uts', a(3:5:end),...
%		            'aln', a(4:5:end),...
%		            'ath', a(5:5:end) );
		a=fread(f, ntr, 'float32'); %ntr or 30
%		 trg.sat=a;
%
%		samp=struct;
%		samp.traces=trg;
%		tgrm.sample=samp;
		
	case 'S1'
		nly=fread(f,1,'int32');
		a=fread(f, 3*nly, 'float32'); %5*nly or 5*10?
		%...
	case 'Q1'
		tvg=fread(f, 1, 'int32'); %0: 20logR, 1:40logR
		dph=fread(f, 1, 'float32'); %depth
		dpu=fread(f, 1, 'float32'); %range start
		dpb=fread(f, 1, 'float32'); %range stop
		dpc=fread(f, 1, 'int32');
		dbu=fread(f, 1, 'float32');
		dbb=fread(f, 1, 'float32');
		dbc=fread(f, 1, 'int32');
		bins=fread(f, (n-12-8*4)/2, 'int16');
		
%		samp=struct;
%		samp.TVG=20+tvg*20;
%		samp.depth=dph;
%		samp.pelagicUpper=dpu;
%		samp.pelagicLower=dpb;
%		samp.pelagicCount=dpc;
%		samp.bottomUpper=bdu;
%		samp.bottomLower=bdb;
%		samp.bottomCount=dbc;
%		dat=struct;
%		dat.power=bins;
%		tgrm.sample=samp;
%		tgrm.data=dat;
	case 'B1' %split beam angles
		a=fread(f, n-12, 'int8');
		aaln=a(1:2:end);
		aath=a(2:2:end);

		dat=struct;
		dat.angleAthwartship=180*aaln/64;
		dat.angleAlongship=180*aath/64;
		tgrm.data=dat;
	case 'W1' %power
		wbin=fread(f, (n-12)/2, 'int16');
		
		dat=struct;
		dat.power=10*log10(2)*wbin/256;
		tgrm.data=dat;
	case 'V1'
		sbin=fread(f, (n-12)/2, 'int16');

%		dat=struct;
%		dat.cpower=sbin;
%		tgrm.data=dat;
	case 'P1'
		pbin=fread(f, (n-12)/2, 'int16');

%		dat=struct;
%		dat.cpower=pbin;
%		tgrm.data=dat;
	case 'VL'
		ymd=fgets(f, 6);
		fgets(f,1);
		dist=fread(f,1,'float32');
		
%		tgrm.date=ymd;
	case 'LL'
		fgets(f,n-12);
	case 'A1'
		fgets(f,n-12);
	case 'H1'
		fgets(f,n-12);
	otherwise
		fgets(f,n-12);
%		printf('%s: %s\n', hdr,tme);
	
 endswitch

endfunction

function r=ifthel(a,b,c)
 if( isfield(a,b) )
  r=getfield(a,b);
 else
  r=c;
 endif
endfunction
