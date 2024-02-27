function hm=cosmos_getRestartTimes(hm)

% Find times at which restart files must be stored

for i=1:hm.nrModels
    
    tana=datenum(2100,1,1);
    
    if ~isempty(hm.models(i).meteowind)
        ii=strmatch(hm.models(i).meteowind,hm.meteoNames,'exact');
        if ~isempty(ii)
            % We want to start with an analyzed wind field
            meteodir=[hm.meteofolder hm.models(i).meteowind filesep];
            tana=readTLastAnalyzed(meteodir);
            tana=rounddown(tana,hm.runInterval/24);
        end
    end

    trst=-1e9;
    trst=max(trst,hm.models(i).tWaveOkay); % Model must be spun-up
    trst=max(trst,hm.models(i).tFlowOkay); % Model must be spun-up
    trst=max(trst,hm.catchupCycle+hm.runInterval/24); % Start time of next cycle
    trst=min(trst,tana); % Restart time no later than last analyzed time in meteo fields
    hm.models(i).restartTime=trst;

end
