%% This file is a modified version of `/ecosons_lib/formats/fmt_simradRAW.m`
clc
close all
clear

%Reads a single-beam Simrad RAW sonar file into memory
% [P HS PS At Al]=fmt_simradRAW(fname, channel, mxp)
% P{}: channel cells with ping matrices: rows: ping no., columns: echo sample
% HS: channel cells with transducer headers
% PS: GPS +1* time data (time=-1: no data)
% At, Al: athwart- and along-ship electrical angles
% fname: RAW file filename
% RAW0: https://www.ngdc.noaa.gov/mgg/wcd/simradEK60manual.pdf
% RAW3: https://www.kongsberg.com/globalassets/maritime/km-products/product-documents/413763_ea640_ref.pdf
% function [P,HS,PS,At,Al,W,filt]=fmt_simradRAW(fname)
% fname = 'file2.raw';
fname = '../L0002-D20140719-T091658-EA400.raw';
% fname = '../L0003-D20140719-T092547-EA400.raw';

%Initialize returned values
P={};
W={};
At={};
Al={};
HS={};
lHS=struct;
lChIds={};
% PS=struct;
lPS=gpsRead("");

%number of arguments
request_As=[];
request_Wf=[];

%open file
sonarFile=fopen(fname, 'rb');

%sizes
max_channels=0;
max_counts=0;

%transceiver Z
chTrcvZ=0;
filt=struct;

pass=0;
while(pass < 2)
    pass=pass+1;
    fseek(sonarFile, 0, "bof");

    %Initialize counter
    nPings=zeros(1,max_channels);

    while( ~feof(sonarFile) )

        dgrm=readRawDatagram(sonarFile);

        if( pass==1 )

            if( strcmp(dgrm.type, 'XML0') && isfield(dgrm.xml, 'Configuration') )
                tcvs=dgrm.xml.Configuration.Transceivers.Transceiver;
                for nt=1:length(tcvs)
                    tchn=dgrm.xml.Configuration.Transceivers.Transceiver(nt).Channels.Channel;
                    for nc=1:length(tchn)
                        disp('warn!');
                        disp(dgrm.xml.Configuration);
