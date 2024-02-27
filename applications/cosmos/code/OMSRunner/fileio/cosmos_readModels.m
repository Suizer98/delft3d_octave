function hm=cosmos_readModels(hm)

dirname=[hm.runDir 'models' filesep];

continent=hm.continents;

%% Find all available models
n=0;
for jj=1:length(continent)
    cntdir=[dirname continent{jj}];
    if exist(cntdir,'dir')
        dr=dir(cntdir);
        for kk=1:length(dr)
            if dr(kk).isdir
                switch dr(kk).name
                    case{'.','..'}
                    otherwise
                        n=n+1;
                        models{n}=dr(kk).name;
                        continents{n}=continent{jj};
                end
            end
        end
    end
end

% Models in scenario have already been read in cosmos_readScenario

for im=1:length(hm.models)
    
    imd=strmatch(hm.models(im).name,models,'exact');

    fname=[dirname continents{imd} filesep hm.models(im).name filesep hm.models(im).name '.xml'];
    dr=[dirname continents{imd} filesep hm.models(im).name filesep];
    [model,ok]=cosmos_readModel(hm,fname,dr);
        
    if ok
        % copy fields in model structure to hm structure
        fld=fieldnames(model);
        for ii=1:length(fld)
            hm.models(im).(fld{ii})=model.(fld{ii});
        end
        hm.models(im).datafolder=[dirname continents{imd} filesep hm.models(im).name filesep];
    else
        disp([hm.models(im).name ' skipped']);
    end
    
end

% Now determine which models are nested in these models

hm.nrModels=length(hm.models);

for i=1:hm.nrModels
    hm.modelNames{i}=hm.models(i).longName;
    hm.modelAbbrs{i}=hm.models(i).name;
    hm.models(i).nestedFlowModels=[];
    hm.models(i).nestedWaveModels=[];
end

for i=1:hm.nrModels
    if hm.models(i).flowNested
        fnest=hm.models(i).flowNestModel;
        mm=findstrinstruct(hm.models,'name',fnest);
        if isempty(mm)
            error(['Model ' fnest ' (in which ' hm.models(i).name ' is nested) not in scenario!']);
        end
        hm.models(i).flowNestModelNr=mm;
        n=length(hm.models(mm).nestedFlowModels);
        hm.models(mm).nestedFlowModels(n+1)=i;
    end
    if hm.models(i).waveNested
        fnest=hm.models(i).waveNestModel;
        mm=findstrinstruct(hm.models,'name',fnest);
        if isempty(mm)
            error(['Model ' fnest ' (in which ' hm.models(i).name ' is nested) not in scenario!']);
        end
        hm.models(i).waveNestModelNr=mm;
        n=length(hm.models(mm).nestedWaveModels);
        hm.models(mm).nestedWaveModels(n+1)=i;
    end
end
