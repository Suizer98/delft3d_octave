function ddb_ModelMakerToolbox_XBeach_quickMode_transects(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_XBeach(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_ModelMakerToolbox_quickMode
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%%
handles=getHandles;
% ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box)', 'Note: make sure origin is offshore and x direction is cross-shore'});
    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'drawline'}
            drawPolyline;
        case('drawmorelines');
            continudrawing;
        case('drawtransectsxy')
            drawTransectsXY;
        case('drawtransectsz')
            drawTransectsZ;
        case{'generategrid'}
            generatemodel;
        case('delete')
            deleteGridOutline
        case('adddem')
            addDEM
        case('fastboundaries')
            fastBoundaries;
    end
    
end

function fastBoundaries

%% First get coordinate to 
% Location
handles=getHandles;

try
    % Use the handle to get location
    h = handles.toolbox.modelmaker.xb_trans.handle1;
    x0= nanmean(getappdata(h,'x'));
    y0= nanmean(getappdata(h,'y'));
catch
    try
        % Use the saved x and y grid
        domains = length( handles.model.xbeach.domain);
        for jj = 1:domains
        x0s(jj) = handles.model.xbeach.domain(jj).grid.x(1,1);
        y0s(jj) = handles.model.xbeach.domain(jj).grid.y(1,1);
        end
        x0 = nanmean(x0s); y0 = nanmean(y0s);
    catch
            % Use the xori and yori (always has a value)
            x0 = handles.toolbox.modelmaker.xOri;
            y0 = handles.toolbox.modelmaker.yOri;
    end
end

% Coordinate system
coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.screenParameters.coordinateSystem.name;
dataCoord.type=handles.screenParameters.coordinateSystem.type;
NewSys.name = 'WGS 84';
NewSys.type = 'geo';
[x1 y1] = ddb_coordConvert(x0, y0, dataCoord, NewSys);

%% Second retrieve values for waves 
fname1 = [handles.toolBoxDir, '\TropicalCyclone\FAST_Hs.mat'];
load (fname1);
distance = ((ReturnValues.location.values(:,1) - x1).^2 + (ReturnValues.location.values(:,2) - y1).^2).^0.5;
id       = find(distance  == min(distance));
Hsvalue  = ReturnValues.Hs.values(id,7);    Tpvalue  = ReturnValues.Tp.values(id,7);

%% Third retrieve values for tide+surge 
fname2 = [handles.toolBoxDir, '\TropicalCyclone\FAST_SSL.mat'];
GTSM = load (fname2);
distance = ((GTSM.lon - x1).^2 + (GTSM.lat - y1).^2).^0.5;
id       = find(distance  == min(distance));
SSL      = GTSM.RP100(id);

%% Save values
handles.toolbox.modelmaker.Hs   = round(Hsvalue(1)*10)/10;		
handles.toolbox.modelmaker.Tp   = round(Tpvalue(1)*10)/10;	
handles.toolbox.modelmaker.SSL  = round(SSL(1)*10)/10;	
setHandles(handles);

gui_updateActiveTab;


%%
function drawPolyline

% Start
handles=getHandles;

% Delete previous
try
% Get previous points
h = handles.toolbox.modelmaker.xb_trans.handle1;
x=getappdata(h,'x');
y=getappdata(h,'y');

% Delete
% Vertices
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle1)
    try
        ch=getappdata(h,'children');
        delete(h); delete(ch); handles.toolbox.modelmaker.xb_trans.handle1 = [];
    end
end
catch
end
catch
end

% Make polyline and save handle
h = UIPolyline(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, 'onstart',@deleteGridOutline, ...
    'Tag', 'XB');
handles.toolbox.modelmaker.xb_trans.handle1=h;

% Close
setHandles(handles);

%% 
function continudrawing

% Start
handles=getHandles;

% Get previous points
h = handles.toolbox.modelmaker.xb_trans.handle1;
x=getappdata(h,'x');
y=getappdata(h,'y');

% Delete vertices
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle1)
    try
        ch=getappdata(h,'children');
        delete(h); delete(ch); handles.toolbox.modelmaker.xb_trans.handle1 = [];
    end
end
catch
end

% Make polyline and save handle
h = UIPolyline(handles.GUIHandles.mapAxis,'continudraw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, 'onstart',@deleteGridOutline, ...
    'Tag', 'XB', 'x', x, 'y', y);

handles.toolbox.modelmaker.xb_trans.handle1=h;

% Close
setHandles(handles);
try
    delete(gtmp1); 
    delete(gtmp2);
catch
end


%%
function updateGridOutline(x,y,h)

% Start
setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box'});
handles=getHandles;


% Settings 
setappdata(h,'x',x);
setappdata(h,'y',y);
handles.toolbox.modelmaker.xb_trans.handle1=h;
handles.toolbox.modelmaker.xb_trans.X=x;
handles.toolbox.modelmaker.xb_trans.Y=y;

% Finish
setHandles(handles);
gui_updateActiveTab;

%%
function deleteGridOutline
handles=getHandles;

% Vertices
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle1)
    try
        h = handles.toolbox.modelmaker.xb_trans.handle1;
        ch=getappdata(h,'children');
        delete(h); delete(ch); handles.toolbox.modelmaker.xb_trans.handle1 = [];
    end
