function s = triana_convertTimeZoneMeasurements2GMT(s)

% load overview of frequencies of tidal components
load([fileparts(which('triana')),filesep,'general',filesep,'Frequency_Tidal_Components.mat']);

for ll = 1:length(s.meas.data)
    if ~isempty(s.meas.data(ll).timeZone) & s.meas.data(ll).timeZone ~= 0
        for cc = 1:length(s.meas.data(ll).Cmp)
            cmpID=find(~cellfun('isempty',regexp(cmp_all.cmp,['^',s.meas.data(ll).Cmp{cc},'$'])));
            if ~isempty(cmpID)
                s.meas.data(ll).G(cc) = mod(s.meas.data(ll).G(cc)-s.meas.data(ll).timeZone*cmp_all.freq(cmpID),360);
            else
                disp(['Couldn''t convert the ',s.meas.data(ll).Cmp{cc},' component to GMT for station ',s.meas.data(ll).name])
            end
        end
    end
end

end