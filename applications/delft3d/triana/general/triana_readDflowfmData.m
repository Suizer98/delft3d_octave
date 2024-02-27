function s = triana_readDflowfmData(s);

nc_getvarinfo(s.model.file,'waterlevel');
s.model.data.Time = nc_cf_time(s.model.file);

IDTime = find(s.model.data.Time>=s.ana.timeStart & s.model.data.Time<=s.ana.timeEnd);

s.model.data.Time = s.model.data.Time(IDTime);
for ss = 1:length(s.modID)
   s.model.data.WL(ss,:) = nc_varget(s.model.file,'waterlevel',[IDTime(1)-1 s.modID(ss)-1],[length(IDTime) 1])';   
end

% remove stations with NaN water level output
IDdry = find(isnan(sum(s.model.data.WL,2)));
s.model.data.WL(IDdry,:) = [];
s.modID(IDdry) = [];
s.measID(IDdry) = [];

% store only the data at the selected stations
s.model.data.stats = s.model.data.statsAll(s.modID,:);
s.model.data.X =s.model.data.XAll(s.modID);
s.model.data.Y =s.model.data.YAll(s.modID);

% set interval of new timeseries
s.ana.new_interval = diff(s.model.data.Time(1:2))*1440;
s.ana.new_interval = round(s.ana.new_interval);