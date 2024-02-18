
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
            lPS.time=str2num(ll(1:2))+1*str2num(ll(3:4))/60+1*str2num(ll(5:6))/3600;

            ll=ss{3};
            lPS.latitude=str2num(ll(1:2))+1*str2num(ll(3:end))/60;
            if( ss{4} == 'S' )
                lPS.latitude=-lPS.latitude;
            end
            ll=ss{5};
            lPS.longitude=str2num(ll(1:3))+1*str2num(ll(4:end))/60;
            if( ss{6} == 'W' )
                lPS.longitude=-lPS.longitude;
            end

        case 'GLL' %Geographic position: latitude longitude UTC
            ll=ss{2};
            lPS.latitude=str2num(ll(1:2))+1*str2num(ll(3:end))/60;
            if( ss{3} == 'S' )
                lPS.latitude=-lPS.latitude;
            end
            ll=ss{4};
            lPS.longitude=str2num(ll(1:3))+1*str2num(ll(4:end))/60;
            if( ss{5}(1) == 'W' )
                lPS.longitude=-lPS.longitude;
            end
            if(length(ss)>6)
                ll=ss{6};
                lPS.time=str2num(ll(1:2))+1*str2num(ll(3:4))/60+1*str2num(ll(5:6))/3600;
            else
                lPS.time=-1;
            end

        case 'GNS' %Fix data: UTC latitude longitude
            ll=ss{2};
            lPS.time=str2num(ll(1:2))+1*str2num(ll(3:4))/60+1*str2num(ll(5:6))/3600;

            ll=ss{3};
            lPS.latitude=str2num(ll(1:2))+1*str2num(ll(3:end))/60;
            if( ss{4} == 'S' )
                lPS.latitude=-lPS.latitude;
            end
            ll=ss{5};
            lPS.longitude=str2num(ll(1:3))+1*str2num(ll(4:end))/60;
            if( ss{6} == 'W' )
                lPS.longitude=-lPS.longitude;
            end

        case 'GXA' %Transit position: UTC latitude longitude
            ll=ss{2};
            lPS.time=str2num(ll(1:2))+1*str2num(ll(3:4))/60+1*str2num(ll(5:6))/3600;

            ll=ss{3};
            lPS.latitude=str2num(ll(1:2))+1*str2num(ll(3:end))/60;
            if( ss{4} == 'S' )
                lPS.latitude=-lPS.latitude;
            end
            ll=ss{5};
            lPS.longitude=str2num(ll(1:3))+1*str2num(ll(4:end))/60;
            if( ss{6} == 'W' )
                lPS.longitude=-lPS.longitude;
            end

    end

end

end

