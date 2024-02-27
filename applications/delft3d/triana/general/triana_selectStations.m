function s = triana_selectStations(s);

meas.X = [s.meas.data.X];
meas.Y = [s.meas.data.Y];

s.modID=[];
s.measID = [];

switch s.selection.opt
    case 1
        for ss = 1:length(s.selection.obs)
            IDstat = find(~cellfun('isempty',regexp(s.model.data.statsAll,s.selection.obs{ss})));
            if ~isempty(IDstat)
                s.modID = [s.modID IDstat];
            end
        end
        
        if isempty(s.modID)
            error('Specified observations points (s.selection.obs) do not exist')
        end
        
        for oo = 1:length(s.modID)
            % calculate for each selected model station the distance to the nearest measurement station
            dist = sqrt((meas.X-s.model.data.XAll(s.modID(oo))).^2 + (meas.Y-s.model.data.YAll(s.modID(oo))).^2);
            if min(dist)<=s.selection.searchRadius
                % find nearest (in case multiple measurement stations are within the searchRadius
                dummy = find(dist == min(dist));
                s.measID(oo) = dummy(1);
                disp(['Selected ',deblank(s.model.data.statsAll{s.modID(oo)}), ' (model) = ',deblank(s.meas.data(s.measID(oo)).name), ' (measurements)'])
            else
                s.measID(oo) = NaN;
                disp(['No measurement station selected for observation point: ',deblank(s.model.data.statsAll{s.modID(oo)})])
            end
        end
    case 2
        obs_nr = 0;
        measSelection = find(meas.Y>= min(s.model.data.YAll)-s.selection.searchRadius & meas.Y<= max(s.model.data.YAll)+s.selection.searchRadius & meas.X >= min(s.model.data.XAll)-s.selection.searchRadius & meas.X <= max(s.model.data.XAll)+s.selection.searchRadius);   % first selection of s.meas stations in the area
        for mm = measSelection
            % determine distances of model stations to each IHO station
            dist = sqrt((s.model.data.XAll-meas.X(mm)).^2 + (s.model.data.YAll-meas.Y(mm)).^2);
            if min(dist)<=s.selection.searchRadius % if nearby stations are available take the closest model station
                obs_nr=obs_nr+1;
                
                s.measID(obs_nr) = mm;
                
                % find nearest (in case multiple observations points are withing the searchRadius
                dummy = find(dist == min(dist));
                s.modID(obs_nr) = dummy(1);
                disp(['Selected ',deblank(s.model.data.statsAll{s.modID(obs_nr)}), ' (model) = ',deblank(s.meas.data(s.measID(obs_nr)).name), ' (measurements)'])
            end
        end
end
