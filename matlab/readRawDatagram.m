function dgrm=readRawDatagram(sonarFile, ctx)
dgrm=struct;
dgrm.length=fread(sonarFile,1,'int32','ieee-le');
if( length(dgrm.length) == 0 || dgrm.length==0 )
    dgrm.type='END0';
    return;
end
dgrm.type=sprintf('%c', fread(sonarFile,4,'uchar'));
dgrm.date(2)=fread(sonarFile,1,'int32','ieee-le');
dgrm.date(1)=fread(sonarFile,1,'int32','ieee-le');

if dgrm.type~='RAW0'
    if dgrm~='NME0'
        disp('warn')
    end
end

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

        %   dgrm.transducer=struct;
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
        end

    case 'NME0'
        dgrm.nmea=sprintf('%c',fread(sonarFile,dgrm.length-3*4,'uchar'));
        %!!!disp(['NMEA=' dgrm.nmea]);

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
        end
        if( samp.mode==2 || samp.mode==3 )
            x=fread(sonarFile, 2*samp.count,'int8','ieee-le');
            dat.angleAthwartship=180*x(1:2:end)/128; %most significant byte
            dat.angleAlongship=180*x(2:2:end)/128;   %least significant byte
        end

        dgrm.sample=samp;
        dgrm.data=dat;

    otherwise
        disp(['Unknown datagram: ' dgrm.type]);
        fread(sonarFile,dgrm.length-3*4,'uchar');
end

dgrm_lc=fread(sonarFile,1,'int32','ieee-le');
if( dgrm_lc ~= dgrm.length )
    error('File does not conform Simrad Raw Format');
end

end
