function s = triana_inputGui


%% model settings

% model type
s.model.type=questdlg('Delft3D or DFlow model?','Choose model type','delft3d','dflowfm','delft3d');

% Ask for input file trih-*.dat for delft3d and _his.nc for dflowfm
switch s.model.type
    case 'dflowfm'
        [filename, pathname] = uigetfile({'*_his.nc'},['Select history file for dflowfm model'],'');
        if filename==0
            return
        end
        s.model.file=[pathname filename];
    case 'delft3d'
        [filename, pathname] = uigetfile({'*trih-*.dat'},['Select history file for delft3d model'],'','MultiSelect','on');
        
        if iscell(filename)
            for ff = 1:length(filename)
                s.model.file{ff}=[pathname filename{ff}];
            end
        else
            if filename==0
                return
            end
            s.model.file{1}=[pathname filename];
        end
end

% Specify coordinate system of model (all results of triana will be presented in WGS84
s.model.epsgOpt=questdlg('Does model correspond fully to an epsg, or is an additional translation required?','','EPSG','EPSG+translation','EPSG');

s.model.epsg=str2num(char(inputdlg(['Specify EPSG code of the model (used to convert measurements)'],'Enter model EPSG code',1,{'4326'})));
if isempty(s.model.epsg)
    s.model.epsg = 4326; % WGS84 is assumed
end
s.model.epsgTxT = strrep(strrep(strtok(epsg_wkt(s.model.epsg),','),'PROJCS["',''),'"','');

if strcmpi(s.model.epsgOpt,'EPSG+translation')
    s.model.epsgTranslation =str2num(char(inputdlg(['Specify translation additional to EPSG: Xtrans Ytranx'],'specify translation',1,{'0; 0'})));
end


s.model.timeZone=str2num(char(inputdlg(['Specify Timezone of model relative to GMT'],'Enter time zone',1,{'0'})));
if isempty(s.model.timeZone)
    s.model.timeZone = 0; % GMT is assumed
end

%% stations selection settings
s.selection.opt=str2num(char(inputdlg(['Specify station selection technique (1 or 2): option 1: prescribe model stations (nearest IHO station within searchRadius will be selected). option 2: all model stations will be selected that are close (within searchRadius) enough to the IHO stations'],'selection technique',1,{'1'})));
if s.selection.opt ~= 1 & s.selection.opt~= 2
    s.selection.opt =str2num(char(inputdlg(['!Please specify 1 or 2! Specify station selection technique (1 or 2): option 1: prescribe model stations (nearest IHO station within searchRadius will be selected). option 2: all model stations will be selected that are close (within searchRadius) enough to the IHO stations'],'selection technique',1,{'1'})))
end

% set search radius
if s.model.epsg == 4326
    s.selection.searchRadius=str2num(char(inputdlg(['Specify search radius (in decimal degrees). If the distance between the model station and the IHO station is smaller than this radius, the station is included in the analysis'],'Enter search radius',1,{'0.05'})));
else
    s.selection.searchRadius=str2num(char(inputdlg(['Specify search radius (in meters). If the distance between the model station and the IHO station is smaller than this radius, the station is included in the analysis'],'Enter search radius',1,{'0.05'})));
end

switch s.selection.opt
    case 1
        s.selection.obs=strsplit(char(strrep(inputdlg(['Specify model stations to be analysed as follows: station1 ; station2 ; stationBla ; etc'],'selection stations',1,{''}),'; ',';')),';');
end


%% Tidal analysis settings
timeStart=char(inputdlg(['Specify start time of analysis (yyyymmddHHMMSS)'],'selection start time analysis',1,{''}));
try
    s.ana.timeStart = datenum(timeStart,'yyyymmddHHMMSS')
catch
    s.ana.timeStart = datenum(timeStart,'yyyymmdd')
end


timeEnd=char(inputdlg(['Specify end time of analysis (yyyymmddHHMMSS)'],'selection end time analysis',1,{''}));
try
    s.ana.timeEnd = datenum(timeEnd,'yyyymmddHHMMSS')
catch
    s.ana.timeEnd = datenum(timeEnd,'yyyymmdd')
end

s.ana.fourier = 1; % 1: fourier analysis on residual is performed for each station, 0: fourier analysis is not performed on residual

% own template file or specify consituents
s.ana.inputType=questdlg('Do you want to specify the constituents to be included in the analysis, or a template.ina file?','','constituents','template .ina file','constituents');
switch s.ana.inputType
    case 'template .ina file'
        [filename, pathname] = uigetfile({'*.template'},['Select template .ina file (make sure it contains the constituents and couplings you want to include in the analysis)'],'');
        if filename==0
            return
        end
        s.ana.inputFile=[pathname filename];
    case 'constituents'
        s.ana.constituents=strsplit(char(inputdlg(['Specify constituents to be included in the analysis as follows: M2; S2; K1; P1; etc'],'selection constituents',1,{''})),';');
end

%  specifiy constituents to be plotted
plotConst=strsplit(char(inputdlg(['Specify constituents for which the results need to be plotted: M2; S2; K1; P1; etc'],'selection constituents',1,{''})),';');
if ~isempty(plotConst)
    s.plot.const = plotConst;
end

% landboundary
[name,pat]=uigetfile('*.ldb','Load LDB-file (should be in the same coordinate system as the model)');
if name~=0
    s.plot.ldb = [pat filesep name];
end

% specify axes limits for plot
axisLims =str2num(char(inputdlg(['Specify axes limits for plot: Xmin Xmax Ymin Yman (should be in the same coordinate system as the model)'],'selection axes limits',1,{'10; 20; 45; 55'})));
s.plot.Xmin = axisLims(1);
s.plot.Xmax = axisLims(2);
s.plot.Ymin = axisLims(3);
s.plot.Ymax = axisLims(4);

s.plot.txtHorFraq = 110; %fraction of (s.plot.Xmax - s.plot.Xmin) used to horizontally locate the computed and observed amplitude and phase texts
s.plot.txtVerFraq = 110; %fraction of (s.plot.Ymax - s.plot.Ymin) used to vertically locate the computed and observed amplitude and phase texts
 s.plot.FontSize = 3; % fontsize of amplitudes and phases in triana overview plot
 
% filename containing IHO stations
s.meas.file = 'p:\delta\svn.oss.deltares.nl\openearthtools\matlab\applications\DelftDashBoard\toolboxes\TideStations\data\iho.nc';

% output directory
[s.outputDir]=uigetdir(pwd,'specify output directory');

% try to find tide_analysis.exe on this machine

dirFiles = [fileparts(which('triana')),filesep,'toBeCopiedFiles'];
s.ana.exe = [dirFiles,filesep,'tide_analysis.exe'];
% h1 = msgbox('Searching on this machine for an tide_analysis.exe...');
% ExePath = triana_checkTidalAnalysisExe
% if ~strcmpi(ExePath,'')
%     s.ana.exe = ExePath;
%     delete(h1);
%     h2 = msgbox(['tide_analysis.exe found: ',ExePath]);
% end
%     delete(h1);
% [name,pat]=uigetfile('*.exe','Select a tide_analysis.exe (need to have installed Delft3D)');
% if name~=0
%     s.ana.exe = [pat filesep name];
% end

% Other settings
s.description = 'triana';

% save settings
save([s.outputDir,filesep,'triana_input_',s.description,'.mat'],'s');

