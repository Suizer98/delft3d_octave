function ddb_ModelMakerToolbox_XBeach_quickMode(varargin)
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
ddb_zoomOff;

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
        case{'drawgridoutline'}
            drawGridOutline;
        case{'editgridoutline'}
            editGridOutline;
        case{'editresolution'}
            editResolution;
        case{'generategrid'}
            generatemodel;
        case('updategui')
            updateGUI;
        case('drawline')
            drawPolyline;
        case('fastboundaries')
            fastBoundaries;
    end
    
end

function fastBoundaries

%% First get coordinate to
% Location
handles=getHandles;
x0 = handles.toolbox.modelmaker.xOri;
y0 = handles.toolbox.modelmaker.yOri;

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

%% Draw first setup
[X,Y] = getline2

%% Plotting lines
hg1 = plot(X,Y, 'color', 'g', 'linewidth', 1.5)
hg2 = plot(X,Y, 'o', 'color', 'k', 'linewidth', 1.5)

%% Delete handles
% delete(hg1)
% delete(hg2)

%% Save
handles.toolbox.modelmaker.xb_trans.X=X;
handles.toolbox.modelmaker.xb_trans.Y=Y;


%%
function updatePolyline
%% Click in order to make point active (red color)
% Click again to give new location

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','Use mouse to draw grid outline on map', 'Make sure the origin is offshore and the coastline is at the right'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number', 1);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});

handles=getHandles;

handles.toolbox.modelmaker.gridOutlineHandle=h;

handles.toolbox.modelmaker.xOri=x0;
handles.toolbox.modelmaker.yOri=y0;
handles.toolbox.modelmaker.rotation=rotation;
handles.toolbox.modelmaker.nX=round(dx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(dy/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.lengthX=dx;
handles.toolbox.modelmaker.lengthY=dy;
handles.toolbox.modelmaker.waveangle = round(270-handles.toolbox.modelmaker.rotation);
if handles.toolbox.modelmaker.waveangle > 360
    handles.toolbox.modelmaker.waveangle = handles.toolbox.modelmaker.waveangle - 360;
end
if handles.toolbox.modelmaker.waveangle < 0
    handles.toolbox.modelmaker.waveangle = handles.toolbox.modelmaker.waveangle + 360;
end
handles.model.xbeach.domain.thetamin = round(handles.toolbox.modelmaker.waveangle - 90);
handles.model.xbeach.domain.thetamax = round(handles.toolbox.modelmaker.waveangle + 90);
setHandles(handles);
gui_updateActiveTab;

%%
function deleteGridOutline
handles=getHandles;
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

%%
function editGridOutline

handles=getHandles;

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

handles.toolbox.modelmaker.lengthX=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
handles.toolbox.modelmaker.lengthY=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;

lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',lenx,'dy',leny,'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number',1);
handles.toolbox.modelmaker.gridOutlineHandle=h;
handles.toolbox.modelmaker.waveangle = round(270-handles.toolbox.modelmaker.rotation);
if handles.toolbox.modelmaker.waveangle > 360
    handles.toolbox.modelmaker.waveangle = handles.toolbox.modelmaker.waveangle - 360;
end
if handles.toolbox.modelmaker.waveangle < 0
    handles.toolbox.modelmaker.waveangle = handles.toolbox.modelmaker.waveangle + 360;
end
handles.model.xbeach.domain.thetamin = round(handles.toolbox.modelmaker.waveangle - 90);
handles.model.xbeach.domain.thetamax = round(handles.toolbox.modelmaker.waveangle + 90);

setHandles(handles);

%%
function editResolution

handles=getHandles;

lenx=handles.toolbox.modelmaker.lengthX;
leny=handles.toolbox.modelmaker.lengthY;

dx=handles.toolbox.modelmaker.dX;
dy=handles.toolbox.modelmaker.dY;

nx=round(lenx/max(dx,1e-9));
ny=round(leny/max(dy,1e-9));

handles.toolbox.modelmaker.nX=nx;
handles.toolbox.modelmaker.nY=ny;

handles.toolbox.modelmaker.lengthX=nx*dx;
handles.toolbox.modelmaker.lengthY=ny*dy;

lenx=handles.toolbox.modelmaker.lengthX;
leny=handles.toolbox.modelmaker.lengthY;

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY, 'number',1);
handles.toolbox.modelmaker.gridOutlineHandle=h;
handles.toolbox.modelmaker.waveangle = round(270-handles.toolbox.modelmaker.rotation);
if handles.toolbox.modelmaker.waveangle > 360
    handles.toolbox.modelmaker.waveangle = handles.toolbox.modelmaker.waveangle - 360;
end
if handles.toolbox.modelmaker.waveangle < 0
    handles.toolbox.modelmaker.waveangle = handles.toolbox.modelmaker.waveangle + 360;
end
handles.model.xbeach.domain.thetamin = round(handles.toolbox.modelmaker.waveangle - 90);
handles.model.xbeach.domain.thetamax = round(handles.toolbox.modelmaker.waveangle + 90);
setHandles(handles);

%%
function updateGUI
ddb_updateDataInScreen;
gui_updateActiveTab;
ddb_refreshDomainMenu;


function generatemodel
handles=getHandles;

%% Check: no geographic coordinate systems
coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.screenParameters.coordinateSystem.name;
dataCoord.type=handles.screenParameters.coordinateSystem.type;
if ~strcmpi(lower(dataCoord.type), 'geographic')
    
    %% Make XBeach
    wb =   waitbox('XBeach model is being created');
    handles=ddb_ModelMakerToolbox_XBeach_generateModel(handles, []);
    
    % Plotting
    handles=ddb_initializeXBeach(handles,1,'xbeach1');% Check
    pathname = pwd; filename='\params.txt';
    handles.model.xbeach.domain(handles.activeDomain).params_file=[pathname filename];
    handles=ddb_readParams(handles,[pathname filename],1);
    handles=ddb_readAttributeXBeachFiles(handles,[pathname,'\'],1); % need to add all files
    close(wb);
    ddb_plotXBeach('plot','domain',ad); % make
    setHandles(handles);
    
    ddb_updateDataInScreen;
    gui_updateActiveTab;
    ddb_refreshDomainMenu;
    
    % Overview
    ddb_ModelMakerToolbox_XBeach_modelsetup(handles)
else
    ddb_giveWarning('text',['XBeach models are ALWAYS in cartesian coordinate systems. Change your coordinate system to make a XBeach model']);
end
