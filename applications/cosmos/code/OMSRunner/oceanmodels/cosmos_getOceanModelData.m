function cosmos_getOceanModelData(hm)


for i=1:length(hm.oceanModels)

    t0=1e9;
    t1=-1e9;

    oceanname=hm.oceanModel(i).name;

    xlim = hm.oceanModel(i).xLim;
    ylim = hm.oceanModel(i).yLim;

    % Check whether this ocean model dataset needs to be downloaded
    useThisOceanModel=0;
    for j=1:hm.nrModels
        if strcmpi(hm.models(j).flowNestType,'oceanmodel')
            if strcmpi(oceanname,hm.models(j).oceanModel)
                useThisOceanModel=1;
                % Find start and stop time for meteo data
                t0=min(hm.models(j).tFlowStart,t0);
                t0=min(hm.models(j).tWaveStart,t0);
                t1=max(t1,hm.models(j).tStop);
            end
        end
    end

    if useThisOceanModel

        display(oceanname);

        outdir=[hm.oceanmodelsfolder oceanname filesep];
        
        try
            
            switch lower(hm.oceanModel(i).type)
                case{'hycom'}
                    url=hm.oceanModel(i).URL;
                    outname=hm.oceanModel(i).name;
                    s=load([hm.dataDir 'oceanmodels' filesep 'hycom_sp.mat']);
                    s=s.s;
                    makedir(hm.scenarioDir,'oceanmodels',oceanname);
                    t0=floor(t0);
                    t1=ceil(t1);
                    
%                    daynum=nc_varget(url,'MT');
                    
                    getHYCOM2(url,outname,outdir,'waterlevel',xlim,ylim,0.1,0.1,[t0 t1],s);
                    getHYCOM2(url,outname,outdir,'current_u',xlim,ylim,0.1,0.1,[t0 t1],s);
                    getHYCOM2(url,outname,outdir,'current_v',xlim,ylim,0.1,0.1,[t0 t1],s);
                    getHYCOM2(url,outname,outdir,'salinity',xlim,ylim,0.1,0.1,[t0 t1],s);
                    getHYCOM2(url,outname,outdir,'temperature',xlim,ylim,0.1,0.1,[t0 t1],s);
            end
            
        catch
            disp(['An error occured while downloading data for ocean model ' hm.oceanModel(i).name]);
        end
        
    end
end