end
catch
end

% Transects
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle2)
    try
        delete(handles.toolbox.modelmaker.xb_trans.handle2);
    end
end
catch
end

% Other windows
for ii =1 :100
    try
    delete(handles.toolbox.modelmaker.hfigure(ii))
    end
end

setHandles(handles);

%%
function addDEM

% Start
handles=getHandles;

% Find DEM
[filename, pathname, filterindex] = uigetfile('*', 'Select the DEM of LISFLOOD');
handles.toolbox.modelmaker.xb_trans.DEM = [pathname, filename];


% Close
setHandles(handles);


%%
function drawTransectsXY

% Start
handles=getHandles;

% Delete
try
    delete(handles.toolbox.modelmaker.xb_trans.handle2);
end

%% Get information
hg = handles.toolbox.modelmaker.xb_trans.handle1;
handles.toolbox.modelmaker.xb_trans.X   = getappdata(hg,'x');
handles.toolbox.modelmaker.xb_trans.Y   = getappdata(hg,'y');

% Draw transects and save in handles based on settings
[handles] = ddb_ModelMakerToolbox_XBeach_quickMode_drawtransects(handles);

% Line sections
xoff    = handles.toolbox.modelmaker.xb_trans.xoff;
yoff    = handles.toolbox.modelmaker.xb_trans.yoff;
xback   = handles.toolbox.modelmaker.xb_trans.xback;
yback   = handles.toolbox.modelmaker.xb_trans.yback;
ntransects = length(xoff);

% Plotting
for ii = 1:ntransects
    h2(ii) = plot3([xoff(ii) xback(ii)], [yoff(ii), yback(ii)], [9000 9000], 'k', 'linewidth', 2);
end
handles.toolbox.modelmaker.xb_trans.handle2 = h2;

% Close
setHandles(handles);

function drawTransectsZ

% Start
handles=getHandles;

% Determine average depth
dataCoord.type=handles.screenParameters.coordinateSystem.type;
if ~strcmpi(lower(dataCoord.type), 'geographic')
    xoff        = handles.toolbox.modelmaker.xb_trans.xoff;
    ntransects  = length(xoff);

    error = 0;
    for ii = 1:ntransects
        try
        [handles] = ddb_ModelMakerToolbox_XBeach_quickMode_Ztransects(handles, ii, 1)
        catch
        error = 1;    
        end
    end

    % Error
    if error == 1;
            ddb_giveWarning('text',['Something went wrong with drawing the transects. Make sure the bathy has information in this area']);
    end
    handles.toolbox.modelmaker.average_z = round(nanmean(handles.toolbox.modelmaker.Zvalues));
else
	ddb_giveWarning('text',['XBeach models are ALWAYS in cartesian coordinate systems. Change your coordinate system to make a XBeach model']);
end

% Close
setHandles(handles);


%%
function generatemodel

% Start
handles=getHandles;
dataCoord.type=handles.screenParameters.coordinateSystem.type;
if ~strcmpi(lower(dataCoord.type), 'geographic')
    
    % Draw transects and save in handles based on settings
    try
    if ~isempty(handles.toolbox.modelmaker.xb_trans.handle2)
        try
            delete(handles.toolbox.modelmaker.xb_trans.handle2);
        end
    end
    catch
    end
    [handles] = ddb_ModelMakerToolbox_XBeach_quickMode_drawtransects(handles);

    % Line sections
    xoff    = handles.toolbox.modelmaker.xb_trans.xoff;
    yoff    = handles.toolbox.modelmaker.xb_trans.yoff;
    xback   = handles.toolbox.modelmaker.xb_trans.xback;
    yback   = handles.toolbox.modelmaker.xb_trans.yback;
    ntransects = length(xoff);

    % Plotting
    for ii = 1:ntransects
        h2(ii) = plot([xoff(ii) xback(ii)], [yoff(ii), yback(ii)], 'k', 'linewidth', 2);
    end
    handles.toolbox.modelmaker.xb_trans.handle2 = h2;

    % Generating models
    wb = waitbox('Generating XBeach transect models');
    handles=ddb_ModelMakerToolbox_XBeach_generateTransects(handles);
    close(wb);
    cd ..

    % Close
    settings = handles.toolbox.modelmaker.xb_trans;
    time = linspace(0,6000, 11); 
    for ii = 1:length(settings.xback)
        transects{ii,1}   = ['Transect_00', num2str(ii)];
        x(ii,:)           = settings.xback(ii);
        y(ii,:)           = settings.yback(ii);
        distances(ii,:)   = settings.distances(ii);
        angles(ii,:)      = settings.coast(ii);
        Q(ii,:)           = abs(cosd(fliplr(time)/60).^2);
    end

    [succes] = ddb_ModelMakerToolbox_XBeach_quickMode_transects_netcdf(x,y,distances, angles, time, Q);
    save('settings.mat','settings')
else
	ddb_giveWarning('text',['XBeach models are ALWAYS in cartesian coordinate systems. Change your coordinate system to make a XBeach model']);
end

% Close
setHandles(handles);