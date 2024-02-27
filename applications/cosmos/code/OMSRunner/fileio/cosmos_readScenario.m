function hm=cosmos_readScenario(hm,opt)

fname=[hm.scenarioDir filesep hm.scenario '.xml'];

xml=xml2struct(fname);

if strcmpi(opt,'first')
    
    hm.runEnv='h4';
    if isfield(xml,'runenv')
        hm.runEnv=xml.runenv;
    end
    
    hm.numCores=1;
    
    hm.archiveinput=0;
    hm.archiveoutput=0;
    hm.archivefigures=0;
    if isfield(xml,'archiveinput')
        txt=xml.archiveinput;
        if strcmpi(txt(1),'t')
            hm.archiveinput=1;
        end
    end
    if isfield(xml,'archiveoutput')
        txt=xml.archiveoutput;
        if strcmpi(txt(1),'t')
            hm.archiveoutput=1;
        end
    end
    if isfield(xml,'archivefigures')
        txt=xml.archivefigures;
        if strcmpi(txt(1),'t')
            hm.archivefigures=1;
        end
    end
    
    nh=24*(now-floor(now));
    if nh>12
        hm.cycle=floor(now)+0.5;
    else
        hm.cycle=floor(now);
    end
    
    hm.stoptime=hm.cycle+1000;
    
    hm.scenarioLongName=xml.longname;
    hm.scenarioShortName=xml.shortname;
    
    hm.scenarioType='hindcast';
    if isfield(xml,'type')
        hm.scenarioType=xml.type;
    end
    
    if isfield(xml,'cycle')
        hm.cycle=datenum(xml.cycle,'yyyymmdd HHMMSS');
    end
    
    if isfield(xml,'stoptime')
        hm.stoptime=datenum(xml.stoptime,'yyyymmdd HHMMSS');
    end
    
    hm.runInterval=str2double(xml.runinterval);
    hm.runTime=str2double(xml.runtime);
    hm.cycleMode=xml.cyclemode;
    

    txt=xml.getmeteodata;
    if strcmpi(txt(1),'t')
        hm.getMeteo=1;
    else
        hm.getMeteo=0;
    end
    
    txt=xml.getobsdata;
    if strcmpi(txt(1),'t')
        hm.getObservations=1;
    else
        hm.getObservations=0;
    end
    
    hm.getOceanModel=0;
    if isfield(xml,'getoceandata')
        txt=xml.getoceandata;
        if strcmpi(txt(1),'t')
            hm.getOceanModel=1;
        end
    end

end

switch hm.scenarioType
    case{'globalcycloneforecast'}
        % All models need to be used
        
    otherwise
        
        nmdl=length(xml.model);

        for im=1:nmdl
            
            modelnames{im}=xml.model(im).model.name;
            hm.models(im).name=xml.model(im).model.name;
            hm.models(im).webSite=[];
            
            %% Archiving
            
            hm.models(im).archiveinput=hm.archiveinput;
            hm.models(im).archiveoutput=hm.archiveoutput;
            hm.models(im).archivefigures=hm.archivefigures;
            
            if isfield(xml.model(im).model,'archiveinput')
                switch xml.model(im).model.archiveinput(1)
                    case{'y','t','1'}
                        hm.models(im).archiveinput=1;
                    otherwise
                        hm.models(im).archiveinput=0;
                end
            end
            if isfield(xml.model(im).model,'archiveoutput')
                switch xml.model(im).model.archiveoutput(1)
                    case{'y','t','1'}
                        hm.models(im).archiveoutput=1;
                    otherwise
                        hm.models(im).archiveoutput=0;
                end
            end
            if isfield(xml.model(im).model,'archivefigures')
                switch xml.model(im).model.archivefigures(1)
                    case{'y','t','1'}
                        hm.models(im).archivefigures=1;
                    otherwise
                        hm.models(im).archivefigures=0;
                end
            end
            
            %% Meteo
            
            hm.models(im).meteowind=[];
            hm.models(im).backupmeteowind=[];
            hm.models(im).meteopressure=[];
            hm.models(im).backupmeteopressure=[];
            hm.models(im).meteoheat=[];
            hm.models(im).backupmeteoheat=[];
            hm.models(im).meteospw=[];
            
            if isfield(xml.model(im).model,'meteowind')
                hm.models(im).meteowind=xml.model(im).model.meteowind;
            end
            if isfield(xml.model(im).model,'meteopressure')
                hm.models(im).meteopressure=xml.model(im).model.meteopressure;
            end
            if isfield(xml.model(im).model,'meteoheat')
                hm.models(im).meteoheat=xml.model(im).model.meteoheat;
            end
            if isfield(xml.model(im).model,'meteospw')
                hm.models(im).meteospw=xml.model(im).model.meteospw;
            end
            if isfield(xml.model(im).model,'backupmeteowind')
                hm.models(im).backupmeteowind=xml.model(im).model.backupmeteowind;
            end
            if isfield(xml.model(im).model,'backupmeteopressure')
                hm.models(im).backupmeteopressure=xml.model(im).model.backupmeteopressure;
            end
            if isfield(xml.model(im).model,'backupmeteoheat')
                hm.models(im).backupmeteoheat=xml.model(im).model.backupmeteoheat;
            end
            
            %% Ocean model
            hm.models(im).oceanModel=[];
            if isfield(xml.model(im).model,'oceanmodel')
                hm.models(im).oceanModel=xml.model(im).model.oceanmodel;
            end
            
        end
        
end


%% Websites
if isfield(xml,'website')
    for iw=1:length(xml.website)

        % General website info
        hm.website(iw).name=xml.website(iw).website.name;
        hm.website(iw).longitude=str2double(xml.website(iw).website.longitude);
        hm.website(iw).latitude=str2double(xml.website(iw).website.latitude);
        hm.website(iw).elevation=str2double(xml.website(iw).website.elevation);

        % Now set data for models in this website
        for imdl=1:length(xml.website(iw).website.model)
            xmodel=xml.website(iw).website.model(imdl).model;
            model=xmodel.name;
            im=strmatch(model,modelnames,'exact');
            nw=length(hm.models(im).webSite)+1;
            hm.models(im).webSite(nw).name=hm.website(iw).name;
            hm.models(im).webSite(nw).location=[];
            hm.models(im).webSite(nw).elevation=[];
            hm.models(im).webSite(nw).overlayFile=[];
            hm.models(im).webSite(nw).positionToDisplay=[];

            if isfield(xmodel,'locationx') && isfield(xmodel,'locationy')
                hm.models(im).webSite(nw).location(1)=str2double(xmodel.locationx);
                hm.models(im).webSite(nw).location(2)=str2double(xmodel.locationy);
            end
            if isfield(xmodel,'elevation')
                hm.models(im).webSite(nw).elevation=str2double(xmodel.elevation);
            end
            if isfield(xmodel,'overlay')
                hm.models(im).webSite(nw).overlayFile=xmodel.overlay;
            end
            if isfield(xmodel,'positiontodisplay')
                hm.models(im).webSite(nw).positionToDisplay=str2double(xmodel.positiontodisplay);
            else
                hm.models(im).webSite(nw).positionToDisplay=-1;
            end
                        
        end    
    end
end
