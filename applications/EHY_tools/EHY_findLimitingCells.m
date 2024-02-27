function EHY_findLimitingCells(mapFile,varargin)
%% EHY_findLimitingCells(mapFile,OPT)
%
% Analyse limiting cells from a Delft3D-FM map output file
% Note that the simulation has to be performed on 1 partition only

% Example1: EHY_findLimitingCells
% Example2: EHY_findLimitingCells('D:\model_map.nc')
% Example3: EHY_findLimitingCells('D:\model_002_map.nc') % partitioned run
% Example4: EHY_findLimitingCells('D:\model_002_map.nc','writeMaxVel',0)
% Example5: EHY_findLimitingCells('D:\model_002_map.nc','writeMaxVel',0,'timeseriesDT',1)

% created by Julien Groenenboom, February 2018

%% Settings
% OPT settings
OPT.writeMaxVel  = 1; % write max velocities to a .xyz file
OPT.outputDir    = 'EHY_findLimitingCells_OUTPUT'; % output directory
OPT.percentile   = 90; % Percentile of flow velocities shown in max. velocities
OPT.timeseriesDT = 0; % create figure with dt varying over time

% check user input
if ~exist('mapFile','var') && nargin==0
    [filename, pathname] = uigetfile('*_map.nc','Open the model output file');
    if isnumeric(filename); disp('EHY_findLimitingCells stopped by user.'); return; end
    
    mapFile = [pathname filename];
    
    % OPT.writeMaxVel
    [writeMaxVel,~] = listdlg('PromptString','Want to write the maximum velocities to a .xyz file?',...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[300 40]);
    if isempty(writeMaxVel)
        disp('EHY_findLimitingCells stopped by user.'); return;
    elseif writeMaxVel==2
        OPT.writeMaxVel = 0;
    end
    
    % OPT.timeseriesDT
    [timeseriesDT,~] = listdlg('PromptString','Want to write the time-varying timestep to a figure?',...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[300 40]);
    if isempty(timeseriesDT)
        disp('EHY_findLimitingCells stopped by user.'); return;
    elseif timeseriesDT==1
        OPT.timeseriesDT = 1;
    end
end

mapFile = strtrim(mapFile);

% another file than *_map.nc was provided, try to find it
if ~strcmp(mapFile(end-6:end),'_map.nc')
    outputDir = EHY_getOutputDirFM(mapFile);
    mapFiles = dir([outputDir filesep '*map.nc']);
    if ~isempty(mapFiles)
        mapFile = [outputDir filesep mapFiles(1).name];
    else
        mapFile = '';
    end
end

%% process
runOutputDir = EHY_path([fileparts(mapFile) filesep]);
outputDir = [fileparts(runOutputDir(1:end-1)) filesep OPT.outputDir filesep];
if ~exist(outputDir,'dir'); mkdir(outputDir); end

% maximum velocities
if OPT.writeMaxVel
    if ~exist(mapFile,'file')
        disp('Could not write max. velocities as no *_map.nc file was provided/found.')
        OPT.writeMaxVel = 0;
    elseif exist(mapFile,'file') && ~nc_isvar(mapFile,EHY_nameOnFile(mapFile,'uv'))
        disp('Velocities were not written to mapFile. (Change in .mdu: wrimap_velocity_vector = 1)')
        OPT.writeMaxVel = 0;
    else
        try % needs MATLAB statistics toolbox
            Data = EHY_getMapModelData(mapFile,'varName','uv','mergePartitions',1);
            if ndims(Data.vel_x)==2
                mag=sqrt(Data.vel_x.^2+Data.vel_y.^2);
            else
                mag=max(sqrt(Data.vel_x.^2+Data.vel_y.^2),[],3); % maximum over depth
            end
            MAXVEL=prctile(mag,OPT.percentile)'; % might crash at this line (so 'Data' and 'mag' are already loaded)
        catch % skips first 2 days to omit spinup velocities
            logi = Data.times > Data.times(1)+2;
            MAXVEL = max(mag(logi,:),[],1)';
        end
    end
end

% limiting cells
numlimdtFiles = dir([runOutputDir '*_numlimdt.xyz']);
if ~isempty(numlimdtFiles)
    XYZ = [];
    for iF = 1:length(numlimdtFiles)
        fileInfo = dir([runOutputDir numlimdtFiles(iF).name]);
        if fileInfo.bytes>0
            XYZ = [XYZ; dlmread([runOutputDir numlimdtFiles(iF).name])];
        end
    end
    Xlim = XYZ(:,1);Ylim = XYZ(:,2);NUMLIMDT = XYZ(:,3);
