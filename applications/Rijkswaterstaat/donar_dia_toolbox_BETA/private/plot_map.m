%PLOT_MAP Plot a North Sea Map
%   PLOT_MAP(CoorType)
%   Arguments:
%   <CoorType> The type of plot to be ploted and can take the follow
%   values:
%           'par'    Paris coordenates
%           'lonlat' Longitude and Latitude coordenates
%           'utm'    Universal 
%   NOTE : If <CoorType> is not given then CoorType = 'par'
%   See also: plot_log10, plot_value, plot_value

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 05.06.2009
%      Author: S. Gaytan Aguilar

%--------------------------------------------------------------------------
function plot_map(varargin)


if nargin ==0
    coordin = 'par';
elseif nargin>1
    coordin = varargin{1};
    extraSpec = {varargin{2:end}};
else
    coordin = varargin{1};
end



set(gcf,'Color','w');
objaxes = gca;

% Load data for map
load('shoreline_euro.mat')

% Selecting type of coordinates 
if strcmp(coordin,'par')
    x = shoreline.xpar;
    y = shoreline.ypar;
    axesLimit = [-0.36 0.430 0.165 1.01]*1.0e+006;
    tmap  = 'tickmap(''xy'')';
elseif strcmp(coordin,'lonlat')
    x = shoreline.lon;
    y = shoreline.lat;
    axesLimit = [-1.9576 9.9379 49.1936 57.2572];
    tmap  = 'tickmap(''ll'')';
elseif strcmp(coordin,'utm')
    x = shoreline.xutm;
    y = shoreline.yutm;
    axesLimit = [1.4 9.2 54.6 63.9]*1.0e+005; 
    tmap  = 'tickmap(''xy'')';
end
clear shoreline

% Axis limits
ibound = x>axesLimit(2) | x<axesLimit(1) | y>axesLimit(4) | y<axesLimit(3);
x(ibound) = nan;
y(ibound) = nan;

% Plot shoreline
if nargin>1
    plot(x, y, 'Parent',objaxes,extraSpec{:});
else
    plot(x, y, 'Parent',objaxes,'color','k');
end
axis square
axis(axesLimit)
set(gca,'xticklabel',{})
set(gca,'yticklabel',{})
eval(tmap)

