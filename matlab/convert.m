%% This file is a modified version of `/ecosons_lib/formats/fmt_simradRAW.m`

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
fname = '../L0002-D20140719-T091658-EA400.raw';

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

            switch(dgrm.type)
                case 'NME0'
                    llPS=gpsRead(dgrm.nmea);
                    if( llPS.time >=0 )
                        lPS=llPS;
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
