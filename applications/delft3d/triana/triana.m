function s = triana(s,meas)
%TRIANA Function to perform a tidal analysis on observations stations in a
%Delft3D or Delft3D-FM model and compare the results with measurements.
%Comparison with the IHO database (from dashboard) is included in this
%function, but also other measurements can be provided (meas).
%
% This function uses t_tide if possible (if a signal toolbox license is
% available), otherwise the tide_analysis.exe from Delft3D will be used.
%
%     Usage (more detailed description of settings is given below):
%
%     TRIANA starts a GUI which will help you to provide the right settings
%     for this function (model output file, tidal analysis settings, plot
%     settings, etc). The tidal analysis will be performed after
%     specification of all required input data, the settings are stored in
%     a structure in teh selected output directory. This structure can be
%     used for subsequent use of this function, see below.
%
%     TRIANA(S) runs the triana function using the settings specified in S
%     (which can you can generate by running the function TRIANA, see
%     above).
%
%     TRIANA(S,MEAS) runs the triana function using the settings specified in S
%     (which can you can generate by running the function TRIANA, see
%     above). The measurements as specified in the array structure MEAS are
%     used to compare the model against. MEAS is an arraw structure with
%     size [Nx1], in which N is the number of locations. The following
%     fields are required for MEAS:
%         name = name of the measurement station [string]
%         X = X-coordinate of measurement (same coordinate system as model) [1x1]
%         Y = Y-coordinate of measurement (same coordinate system as model) [1x1]
%         Cmp = cell array containing the component names (e.g.
%         {'M2','K1','K1'} [1xC]
%         A = array containing the amplitude in meters for each tidal
%         component (e.g. [0.5 0.2 0.1]) [1xC]
%         G = array containing the phase in degrees for each tidal
%         component (e.g. [350 4.5 45.9]) [1xC]
%         OPTIONAL: timeZone = timezone in hours relative to GMT
%
%     TRIANA(MEAS) starts a GUI which will help you to provide the right settings
%     for this function (model output file, tidal analysis settings, plot
%     settings, etc. The measurements as specified in the array structure MEAS are
%     used to compare the model against. See explanation above for a
%     description of MEAS.
%
% ----------------- DETAILED DESCRIPTION OF SETTINGS ----------------------
% The structure S has the following fields (required or <optional>)
%     model: which has the following subfields
%         type: 'delft3d' or 'dflowfm'
%         file: full path to the history output file (*_his.nc, or
%               trih*.dat)
%         <epsg>: coordinate system of model (Default = 4326, WGS84)
%         <timeZone>: time zone of model  relative to GMT (Default = 0)
%     selection: which has the following subfields
%         opt: 1 or 2. Option 1 will let you specify which model stations
%               need to be analysed. The nearest measurement location will be
%               selected if the distance in between is smaller than
%               s.selection.searchRadius. Option 2 will analyse all model
%               stations which are within s.selection.searchRadius of a
%               measurements station
%         searchRadius: distance in m or degrees (if model is in sphrerical
%               WGS84 coordinates). Measurements and model stations are
%               compared to each other if they are within this distance.
%         obs (only required if s.selection.op = 1): cell array with names
%               of model stations
%     ana: tidal analysis settings, which has the following subfields
%         timeStart: start of tidal analysis (datenum)
%         timeEnd: end of tidal analysis (datenum)
%         <fourier>: 0 or 1(default); If 1: fourier analysis is carried out
%               on the residual
%         inputFile (only required if s.ana.constituents is not specified):
%               full path to the analyse.ina.template file (used by
%               tide_analysis.exe).
%         constituents (only required if s.ana.inputFile is not specified:
%               cell array containing the tidal components to be included in the
%               tidal analysis. Note that this option does not cater for tidal
%               couplings (if coupling is required, us the s.ana.inputFile
%               option)
%     plot: plot settings, which has the following subfields
%         const: cell array containing the tidal components for which the
%               triana results need to be plotted
%         ldb: full path to the landboundary file
%         Xmin, Xmax, Ymin, Ymax: axes limits for the plots
%         <txtHorFraq>, <txtVerFraq>: fraction of total X and Y limits
%               used as spacing for plotting the triana results (Deafults:
%               110, 110)
%     meas: measurements settings, which has the following subfields
%         <useIHO>: 0 or 1(Default). Specifies whether the IHO database will
%               be used for the analysis. In case the user also specified
%               the MEAS variable as input, the IHO measurements will be
%               used in addition to these.
%     <description>: name tag which will be added to the filenames of the figures
%               and other output data (Default: 'triana')
%     outputDir: folder where the triana results need to be stored
%
%
% Wilbert Verbruggen, 2016
%

warning off

if nargin == 0
    s = triana_inputGui;
end

if nargin == 1
    if  ~isfield(s,'model')
        if isfield(s,'data') % input variable contains measured components
            meas = s;
            clear s
        end
        s = triana_inputGui;
    end
end

if exist('meas','var')  % store user defined measurement in structure
    s.meas.data = meas;
    if isfield(meas,'timeZone')
        s = triana_convertTimeZoneMeasurements2GMT(s);
    end
end

%% set defaults
disp('Setting defaults (if neccesary)')
s = triana_setDefaults(s);
disp('***')

%% reading locations of model stations
switch s.model.type
    case 'dflowfm'
        s = triana_readDflowfmStations(s);
    case 'delft3d'
        s = triana_readDelft3DStations(s);
end

%% reading IHO station data
if s.meas.useIHO == 1
    tic;
    disp('Reading measurement data')
    s = triana_readIHOdata(s);
    T = toc; disp(['Finished reading measurement data in ',num2str(T),' seconds'])
    disp('***')
end

%% Selecting stations
disp('Selecting stations for analysis')
s = triana_selectStations(s);
disp('***')

if ~isempty(s.modID)
    %% reading model data
    disp('Reading water level data at selected stations')
    tic
    switch s.model.type
        case 'dflowfm'
            s = triana_readDflowfmData(s);
        case 'delft3d'
            s = triana_readDelft3DData(s);
    end
    T = toc; disp(['Finished reading model data in ',num2str(T),' seconds'])
    disp('***')
    
    %% Performing Tidal Analysis on measurement data for each station
    % s = triana_tidalAnalysis(s);
    try
        xcov(1,1); % checking if you have access to the signal toolbox
        disp('T_tide will be used for the tidal analysis')
        s = triana_tidalAnalysis_t_tide(s);
    catch
        disp('T_tide can not be used (no signal toolbox license), therefore Delft-Tide will be used for the tidal analysis')
        s = triana_tidalAnalysis(s);
    end
    
    save([s.outputDir,filesep,filesep,'Triana_',s.description,'.mat'],'s')
    
    %% Prepare Triana plot
    s = triana_plotTriana(s);
else
    disp('Warning: No corresponding model observation points were found for the specified measurements (check s.selection.searchRadius!)')
    
    ldb = landboundary('read',s.plot.ldb);
    figure; hold on; axis equal
    hold on; plot(ldb(:,1),ldb(:,2),'k')
    plot(meas.X,meas.Y,'b.')
    plot(s.model.data.XAll,s.model.data.YAll,'rx')
    
end
