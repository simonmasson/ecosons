%Reads a single-beam Simrad RAW sonar file into memory
% [P HS PS At Al]=fmt_simradRAW(fname, channel, mxp)
% P{}: channel cells with ping matrices: rows: ping no., columns: echo sample
% HS: channel cells with transducer headers
% PS: GPS + time data (time=-1: no data)
% At, Al: athwart- and along-ship electrical angles
% fname: RAW file filename
% RAW0: https://www.ngdc.noaa.gov/mgg/wcd/simradEK60manual.pdf
% RAW3: https://www.kongsberg.com/globalassets/maritime/km-products/product-documents/413763_ea640_ref.pdf
function [P,HS,PS,At,Al]=fmt_simradRAW(fname)

 %Initialize returned values
 P={};
 At={};
 Al={};
 HS={};
  lHS=struct;
  lChIds={};
 PS=struct;
  lPS=gpsRead("");

 %number of arguments
 request_As=[];
 request_Wf=[]; %!!!

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

  while( ~feof(sonarFile) )
 
   dgrm=readRawDatagram(sonarFile);
 
   if( pass==1 )
   
    if( strcmp(dgrm.type, 'XML0') && isfield(dgrm.xml, 'Channel') )
     for nc=1:length(dgrm.xml.Channel)
      ch=find( strcmp(dgrm.xml.Channel(nc)._ChannelID, lChIds) );
      if( ~any(ch) )
       lChIds{end+1}=dgrm.xml.Channel(nc)._ChannelID;
      endif
     endfor
    endif
  
    if( strcmp(dgrm.type, 'RAW0') || strcmp(dgrm.type, 'RAW3') )
    
     %sample header
     lH=dgrm.sample;
     if( isfield(lH, 'channelId') )
       lH.channel=find( strcmp(lH.channelId, lChIds) );
     endif
     
     ch=lH.channel;

     if( ch > max_channels )
      max_counts(max_channels+1:ch)=0;
      max_channels=ch;
      nPings(ch)=0;
      
     endif

     if( isfield(dgrm, 'data') && isfield(dgrm.data, 'waveform') )
      request_Wf(ch)=size(dgrm.data.waveform,2);
     endif

     if( isfield(dgrm, 'data') && isfield(dgrm.data, 'angleAthwartship') )
      request_As(ch)=(nargout>3);
     else
      request_As(ch)=false;
     endif

     nPings(ch)=nPings(ch)+1;
     max_counts(ch)=max(max_counts(ch),lH.count);
        
    endif
    
   else
   
    switch(dgrm.type)
   
    case 'NME0'
     llPS=gpsRead(dgrm.nmea);
     if( llPS.time >=0 )
      lPS=llPS;
     endif

    case 'XML0'
    
     if( isfield(dgrm.xml, 'Channel') )
      for nc=1:length(dgrm.xml.Channel)
       ch=find( strcmp(dgrm.xml.Channel(nc)._ChannelID, lChIds) );
       lHS(ch).channel=ch;
       lHS(ch).mode=str2num(dgrm.xml.Channel(nc)._ChannelMode);
       lHS(ch).pulseForm=str2num(dgrm.xml.Channel(nc)._PulseForm);
       if( isfield(dgrm.xml.Channel(nc), '_Frequency') && !isempty(dgrm.xml.Channel(nc)._Frequency) )
        lHS(ch).frequency=str2num(dgrm.xml.Channel(nc)._Frequency);
       elseif( isfield(dgrm.xml.Channel(nc), '_FrequencyStart') )
        lHS(ch).frequency=[str2num(dgrm.xml.Channel(nc)._FrequencyStart) str2num(dgrm.xml.Channel(nc)._FrequencyEnd)];
       else
        lHS(ch).frequency=NaN;
        warning('Channel datagram without frequency?');
       endif
       lHS(ch).bandWidth=0;
       lHS(ch).pulseLength=str2num(dgrm.xml.Channel(nc)._PulseDuration);
       lHS(ch).sampleInterval=str2num(dgrm.xml.Channel(nc)._SampleInterval);
       lHS(ch).transmitPower=str2num(dgrm.xml.Channel(nc)._TransmitPower);
     endfor
     endif
     
     if( isfield(dgrm.xml, 'Environment') ) %only one per file?
      for ch=1:length(lChIds)
       lHS(ch).transducerDepth=( depth=str2num(dgrm.xml.Environment._Depth) );
       lHS(ch).soundVelocity=str2num(dgrm.xml.Environment._SoundSpeed);
       lHS(ch).temperature=( temperature=str2num(dgrm.xml.Environment._Temperature) );
       salinity=str2num(dgrm.xml.Environment._Salinity);
       acidity=str2num(dgrm.xml.Environment._Acidity);
       %!!!disp(['f=' num2str(lHS(ch).frequency) ', T=' num2str(temperature) ', S=' num2str(salinity), ', D=' num2str(depth) ', pH=' num2str(acidity)])
       if( isfield(lHS(ch), 'frequency') )
        lHS(ch).absorptionCoefficient=alphaAinslieMcColm(lHS(ch).frequency,temperature,salinity,depth,acidity); %calculado a partir de la salinidad, el pH, la temperatura, ...
       else
        lHS(ch).absorptionCoefficient=0.0;
       endif
      endfor
     endif

    case 'MRU0'
    
     for ch=1:length(lChIds)
      lHS(ch).heave=dgrm.heave;
      lHS(ch).roll=dgrm.roll;
      lHS(ch).pitch=dgrm.pitch;
      lHS(ch).heading=dgrm.heading;
     endfor

    case 'CON0'
    
     if( length(dgrm.transducer) > 0 )
      for ch=1:length(lChIds)
       lHS(ch).gain=dgrm.transducer(1).gain;
       lHS(ch).equivalentBeamAngle=dgrm.transducer(1).equivalentBeamAngle;
      endfor
     endif
     
    case 'RAW0'
  
     %sample header
     lH=dgrm.sample;
     ch=lH.channel;
     
     nPings(ch)=nPings(ch)+1;
     
     %header and last GPS data
     HS{ch}(nPings(ch))=lH;
     PS(nPings(ch))=lPS;
     
     %sample power
     if( isfield(dgrm.data, "power") )
        
      ll=min(lH.count, length(dgrm.data.power));
      P{ch}(nPings(ch),1:ll)=dgrm.data.power(1:ll);
     
     endif
     
     %sample angles
     if( request_As(ch) ...
      && isfield(dgrm.data, "angleAthwartship") ...
      && isfield(dgrm.data, "angleAlongship") )
  
      ll=min(lH.count, length(dgrm.data.power));
      At{ch}(nPings(ch),1:ll)=dgrm.data.angleAthwartship(1:ll);
      Al{ch}(nPings(ch),1:ll)=dgrm.data.angleAlongship(1:ll);
     
     endif

    case 'RAW3'
  
     %sample header
     lH=dgrm.sample;
     lH.channel=find( strcmp(lH.channelId, lChIds) );
     ch=lH.channel;
     ff=fieldnames(lHS);
     %!!!disp([ "'" lH.channelId "'" " ?= " "'" lChIds{1} "'" " | " "'" lChIds{2} "'" " : " num2str(ch) ])
     for nf=1:length(ff)
      lH=setfield(lH, ff{nf}, getfield(lHS(ch),ff{nf}));
     endfor
     
     nPings(ch)=nPings(ch)+1;
     
     %header and last GPS data
     HS{ch}(nPings(ch))=lH;
     PS(nPings(ch))=lPS;
     
     %sample power
     if( isfield(dgrm.data, "power") )
        
      ll=min(lH.count, length(dgrm.data.power));
      P{ch}(nPings(ch),1:ll)=dgrm.data.power(1:ll);
     
     endif
     
     %sample angles
     if( request_As ...
      && isfield(dgrm.data, "angleAthwartship") ...
      && isfield(dgrm.data, "angleAlongship") )
  
      ll=min(lH.count, length(dgrm.data.power));
      At{ch}(nPings(ch),1:ll)=dgrm.data.angleAthwartship(1:ll);
      Al{ch}(nPings(ch),1:ll)=dgrm.data.angleAlongship(1:ll);
     
     endif

     %waveform
     if( isfield(dgrm.data, "waveform") )
      
      ll=min(lH.count, size(dgrm.data.waveform,1));
      P{ch}(nPings(ch),1:ll,:)=dgrm.data.waveform(1:ll,:);
     
     endif
    
    endswitch

   endif
    
  endwhile

  if( pass == 1 )
   
   for ch=1:max_channels
    if( request_Wf(ch) )
     P{ch} = nan(nPings(ch),max_counts(ch), request_Wf(ch));
    else
     P{ch} = nan(nPings(ch),max_counts(ch));
    endif
    if( request_As(ch) )
     Al{ch}=nan(nPings(ch),max_counts(ch));
     At{ch}=nan(nPings(ch),max_counts(ch));
    endif
   endfor
   
  endif

 endwhile %pass
 fclose(sonarFile);
 
