function hm=cosmos_readOceanModels(hm)

s=xml2struct([hm.dataDir 'oceanmodels' filesep 'OceanModels.xml']);

for i=1:length(s.models.models.model)
    hm.oceanModel(i).name = s.models.models.model(i).model.name;
    hm.oceanModel(i).longName = s.models.models.model(i).model.longname;
    hm.oceanModel(i).URL = s.models.models.model(i).model.url;
    hm.oceanModel(i).type = s.models.models.model(i).model.type;
    hm.oceanModel(i).delay = 8;
    hm.oceanModel(i).cycleInterval = 24;
    hm.oceanModel(i).xLim(1) = str2double(s.models.models.model(i).model.xlim1);
    hm.oceanModel(i).yLim(1) = str2double(s.models.models.model(i).model.ylim1);
    hm.oceanModel(i).xLim(2) = str2double(s.models.models.model(i).model.xlim2);
    hm.oceanModel(i).yLim(2) = str2double(s.models.models.model(i).model.ylim2);
    if isfield(s.models.models.model(i).model,'gridcoordinates')
        hm.oceanModel(i).gridCoordinates = s.models.models.model(i).model.gridcoordinates;
    else
        hm.oceanModel(i).gridCoordinates=[];
    end
    if isfield(s.models.models.model(i).model,'region')
        hm.oceanModel(i).region = s.models.models.model(i).model.region;
    else
        hm.oceanModel(i).region=[];
    end
    hm.oceanModels{i} = s.models.models.model(i).model.longname;
end

for i=1:length(hm.oceanModels)
    hm.oceanModel(i).tLastAnalyzed=rounddown(now-hm.oceanModel(i).delay/24,hm.oceanModel(i).cycleInterval/24);
end
