function s = triana_readDelft3DData(s);

filesRead = unique(s.model.data.fileNr(s.modID));

s.model.data.WL = [];
s.model.data.stats= {};
s.model.data.X = [];
s.model.data.Y = [];
IDmodsAll = [];
for ff = 1:length(filesRead)
    
    trih = qpfopen(s.model.file{filesRead(ff)});
    
    IDmods = find(s.model.data.fileNr(s.modID) == filesRead(ff));
    IDmodsAll = [IDmodsAll;IDmods];
    
    dummy = qpread(trih,'water level','data',0,s.model.data.obsNrFile(s.modID(IDmods)));
    
    if ff > 1 % check if output times are similar
        Time = get_d3d_output_times(s.model.file{ff});
        if s.model.data.Time ~= Time
            smallestInterval = min(diff(Time(1:2)),diff(s.model.data.Time(1:2)));
            timeNew = [min(s.model.data.Time(1),Time(1)):smallestInterval:max(s.model.data.Time(end),Time(end))]
            for ss = 1:size(s.model.data.WL,1)
                WLnew(ss,:) = interp1(s.model.data.Time,s.model.data.WL(ss,:),timeNew);
            end
            for ss = 1:size(dummy.Val,2)
                WLnew(length(s.model.data.WL)+ss,:) = interp1(Time,dummy.Val(:,ss),timeNew);
            end
            s.model.data.Time = timeNew';
            s.model.data.WL = WLnew;
        else
            s.model.data.WL = [s.model.data.WL;dummy.Val'];
        end
    else
        s.model.data.Time = get_d3d_output_times(s.model.file{filesRead(ff)});
        s.model.data.WL = [s.model.data.WL;dummy.Val'];
    end
    
end
% make sure that s.model.data.WL corresponds with the s.modID array
[~,sortID] = sort(IDmodsAll);
s.model.data.WL = s.model.data.WL(sortID,:);

% store only the data at the selected stations
s.model.data.stats = s.model.data.statsAll(s.modID);
s.model.data.X =s.model.data.XAll(s.modID);
s.model.data.Y =s.model.data.YAll(s.modID);

% set interval of new timeseries
s.ana.new_interval = diff(s.model.data.Time(1:2))*1440;