endfunction


function lPS=gpsRead(nmea)
 lPS.time=-1.0;
 lPS.latitude=0.0;
 lPS.longitude=0.0;
 
 if( length(nmea) > 5 )
 
  ss=strsplit(nmea(4:end), ',');
  switch(ss{1})
  
  %https://gpsd.gitlab.io/gpsd/NMEA.html#_gga_global_positioning_system_fix_data
  
  case 'GGA' %GPS fix data: UTC lat lon
   ll=ss{2};
   lPS.time=str2num(ll(1:2))+str2num(ll(3:4))/60+str2num(ll(5:6))/3600;

   ll=ss{3};
   lPS.latitude=str2num(ll(1:2))+str2num(ll(3:end))/60;
    if( ss{4} == 'S' )
     lPS.latitude=-lPS.latitude;
    endif
   ll=ss{5};
   lPS.longitude=str2num(ll(1:3))+str2num(ll(4:end))/60;
    if( ss{6} == 'W' )
     lPS.longitude=-lPS.longitude;
    endif
   
  case 'GLL' %Geographic position: latitude longitude UTC
   ll=ss{2};
   lPS.latitude=str2num(ll(1:2))+str2num(ll(3:end))/60;
    if( ss{3} == 'S' )
     lPS.latitude=-lPS.latitude;
    endif
   ll=ss{4};
   lPS.longitude=str2num(ll(1:3))+str2num(ll(4:end))/60;
    if( ss{5}(1) == 'W' )
     lPS.longitude=-lPS.longitude;
    endif
   if(length(ss)>6)
     ll=ss{6};
     lPS.time=str2num(ll(1:2))+str2num(ll(3:4))/60+str2num(ll(5:6))/3600;
   else
     lPS.time=-1;
   endif 

  case 'GNS' %Fix data: UTC latitude longitude
   ll=ss{2};
   lPS.time=str2num(ll(1:2))+str2num(ll(3:4))/60+str2num(ll(5:6))/3600;

   ll=ss{3};
   lPS.latitude=str2num(ll(1:2))+str2num(ll(3:end))/60;
    if( ss{4} == 'S' )
     lPS.latitude=-lPS.latitude;
    endif
   ll=ss{5};
   lPS.longitude=str2num(ll(1:3))+str2num(ll(4:end))/60;
    if( ss{6} == 'W' )
     lPS.longitude=-lPS.longitude;
    endif

  case 'GXA' %Transit position: UTC latitude longitude
   ll=ss{2};
   lPS.time=str2num(ll(1:2))+str2num(ll(3:4))/60+str2num(ll(5:6))/3600;

   ll=ss{3};
   lPS.latitude=str2num(ll(1:2))+str2num(ll(3:end))/60;
    if( ss{4} == 'S' )
     lPS.latitude=-lPS.latitude;
    endif
   ll=ss{5};
   lPS.longitude=str2num(ll(1:3))+str2num(ll(4:end))/60;
    if( ss{6} == 'W' )
     lPS.longitude=-lPS.longitude;
    endif
    
  endswitch
 
 endif

