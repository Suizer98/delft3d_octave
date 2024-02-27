function varargout = EHY_closureCorrection(fileObs,fileMdu,fileCorr,varargin)
%% varargout =  EHY_closureCorrection(fileObs,fileMdu,fileCorr,varargin)
%  Computes closure correction for enclosed water bodies (Veerse Meer, Grevelingen, Volkerak Zoommmeer etc.)
%  First attampt which will hopefully result in a generic approach. 
%  Feel free to modify/improve/extent
% 
%  Input:
%  fileObs: mat file with observed water levels,
%  fileMdu: name of the mdu file of the model (used to get the time-frame,
%           network, external forcing file etc.
%  output:
%  fileCorr: name of the file with time series of the closure correction (*.tim)
% 
%  limitations:
%  1) Wet area determined from the water level in combination with hysometric
%     curve derived from network and depths. This might slightly differ from
%     actual wet area which in longer simulations might result in small
%     differences in computed and measured water level. 
%  2) Only takes into account discharge points defined in ext file.
%     not yet: rain and evaporation over the whole model domain,
%              discharges defined as open boundary.
%
%  Additional input as <keyword,value> pairs
%  timeSkip - time periods to skip measurements because they are considered
%             unreliable
%  dt_bc    - interval to write the closure correction (default 10 minutes)
%  days_ave - time period for the moving average operation used in the
%             closure correction (default 7 days)
% oetsettings('quiet');

%% Time intervals
OPT.timeSkip    = []  ; % Time interval for skipping of measurements (filled in by linear interpolation)
OPT.dt_bc       = 10.0; % Interval in minutes 
OPT.days_ave    = 7;    % number of days for the moving average
OPT.salinity    = [];
OPT.temperature = [];

OPT = setproperty(OPT,varargin);

