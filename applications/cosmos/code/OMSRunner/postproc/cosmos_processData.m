function hm=cosmos_processData(hm,m)

model=hm.models(m);

mdl=model.name;

% Create archive folders
archivedir=[hm.archiveDir model.continent filesep model.name filesep 'archive' filesep];

hm.models(m).cycledirinput=[archivedir 'input' filesep hm.cycStr filesep];
hm.models(m).cyclediroutput=[archivedir 'output' filesep hm.cycStr filesep];
hm.models(m).cycledirfigures=[archivedir 'figures' filesep hm.cycStr filesep];
hm.models(m).cycledirmaps=[archivedir 'maps' filesep hm.cycStr filesep];
hm.models(m).cycledirtimeseries=[archivedir 'timeseries' filesep hm.cycStr filesep];
hm.models(m).cycledirsp2=[archivedir 'sp2' filesep hm.cycStr filesep];
hm.models(m).cycledirhazards=[archivedir 'hazards' filesep hm.cycStr filesep];
hm.models(m).cycledirnetcdf=[archivedir 'netcdf' filesep hm.cycStr filesep];
hm.models(m).appendeddirmaps=[archivedir 'maps' filesep 'appended' filesep];
hm.models(m).appendeddirtimeseries=[archivedir 'timeseries' filesep 'appended' filesep];

makedir(archivedir);
makedir(hm.models(m).cycledirinput);
makedir(hm.models(m).cyclediroutput);
makedir(hm.models(m).cycledirfigures);
makedir(hm.models(m).cycledirmaps);
makedir(hm.models(m).cycledirtimeseries);
makedir(hm.models(m).cycledirsp2);
makedir(hm.models(m).cycledirhazards);
makedir(hm.models(m).cycledirnetcdf);
makedir(hm.models(m).appendeddirmaps);
makedir(hm.models(m).appendeddirtimeseries);

% Remove older input, output and figure folders
if ~model.archiveinput
    deleteoldercycles(archivedir,'input',hm.cycle);
end
if ~model.archiveoutput
    deleteoldercycles(archivedir,'output',hm.cycle);
end
if ~model.archivefigures
    deleteoldercycles(archivedir,'figures',hm.cycle);
end

% Old stuff
if exist([model.dir filesep 'lastrun'],'dir')
    movefile([model.dir filesep 'lastrun' filesep 'input' filesep '*'],hm.models(m).cycledirinput);
    movefile([model.dir filesep 'lastrun' filesep 'output' filesep '*'],hm.models(m).cyclediroutput);
    movefile([model.dir filesep 'lastrun' filesep 'figures' filesep '*'],hm.models(m).cycledirfigures);
    rmdir([model.dir filesep 'lastrun']);
end