%                         ch=find( strcmp(dgrm.xml.Configuration.Transceivers.Transceiver(nt).Channels.Channel(nc)._ChannelID, lChIds) );
%                         if( ~any(ch) )
%                             lChIds{end+1}=dgrm.xml.Configuration.Transceivers.Transceiver(nt).Channels.Channel(nc)._ChannelID;
%                             chTrcvZ(length(lChIds))=str2num(dgrm.xml.Configuration.Transceivers.Transceiver(nt)._Impedance);
%                         end
                    end
                end
            end

            %    if( strcmp(dgrm.type, 'XML0') && isfield(dgrm.xml, 'Channel') )
            %    %if( strcmp(dgrm.type, 'XML0') && strcmp(dgrm.xml.__name, 'Channels') )
            %     dgrm.xml
            %     for nc=1:length(dgrm.xml.Channel)
            %      ch=find( strcmp(dgrm.xml.Channel(nc)._ChannelID, lChIds) );
            %      if( ~any(ch) )
            %       lChIds{end+1}=dgrm.xml.Channel(nc)._ChannelID;
            %      end
            %     end
            %    end

            if( strcmp(dgrm.type, 'RAW0') || strcmp(dgrm.type, 'RAW3') )

                %sample header
                lH=dgrm.sample;
                if( isfield(lH, 'channelId') )
                    lH.channel=find( strcmp(lH.channelId, lChIds) );
                end

                ch=lH.channel;

                if( ch > max_channels )
                    max_counts(max_channels+1:ch)=0;
                    max_channels=ch;
                    nPings(ch)=0;
                    request_Wf(ch)=0;
                    request_As(ch)=false;
                end

                if( isfield(dgrm, 'data') && isfield(dgrm.data, 'waveform') )
                    if( nargout > 5 )
                        request_Wf(ch)=size(dgrm.data.waveform,2);
                    end
                    request_As(ch)=(nargout>3);
                end

                if( isfield(dgrm, 'data') && isfield(dgrm.data, 'angleAthwartship') )
                    request_As(ch)=(nargout>3);
                end

                nPings(ch)=nPings(ch)+1;
                max_counts(ch)=max(max_counts(ch),lH.count);

            end

        else

            disp(dgrm.type);
            switch(dgrm.type)
                case 'NME0'
                    llPS=gpsRead(dgrm.nmea);
                    if( llPS.time >=0 )
                        lPS=llPS;
                    end

                case 'XML0'

                    if( isfield(dgrm.xml, 'InitialParameter') )
                        chs=dgrm.xml.InitialParameter.Channels;
                        for nc=1:length(chs.Channel)
                            disp('warn!');
                            %                             ch=find( strcmp(chs.Channel(nc)._ChannelID, lChIds) );
                            %                             lHS(ch).channel=ch;
                            %                             lHS(ch).mode=str2num(chs.Channel(nc)._ChannelMode);
                            %                             lHS(ch).pulseForm=str2num(chs.Channel(nc)._PulseForm);
                            %                             if( isfield(chs.Channel(nc), '_Slope') )
                            %                                 lHS(ch).slope=str2num(chs.Channel(nc)._Slope);
                            %                             else
                            %                                 lHS(ch)=0.0;
                            %                             end
                            %                             if( isfield(chs.Channel(nc), '_Frequency') && !isempty(chs.Channel(nc)._Frequency) )
                            %                                 lHS(ch).frequency=str2num(chs.Channel(nc)._Frequency);
                            %                             elseif( isfield(chs.Channel(nc), '_FrequencyStart') )
                            %                                 lHS(ch).frequency=[str2num(chs.Channel(nc)._FrequencyStart) str2num(chs.Channel(nc)._FrequencyEnd)];
                            %                             else
                            %                                 lHS(ch).frequency=0;
                            %                                 warning('Channel datagram without frequency?');
                            %                             end
                            %                             lHS(ch).bandWidth=diff([lHS(ch).frequency 0])(1);
                            %                             lHS(ch).pulseLength=str2num(chs.Channel(nc)._PulseDuration);
                            %                             lHS(ch).sampleInterval=str2num(chs.Channel(nc)._SampleInterval);
                            %                             lHS(ch).transmitPower=str2num(chs.Channel(nc)._TransmitPower);
                        end
                    end

                    if( isfield(dgrm.xml, 'Parameter') )
                        disp('warn!');
                        %                         chn=dgrm.xml.Parameter.Channel;
                        %                         ch=find( strcmp(chn._ChannelID, lChIds) );
                        %                         lHS(ch).channel=ch;
                        %                         lHS(ch).mode=str2num(chn._ChannelMode);
                        %                         lHS(ch).pulseForm=str2num(chn._PulseForm);
                        %                         if( isfield(chn, '_Slope') )
                        %                             lHS(ch).slope=str2num(chn._Slope);
                        %                         else
                        %                             lHS(ch)=0.0;
                        %                         end
                        %                         if( isfield(chn, '_Frequency') && !isempty(chn._Frequency) )
                        %                             lHS(ch).frequency=str2num(chn._Frequency);
                        %                         elseif( isfield(chn, '_FrequencyStart') )
                        %                             lHS(ch).frequency=[str2num(chn._FrequencyStart) str2num(chn._FrequencyEnd)];
                        %                         else
                        %                             lHS(ch).frequency=0;
                        %                             warning('Channel datagram without frequency?');
                        %                         end
                        %                         lHS(ch).bandWidth=diff([lHS(ch).frequency 0])(1);
                        %                         lHS(ch).pulseLength=str2num(chn._PulseDuration);
                        %                         lHS(ch).sampleInterval=str2num(chn._SampleInterval);
                        %                         lHS(ch).transmitPower=str2num(chn._TransmitPower);
                    end

                    if( isfield(dgrm.xml, 'Environment') ) %only one per file?
                        for ch=1:length(lChIds)
                            disp('warn!');
                            %                             lHS(ch).transducerDepth=( depth=str2num(dgrm.xml.Environment._Depth) );
                            %                             lHS(ch).soundVelocity=str2num(dgrm.xml.Environment._SoundSpeed);
                            %                             lHS(ch).temperature=( temperature=str2num(dgrm.xml.Environment._Temperature) );
                            %                             salinity=str2num(dgrm.xml.Environment._Salinity);
                            %                             acidity=str2num(dgrm.xml.Environment._Acidity);
                            %                             %!!!disp(['f=' num2str(lHS(ch).frequency) ', T=' num2str(temperature) ', S=' num2str(salinity), ', D=' num2str(depth) ', pH=' num2str(acidity)])
                            %                             if( isfield(lHS(ch), 'frequency') )
                            %                                 lHS(ch).absorptionCoefficient=alphaAinslieMcColm(lHS(ch).frequency,temperature,salinity,depth,acidity); %calculado a partir de la salinidad, el pH, la temperatura, ...
                            %                             else
                            %                                 lHS(ch).absorptionCoefficient=0.0;
                            %                             end
                        end
                    end

                case 'MRU0'

                    for ch=1:length(lChIds)
                        lHS(ch).heave=dgrm.heave;
                        lHS(ch).roll=dgrm.roll;
                        lHS(ch).pitch=dgrm.pitch;
                        lHS(ch).heading=dgrm.heading;
                    end

                case 'CON0'

                    if( length(dgrm.transducer) > 0 )
                        for ch=1:length(lChIds)
                            lHS(ch).beamType=dgrm.transducer(1).beamType;
                            lHS(ch).gain=dgrm.transducer(1).gain;
                            lHS(ch).equivalentBeamAngle=dgrm.transducer(1).equivalentBeamAngle;
                        end
                    end

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

                    end

                    %sample angles
                    if( request_As(ch) ...
                            && isfield(dgrm.data, "angleAthwartship") ...
                            && isfield(dgrm.data, "angleAlongship") )

                        ll=min(lH.count, length(dgrm.data.power));
                        At{ch}(nPings(ch),1:ll)=dgrm.data.angleAthwartship(1:ll);
                        Al{ch}(nPings(ch),1:ll)=dgrm.data.angleAlongship(1:ll);

                    end

                case 'RAW3'

                    %sample header
                    lH=dgrm.sample;
                    lH.channel=find( strcmp(lH.channelId, lChIds) );
                    ch=lH.channel;
                    ff=fieldnames(lHS);
                    %!!!disp([ "'" lH.channelId "'" " ?= " "'" lChIds{1} "'" " | " "'" lChIds{2} "'" " : " num2str(ch) ])
                    for nf=1:length(ff)
                        lH=setfield(lH, ff{nf}, getfield(lHS(ch),ff{nf}));
                    end

                    nPings(ch)=nPings(ch)+1;

                    %header and last GPS data
                    HS{ch}(nPings(ch))=lH;
                    PS(nPings(ch))=lPS;

                    %sample power
                    if( isfield(dgrm.data, "power") )

                        ll=min(lH.count, length(dgrm.data.power));
                        P{ch}(nPings(ch),1:ll)=dgrm.data.power(1:ll);

                        %sample angles
                        if( request_As(ch) ...
                                && isfield(dgrm.data, "angleAthwartship") ...
                                && isfield(dgrm.data, "angleAlongship") )

                            ll=min(lH.count, length(dgrm.data.power));
                            At{ch}(nPings(ch),1:ll)=dgrm.data.angleAthwartship(1:ll);
                            Al{ch}(nPings(ch),1:ll)=dgrm.data.angleAlongship(1:ll);

                        end

                    end

                    %waveform
                    if( isfield(dgrm.data, "waveform") )

                        ll=min(lH.count, size(dgrm.data.waveform,1));
                        W{ch}(nPings(ch),1:ll,:)=dgrm.data.waveform(1:ll,:);

                        dTX=round(2*lH.pulseLength/lH.sampleInterval); %!número de bins que contienen la señal transmitida
                        P{ch}(nPings(ch),1:ll-dTX)=20*log10( abs( mean(dgrm.data.waveform(1+1*dTX:ll,:),2) ) );

                        if( request_As(ch) )
                            if( isfield(lH, 'beamType') )
                                bt=lH.beamType;
                            else
                                bt=0*(request_Wf(ch)==1)+1*1*(request_Wf(ch)==4)+1*17*(request_Wf(ch)==3);
                            end
                            if( bt>0 )
                                [paAt,paAl]=phaseAngle(squeeze(W{ch}(nPings(ch),1:ll,:)), bt);
                                At{ch}(nPings(ch),1:ll-dTX)=paAt(1+1*dTX:end);
                                Al{ch}(nPings(ch),1:ll-dTX)=paAl(1+1*dTX:end);
                            else
                                At{ch}(nPings(ch),1:ll-dTX)=nan(1,ll-dTX);
                                Al{ch}(nPings(ch),1:ll-dTX)=nan(1,ll-dTX);
                            end
                        end
                    end

                case 'FIL1'
                    ch=find( strcmp(dgrm.channelID, lChIds) );
                    filt(ch).noOfCoefficients(dgrm.stage)=dgrm.noOfCoefficients;
                    filt(ch).decimationFactor(dgrm.stage)=dgrm.decimationFactor;

            end

        end

    end

    if( pass == 1 )

        for ch=1:max_channels
            if( request_Wf(ch) )
                P{ch} = nan(nPings(ch),max_counts(ch));
                W{ch} = nan(nPings(ch),max_counts(ch), request_Wf(ch));
            else
                P{ch} = nan(nPings(ch),max_counts(ch));
            end
            if( request_As(ch) )
                Al{ch}=nan(nPings(ch),max_counts(ch));
                At{ch}=nan(nPings(ch),max_counts(ch));
            end
        end

    end

end %pass
fclose(sonarFile);

% end
figure();
imagesc(P{1}');
figure();
imagesc(P{2}');