%% Load waterlevels
obs = load(fileObs);
%  Proces waterlevel (fill values in intervals timeSkip with NaN 
stations = {obs.A.name};
for istat = 1:length(stations)
    for i_int = 1: size(OPT.timeSkip,1)
        index = find(obs.A(istat).time >= OPT.timeSkip(i_int,1) &  obs.A(istat).time <= OPT.timeSkip(i_int,2));
        obs.A(istat).wl(index) = NaN;
    end
end

%% Read mdu
mdu                = dflowfm_io_mdu('read',fileMdu);
% make all fields available in lower case for easier handling of e.g. mdu.geometry.bedlevuni
fns1 = fieldnames(mdu);
for i = 1:length(fns1)
    fn1 = fns1{i};
    fns2 = fieldnames(mdu.(fn1));
    for j = 1:length(fns2)
        fn2 = fns2{j};
        mdu.(lower(fn1)).(lower(fn2)) = mdu.(fn1).(fn2);
    end
end

%% Time info from MDU
[ref_date,Tunit,TStart,TStop] = EHY_getTimeInfoFromMdFile(fileMdu,'dfm');
TStart                        = ref_date + TStart*timeFactor(Tunit,'D');
TStop                         = ref_date + TStop*timeFactor(Tunit,'D');
t_bc_ml                       = TStart:OPT.dt_bc/1440.:TStop;

if t_bc_ml(end)~=TStop
    t_bc_ml(end+1) = TStop;
end

%% Geometry data
gridInfo = EHY_getGridInfo(EHY_getFullWinPath(mdu.geometry.netfile,fileparts(fileMdu)),{'XYcor' 'Z' 'spherical'});
%  Replace missing depth points with default value
index = find(gridInfo.Zcor == -999);
gridInfo.Zcor(index) = mdu.geometry.bedlevuni; 

%% Hypsometric curve
[area, volume, interface] = EHY_dethyps(gridInfo.Xcor,gridInfo.Ycor,gridInfo.Zcor,'spherical',gridInfo.spherical,'noLevels',1000);

%%  From mdu > ext > pli > discharge_series 
ext_file = mdu.external_forcing.extforcefile;
ext_file = EHY_getFullWinPath(ext_file,fileparts(fileMdu));
ext = dflowfm_io_extfile('read',ext_file);
extInd = [strmatch('discharge_',{ext.quantity}); strmatch('lateraldischarge',{ext.quantity})];
pli_files = {ext.filename};
pli_files = pli_files(extInd);
pli_files = EHY_getFullWinPath(pli_files,fileparts(ext_file));

%  time series from discharge tim files (interpolate to t_bc)
for i_file = 1:length(pli_files)
    pli_file = pli_files{1,i_file};
    [pathstr, name, ex] = fileparts(pli_file);
    if strncmp(ex,'.pli',4) % .pli- or .pliz-file
        tim_file{i_file} = [pathstr filesep name '.tim'];
    elseif strcmp(ex,'.pol') % .pol (lateraldischarge)
        tim_file{i_file} = [pathstr filesep name '.tim'];
        if ~exist(tim_file{i_file},'file') % .pol is still/used to be linked to *_0001.tim
            tim_file{i_file} = [pathstr filesep name '_0001.tim'];
        end
    end
    pli_names{1,i_file} = name;
end

%% read tim files (when the file name/directory does not contail "correc' 
nr_file = 0;
for i_file = 1: length(pli_files)
    if ~contains(lower(pli_files{i_file}),'correc')
        nr_file = nr_file + 1;
        raw = importdata(tim_file{i_file});
        data = raw.data;
        data     (:,1     ) = data(:,1)/1440.0 + ref_date; % time from min. from ref_date to MATLAB-times
        data_intp(:,nr_file) = interp1( data(:,1) , data(:,2) , t_bc_ml);
    end
end

%% Discharges associated with water level variations
for istat = 1: length(stations) 
   wl_intp(:,istat) = interp1(obs.A(istat).time, obs.A(istat).wl, t_bc_ml);
end

%  average over all stations, fill NaN values by linear interpolation
DVpeil      = nanmean(wl_intp,2);
nonan       = ~isnan(DVpeil);
DVpeil      = interp1(t_bc_ml(nonan), DVpeil(nonan), t_bc_ml); % lineaire interp om kleine gaten te vullen
area_now    = interp1(interface,area  ,DVpeil);
volume_now  = interp1(interface,volume,DVpeil);
for i_time = 1: length(t_bc_ml) - 1 
    Qpeil(i_time)  = 0.5*(area_now  (i_time + 1) + area_now  (i_time))*(DVpeil(i_time+1) - DVpeil(i_time))/(OPT.dt_bc*60.);
end
Qpeil (end + 1) = 0.;

%% Closure correction (use the moving average over days_ave)
closeCorr = movmean(Qpeil - sum(data_intp,2)',OPT.days_ave*(1440./OPT.dt_bc)); 

%% Write closure correction tim file
t_bc            = (t_bc_ml - ref_date ) * 1440.0 ;
tim.Comments{1} = '* COLUMN=2';
tim.Comments{2} = ['* COLUMN1=Time (minutes since ' datestr(ref_date,'yyyy-mm-dd') ')'];
tim.Comments{3} =  '* COLUMN2=Discharge (m3/s), positive in';
tim.Values      = num2cell([t_bc(:),closeCorr(:)]);

if ~isempty(OPT.salinity) 
    tim.Comments{1}       = '* COLUMN=3';
    tim.Comments{4}       = '* COLUMN3=Salinity (psu)';
    tim.Values(:,end + 1) = num2cell(OPT.salinity);
    if ~isempty(OPT.temperature)
        tim.Comments{1}       = '* COLUMN=4';
        tim.Comments{5}       = '* COLUMN4=Temperature (oC)';
        tim.Values(:,end + 1) = num2cell(OPT.temperature);
    end
end
if isempty(OPT.salinity) && ~isempty(OPT.temperature)
    tim.Comments{1}       = '* COLUMN=3';
    tim.Comments{4}       = '* COLUMN3=Temperature (oC)';
    tim.Values(:,end + 1) = num2cell(OPT.temperature);
end

dflowfm_io_series('write',fileCorr,tim)

%% varargout
if nargout >= 1
    out(:,1) = reshape(t_bc_ml,[],1); % time in MATLABs datenum
    out(:,2) = reshape(closeCorr,[],1);
    if ~isempty(OPT.salinity)
        out(:,end+1) = OPT.salinity;
    end
    if ~isempty(OPT.temperature)
        out(:,end+1) = OPT.temperature;
    end
    out(:,end + 1) = cumsum(reshape(closeCorr,[],1)*(t_bc_ml(2) - t_bc_ml(1))*1440.*60.);
    varargout{1} = out;
    clear out
end

if nargout >=2
    out(:,1)                     = reshape(t_bc_ml,[],1);
    for i_file = 1: size(data_intp,2) 
        out(:,1+i_file) = data_intp(:,i_file);
    end
    for i_file = 1: size(data_intp,2) 
        out(:,1+size(data_intp,2) + i_file) = cumsum(data_intp(:,i_file)*(t_bc_ml(2) - t_bc_ml(1)) *1440*60.);
    end
    varargout{2} = out;
    clear out
end
    
    