%% Extract data
if model.extractData
    try
        disp('Extracting Data ...');
        tic
        set(hm.textModelLoopStatus,'String',['Status : extracting data - ' mdl ' ...']);drawnow;
        switch lower(model.type)
            case{'delft3dflow','delft3dflowwave'}
                cosmos_extractDataDelft3D(hm,m);
            case{'xbeach'}
                cosmos_extractDataXBeach(hm,m);
            case{'ww3'}
                cosmos_extractDataWW3(hm,m);
            case{'xbeachcluster'}
                cosmos_extractDataXBeachCluster(hm,m);
        end
        cosmos_convertTimeSeriesMat2NC(hm,m);
        cosmos_copyNCTimeSeriesToOPeNDAP(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with extracting data from ' model.name]);
        %     hm.models(m).status='failed';
        %     return;
    end
    hm.models(m).extractDuration=toc;
end

% if model.archiveInput
%     try
%         disp('Archiving input ...');
%         makedir(cycledir,'input');
%         fname=[hm.archiveDir model.continent filesep model.name filesep 'archive' filesep hm.cycStr filesep 'input' filesep model.name '.zip'];
%         zip(fname,[model.dir 'lastrun' filesep 'input' filesep '*']);
%     catch
%         WriteErrorLogFile(hm,['Something went wrong with archiving input from ' model.name]);
%     end
% end

%% Determine hazards
if model.DetermineHazards
    try
        disp('Determining hazards ...');
        tic
        set(hm.textModelLoopStatus,'String',['Status : determining hazards - ' mdl ' ...']);drawnow;
        switch lower(model.type)
            case{'delft3dflow','delft3dflowwave'}
                %                 makedir(cycledir,'hazards');
                %                 cosmos_determineHazardsDelft3D(hm,m);
            case{'xbeach'}
                %                 makedir(cycledir,'hazards');
                %                 determineHazardsXBeach(hm,m);
            case{'ww3'}
                %                 makedir(cycledir,'hazards');
                %                 determineHazardsWW3(hm,m);
            case{'xbeachcluster'}
                cosmos_determineHazardsXBeachCluster(hm,m);
        end
    catch
        WriteErrorLogFile(hm,['Something went wrong with determining hazards from ' model.name]);
        %     hm.models(m).status='failed';
        %     return;
    end
    hm.models(m).hazardDuration=toc;
end

%% Make figures
if model.runPost
    disp('Making figures ...');
    try
        tic
        set(hm.textModelLoopStatus,'String',['Status : making figures - ' mdl ' ...']);drawnow;
        cosmos_makeModelFigures(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with making figures for ' model.name]);
        %         hm.models(m).status='failed';
        %         return;
    end
    hm.models(m).plotDuration=toc;
end

%% Determine hazards (again?)
if model.DetermineHazards
    try
        disp('Determining hazards ...');
        tic
        set(hm.textModelLoopStatus,'String',['Status : determining hazards - ' mdl ' ...']);drawnow;
        cosmos_determineHazards(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with determining hazards from ' model.name]);
    end
    hm.models(m).hazardDuration=toc;
end

%% Copy figures to local website
if model.makeWebsite
    disp('Copying figures to local website ...');
    try
        set(hm.textModelLoopStatus,'String',['Status : copying to local website - ' mdl ' ...']);drawnow;
        cosmos_copyFiguresToLocalWebsite(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong while copying figures to local website of ' model.name]);
        %         hm.models(m).status='failed';
        %         return;
    end
    %%
    disp('Updating xml files on local website ...');
    try
        cosmos_updateModelsXML(hm,m);
        cosmos_updateScenarioXML(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong while updating models.xml on local website for ' hm.models(m).name]);
        %         hm.models(m).status='failed';
        %         return;
    end
end

%% Copy figures and xml files to web server
if model.uploadFTP
    disp('Uploading figures to web server ...');
    try
        tic
        set(hm.textModelLoopStatus,'String',['Status : uploading to SCP server - ' mdl ' ...']);drawnow;
        %        PostFTP(hm,m);
        cosmos_postFigures(hm,m);
        if hm.models(m).forecastplot.plot
            cosmos_postFiguresForecast(hm,m);
        end
    catch
        WriteErrorLogFile(hm,['Something went wrong while upload to SCP server for ' model.name]);
        %         hm.models(m).status='failed';
        %         return;
    end
    hm.models(m).uploadDuration=toc;
    %%
    if ~strcmpi(hm.models(m).status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
        disp('Uploading xml files to web server ...');
        try
            cosmos_postXML(hm,m);
        catch
            WriteErrorLogFile(hm,['Something went wrong while uploading models.xml to website for ' hm.models(m).name]);
            %         hm.models(m).status='failed';
            %         return;
        end
    end
end


%%
function deleteoldercycles(archivedir,fldrname,cycl)
flist=dir([archivedir fldrname]);
for ii=1:length(flist)
    dr=[archivedir fldrname filesep flist(ii).name];
    try
        if isdir(dr)
            switch flist(ii).name
                case{'.','..'}
                otherwise
                    dt=datenum(flist(ii).name(1:end-1),'yyyymmdd_HH');
                    if dt<cycl-0.01
                        rmdir(dr,'s');
                    end
            end
        end
    end
end