endfunction


function dgrm=readRawDatagram(sonarFile, ctx)
 dgrm=struct;
 dgrm.length=fread(sonarFile,1,'int32','ieee-le');
  if( length(dgrm.length) == 0 || dgrm.length==0 )
   dgrm.type='END0';
   return;
  endif
 dgrm.type=sprintf('%c', fread(sonarFile,4,'uchar'));
 dgrm.date(2)=fread(sonarFile,1,'int32','ieee-le');
 dgrm.date(1)=fread(sonarFile,1,'int32','ieee-le');

 switch(dgrm.type)
 case 'CON0'
  hdr=struct;
  hdr.surveyName=sprintf('%c', fread(sonarFile,128,'uchar'));
  hdr.transectName=sprintf('%c', fread(sonarFile,128,'uchar'));
  hdr.sounderName=sprintf('%c', fread(sonarFile,128,'uchar'));
  hdr.version=sprintf('%c', fread(sonarFile, 30,'uchar'));
   fread(sonarFile, 98,'uchar');
  hdr.transducerCount=fread(sonarFile, 1,'int32','ieee-le');

  dgrm.header=hdr;
  
  dgrm.transducer=struct;
  for ntransducer=1:dgrm.header.transducerCount
   tr_des=struct;
   tr_des.channelId=sprintf('%c', fread(sonarFile,128,'uchar'));
   tr_des.beamType=fread(sonarFile, 1,'int32','ieee-le');
   tr_des.frequency=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.gain=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.equivalentBeamAngle=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.beamAlongship=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.beamAthwartship=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.sensitivityAlongship=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.sensitivityAthwartship=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.offsetAlongship=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.offsetAthwartship=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.posX=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.posY=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.posZ=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.dirX=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.dirY=fread(sonarFile, 1,'float32','ieee-le');
   tr_des.dirZ=fread(sonarFile, 1,'float32','ieee-le');
    fread(sonarFile, 8,'uchar');
   tr_des.pulseLengthTable=fread(sonarFile, 5,'float32','ieee-le');
    fread(sonarFile, 8,'uchar');
   tr_des.gainTable=fread(sonarFile, 5,'float32','ieee-le');
    fread(sonarFile, 8,'uchar');
   tr_des.saCorrectionTable=fread(sonarFile, 5,'float32','ieee-le');
    fread(sonarFile, 8,'uchar');
   tr_des.gptSofwareVersion=sprintf('%c', fread(sonarFile,16,'uchar'));
    fread(sonarFile, 20,'uchar');
   

   dgrm.transducer(ntransducer)=tr_des;
  endfor
  
 case 'NME0'
  dgrm.nmea=sprintf('%c',fread(sonarFile,dgrm.length-3*4,'uchar'));
  %!!!disp(['NMEA=' dgrm.nmea]);

 case 'XML0'
  txt=sprintf('%c',fread(sonarFile,dgrm.length-3*4,'uchar'));
  dgrm.xml=parseXML(txt);
  %XML0: Transducers.Transducer(1:N), Transceivers.Transceiver(1:N), etc.
  %XML0: Channel(1:N).{Frequency,PulseDuration,SampleInterval,TransmitPower,SoundVelocity} también un único Channel
  %XML0: Environment.{Depth, SoundSpeed}
  %XML0: Sensor
  %XML0: Ping
  
  
 case 'TAG0'
  dgrm.text=sprintf('%c',fread(sonarFile,dgrm.length-3*4,'uchar'));
   if( length(dgrm.text)>80 )
    dgrm.text=dgrm.text(1:80);
   endif
   %!!!disp(['TAG0=' dgrm.text]);

 case 'MRU0'
  dgrm.heave=fread(sonarFile,1,'float32');
  dgrm.roll=fread(sonarFile,1,'float32');
  dgrm.pitch=fread(sonarFile,1,'float32');
  dgrm.heading=fread(sonarFile,1,'float32');
 
 case 'RAW0'
  samp=struct;
  
  samp.channel=fread(sonarFile, 1,'int16','ieee-le');
  samp.mode=fread(sonarFile, 1,'int16','ieee-le');
  samp.transducerDepth=fread(sonarFile, 1,'float32','ieee-le');
  samp.frequency=fread(sonarFile, 1,'float32','ieee-le');
  samp.transmitPower=fread(sonarFile, 1,'float32','ieee-le');
  samp.pulseLength=fread(sonarFile, 1,'float32','ieee-le');
  samp.bandWidth=fread(sonarFile, 1,'float32','ieee-le');
  samp.sampleInterval=fread(sonarFile, 1,'float32','ieee-le');
  samp.soundVelocity=fread(sonarFile, 1,'float32','ieee-le');
  samp.absorptionCoefficient=fread(sonarFile, 1,'float32','ieee-le');
  samp.heave=fread(sonarFile, 1,'float32','ieee-le');
  samp.roll=fread(sonarFile, 1,'float32','ieee-le');
  samp.pitch=fread(sonarFile, 1,'float32','ieee-le');
  samp.temperature=fread(sonarFile, 1,'float32','ieee-le');
   fread(sonarFile, 12,'uchar');
  samp.offset=fread(sonarFile, 1,'int32','ieee-le');
  samp.count=fread(sonarFile, 1,'int32','ieee-le');
 
  dat=struct;
  if( samp.mode==1 || samp.mode==3 )
   x=fread(sonarFile, samp.count,'int16','ieee-le');
   dat.power=10*log10(2)*x/256;
  endif
  if( samp.mode==2 || samp.mode==3 )
   x=fread(sonarFile, 2*samp.count,'int8','ieee-le');
   dat.angleAthwartship=180*x(1:2:end)/128; %most significant byte
   dat.angleAlongship=180*x(2:2:end)/128;   %least significant byte
  endif

  dgrm.sample=samp;
  dgrm.data=dat;

 case 'RAW3'
  samp.channelId=sprintf('%c', fread(sonarFile,128,'uchar'));
   samp.channelId=samp.channelId( samp.channelId ~= 0 );
  samp.dataType=fread(sonarFile, 1,'int16','ieee-le');
  samp.spare=fread(sonarFile, 1,'int16','ieee-le');
  samp.offset=fread(sonarFile, 1,'int32','ieee-le');
  samp.count=fread(sonarFile, 1,'int32','ieee-le');
 
  dat=struct;
  if( bitand(samp.dataType,1) ) %Power: integer "compressed"
   x=fread(sonarFile, samp.count,'int16','ieee-le');
   dat.power=10*log10(2)*x/256;
  endif
  if( bitand(samp.dataType,2) ) %Angle: integer encoded
   x=fread(sonarFile, 2*samp.count,'int8','ieee-le');
   dat.angleAthwartship=180*x(1:2:end)/128; %most significant byte
   dat.angleAlongship=180*x(2:2:end)/128;   %least significant byte
  endif
  if( bitand(samp.dataType,4) ) %Waveform: complex float 16
   cperSample=floor(samp.dataType/256);
   x=fread(sonarFile, 2*cperSample*samp.count,'float16','ieee-le');
   dat.waveform=reshape(x(1:2:end)+j*x(2:2:end), cperSample, samp.count)';
  endif
  if( bitand(samp.dataType,8) ) %Waveform: complex float 32
   cperSample=floor(samp.dataType/256);
   x=fread(sonarFile, 2*cperSample*samp.count,'float32','ieee-le');
   dat.waveform=reshape(x(1:2:end)+j*x(2:2:end), cperSample, samp.count)';
  endif

  dgrm.sample=samp;
  dgrm.data=dat;
 
 otherwise
  disp(['Unknown datagram: ' dgrm.type]);
  fread(sonarFile,dgrm.length-3*4,'uchar');
 endswitch
 
 dgrm_lc=fread(sonarFile,1,'int32','ieee-le');
 if( dgrm_lc ~= dgrm.length )
  error('File does not conform Simrad Raw Format');
 endif

endfunction


function alpha=alphaAinslieMcColm(f,T,S,D,pH) %Ainslie & McColm, J. Acoust. Soc. Am., Vol. 103, No. 3, March 1998
 f=f/1000; %f in kHz
 D=D/1000; %D in km
 %T in ªC
 %S in PSU ~= 35
 %pH ~= 8
 
 %Boric acid
 A1=0.106*exp((pH - 8)/0.56);
 P1=1;
 f1=0.78*sqrt(S/35)*exp(T/26);
 Boric=(A1*P1*f1*power(f,2))./(power(f,2)+f1**2);

 %MgSO4 contribution
 A2=0.52*(S/35)*(1+T/43);
 P2=exp(-D/6);
 f2=42*exp(T/17);
 MgSO4=(A2*P2*f2*power(f,2))./(power(f,2)+f2**2);

 %Pure water contribution
 A3=0.00049*exp(-(T/27+D/17));
 P3=1;
 H2O=A3*P3*power(f,2);

 %Total absorption (dB/km)
 alpha=(Boric+MgSO4+H2O);

endfunction
