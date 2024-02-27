function varargout = EHY_plot_ldb(varargin)
%% varargout = EHY_plot_ldb(varargin)
%
% This functions plots a polyline (landboundary, river, border) to your current figure
% You may also be interested in EHY_plot_satellite_map.m
%
% Example1: EHY_plot_ldb
% Example2: hLdb = EHY_plot_ldb;
% Example3: hLdb = EHY_plot_ldb('color','r','type','rivers');
% Example4: hLdb = EHY_plot_ldb('color','r','type',{'shorelines','rivers'},'linewidth',1);
% Example5: hLdb = EHY_plot_ldb('color','r','type',{'shorelines','rivers'},'localEPSG',28992);
%
% Example6 - plot a map showing some capitals in Europe:
%    lat = [48.8708   51.5188   41.9260   40.4312   52.523   37.982];
%    lon = [2.4131    -0.1300    12.4951   -3.6788    13.415   23.715];
%    plot(lon,lat,'.r','MarkerSize',20)
%    EHY_plot_ldb
%
% This function is largely based on QuickPlot-functionality and uses the
% Self-consistent, Hierarchical, High-resolution Geography Database (GSHHS).
% For more information see one of the following two links:
%   http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
%   http://www.soest.hawaii.edu/pwessel/gshhg/index.html
%
% To delete the polylines, you may use delete(hLdb{:});
%
% Julien.Groenenboom@deltares.nl, January 2020

%% default settings
OPT.type      = {'shorelines','borders'}; % choose from: 'borders','rivers','shorelines' // string or cell array
OPT.color     = 'k';
OPT.linewidth = 0.5;
OPT.localEPSG = []; % specify local EPSG (e.g. 28992)
OPT.localUnit = 'km';
OPT           = setproperty(OPT,varargin);

%% structure to cell array
fns = fieldnames(OPT);
for iFN = 1:length(fns)
    ind = iFN*2-1;
    input{ind} = fns{iFN};
    input{ind+1} = OPT.(fns{iFN});
end

%% plot polyline in current axis
if ischar(OPT.type)
    OPT.type = cellstr(OPT.type);
end

hold on
rootfolder = [fileparts(which('EHY')) filesep 'support_functions' filesep 'GSHHG'];

if ~isempty(OPT.localEPSG)
    x_lim = get(gca,'xlim');
    y_lim = get(gca,'ylim');
    if strcmpi(OPT.localUnit,'km')
        x_lim = x_lim*1000;
        y_lim = y_lim*1000;
    end
    hFig = figure('visible','off'); % dummy figure with [lat,lon]-axis
    [x_lim, y_lim] = convertCoordinates(x_lim, y_lim,'CS1.code',OPT.localEPSG,'CS2.code',4326);
    set(gca,'xlim',x_lim,'ylim',y_lim)
    
    X = [];
    Y = [];
    for iT = 1:length(OPT.type) % loop over types
        h = gshhg('plot','type',OPT.type{iT},'color',OPT.color,'rootfolder',rootfolder);
        child = get(gca,'children');
        if isobject(child) && ~isempty(child)
            for iC = 1:length(child)
            X = [X child(iC).XData NaN];
            Y = [Y child(iC).YData NaN];
            end
        end
        delete(h);
    end
    delete(hFig); % close dummy fig
    [X, Y] = convertCoordinates(X, Y,'CS1.code',4326,'CS2.code',OPT.localEPSG);
    if strcmpi(OPT.localUnit,'km')
        X = X/1000;
        Y = Y/1000;
    end    
    hLdb = plot(X,Y,'color',OPT.color,'linewidth',OPT.linewidth);
else
    for iT = 1:length(OPT.type) % loop over types
        hLdb{iT} = gshhg('plot','type',OPT.type{iT},'color',OPT.color,'rootfolder',rootfolder);
        set(hLdb{iT},'linewidth',OPT.linewidth); % linewidth
    end
end

if nargout > 0
    varargout{1} = hLdb;
end