elseif exist(mapFile)
    disp('Reading numlimdt from *_map.nc ...')
    disp('To avoid this, set ''Wrimap_numlimdt = 1'' in the mdu-file')
    disp('and/or wait untill the simulation has finished.')
    time0 = EHY_getmodeldata_getDatenumsFromOutputfile(mapFile);
    time = time0(end);
    try
        Data = EHY_getMapModelData(mapFile,'varName','numlimdt','t0',time,'tend',time,'mergePartitions',1);
    catch % if run is not finished yet, mapFile may contain different one timestep less. Use one time step before.
        time = time0(end-1);
        Data = EHY_getMapModelData(mapFile,'varName','numlimdt','t0',time,'tend',time,'mergePartitions',1);
    end
    NUMLIMDT = Data.val';
    limInd = find(NUMLIMDT>0);
    NUMLIMDT = NUMLIMDT(limInd);
end

if OPT.writeMaxVel || ~exist('Xlim','var')
    gridInfo = EHY_getGridInfo(mapFile,{'XYcen','no_layers'},'mergePartitions',1);
    Xcen = gridInfo.Xcen;
    Ycen = gridInfo.Ycen;
    if ~exist('Xlim','var')
        Xlim = Xcen(limInd);
        Ylim = Ycen(limInd);
    end
end

% sort descending
[~,I] = sort(NUMLIMDT);
I = flipud(I);
Xlim = Xlim(I);
Ylim = Ylim(I);
NUMLIMDT = NUMLIMDT(I);

% export
disp(['You can find the created files in the directory:' char(10) outputDir])
    
try
    if ~exist('mdu','var')
        mdFile = EHY_getMdFile(mapFile);
        mdu = dflowfm_io_mdu('read',mdFile);
    end
end

if ~isempty(Xlim)
    outputFile = [outputDir 'restricting_nodes.pol'];
    tekal('write',outputFile,[Xlim Ylim]);
    copyfile(outputFile,strrep(outputFile,'.pol','.ldb'))
    delft3d_io_xyn('write',strrep(outputFile,'.pol','_obs.xyn'),Xlim,Ylim,cellstr(num2str(NUMLIMDT)))
    top10ind = 1:min([length(Xlim) 10]);
    delft3d_io_xyn('write',strrep(outputFile,'.pol','_top10_obs.xyn'),Xlim(top10ind),Ylim(top10ind),cellstr(num2str(NUMLIMDT(top10ind))))
    dlmwrite(strrep(outputFile,'.pol','.xyz'),[Xlim Ylim NUMLIMDT],'delimiter',' ','precision','%20.7f')
    try % copy network to outputDir
        fullWinPathNetwork = EHY_getFullWinPath(mdu.geometry.NetFile,fileparts(mdFile));
        copyfile(fullWinPathNetwork,outputDir)
    end
else
    disp('No limiting cells found')
end

if OPT.writeMaxVel
    outputFile = [outputDir 'maximumVelocities.xyz'];
    disp('start writing maximum velocities')
    dlmwrite([tempdir 'maxvel.xyz'],[Xcen Ycen MAXVEL],'delimiter',' ','precision','%20.7f')
    copyfile([tempdir 'maxvel.xyz'],outputFile);
    disp('finished writing maximum velocities')
end
fclose all;

%% timeseries of time step
if OPT.timeseriesDT
    disp('start reading timestep-info from *his.nc file');
    hisFile = dir([runOutputDir '*_his.nc']);
    hisFile = [runOutputDir hisFile(1).name];
    Data = EHY_getmodeldata(hisFile,'','dfm','varName','timestep');
    disp('finished reading timestep-info from *his.nc file');
    
    try % if mdFile was found
        maxdt = num2str(mdu.time.DtMax);
    catch
        maxdt = '???';
    end
    
    try
        disp('start reading end part of out.txt')
        runTimeInfo = EHY_runTimeInfo(mapFile);
        meandt = runTimeInfo.aveTimeStep_S;
        disp('finished reading end part of out.txt')
        figTitle = ['Mean dt (from out.txt): ' num2str(meandt) ' s - Max dt : ' maxdt ' s'];
    catch
        disp('Could not get average timestep from out.txt, will now take mean(dt) from his-file')
        meandt = mean(Data.val);
        figTitle = ['Mean dt (from *his.nc): ' num2str(meandt) ' s - Max dt : ' maxdt ' s'];
    end
    
    figure('visible','off');
    hold on; grid on;
    plot(Data.times,Data.val,'b');
    plot([Data.times(1) Data.times(end)],[meandt meandt],'k--');
    xlim([Data.times(1) Data.times(end)]);
    ylim([0 max(Data.val)+0.1*std(Data.val) ]);
    xtick = [get(gca,'xtick')];
    set(gca,'xtick',[xtick(1:2:end)])
    datetick('x','dd-mmm-''yy','keeplimits','keepticks');
    legend({'timestep','mean(timestep)'});
    ylabel('time-varying time step');
    title(figTitle)
    saveas(gcf,[outputDir 'timestep.png']);
    disp(['created figure: ' outputDir 'timestep.png'])
end

end