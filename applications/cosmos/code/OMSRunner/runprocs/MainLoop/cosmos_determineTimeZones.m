function hm=cosmos_determineTimeZones(hm)

t = timeZones();

for i=1:hm.nrModels
    tstop=hm.models(i).tStop;
    if ~isempty(hm.models(i).timeZone)
        hm.models(i).timeZoneString='local time';
        % Use model stop time to determine time shift
        dt=t.utc2dst(tstop,hm.models(i).timeZone)-tstop;
        hm.models(i).timeShift=dt*24; % hours
    else
        hm.models(i).timeZoneString='GMT';
        hm.models(i).timeShift=0; % hours
    end
    for j=1:hm.models(i).nrStations
        if ~isempty(hm.models(i).stations(j).timeZone)
            hm.models(i).stations(j).timeZoneString='Local time (incl. daylight savings)';
            % Use model stop time to determine time shift
            dt=t.utc2dst(tstop,hm.models(i).stations(j).timeZone)-tstop;
            hm.models(i).stations(j).timeShift=dt*24; % hours
        else
            hm.models(i).stations(j).timeZoneString='GMT';
            hm.models(i).stations(j).timeShift=0; % hours
        end
    end
end
