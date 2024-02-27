function ddb_ModelMakerToolbox_Delft3DFLOW_quickMode(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_quickMode(varargin)
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
%   Copyright (C) 2011 Deltares
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_ModelMakerToolbox_quickMode.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box'});
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
            generateGrid;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'generateopenboundaries'}
            generateOpenBoundaries;
        case{'generateboundaryconditions'}
            generateBoundaryConditions;
        case{'generateinitialconditions'}
            generateInitialConditions;
        case{'automatetimestep'}
            automateTimestep;
        case{'changetimes'}
            changeTimes;
        case{'generateflowwavemodel'}
            generateFlowWaveModel;
    end
    
end

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','','Use mouse to draw grid outline on map'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number',1);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box'});

handles=getHandles;

handles.toolbox.modelmaker.gridOutlineHandle=h;

handles.toolbox.modelmaker.xOri=x0;
handles.toolbox.modelmaker.yOri=y0;
handles.toolbox.modelmaker.rotation=rotation;
handles.toolbox.modelmaker.nX=round(dx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(dy/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.lengthX=dx;
handles.toolbox.modelmaker.lengthY=dy;

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
function automateTimestep
% Start
handles=getHandles;

% Get X,Y,Z in projection
dataCoord=handles.screenParameters.coordinateSystem;
ad = handles.activeDomain;

x = handles.model.delft3dflow.domain(ad).gridX;
y = handles.model.delft3dflow.domain(ad).gridY;
z = handles.model.delft3dflow.domain(ad).depth;

if isempty(x)
    return
end

if strcmpi(dataCoord.type,'geographic')
    
    % Determine UTM zone of the middle
    [ans1,ans2, utmzone_total, utmzone_parts] = ddb_deg2utm(nanmean(nanmean(y)),nanmean(nanmean(x)));
    
    % Change coordinate system to UTM of the middle
    coord.name = 'WGS 84 / UTM zone ';
    s           = {coord.name, '',num2str(utmzone_parts.number), utmzone_parts.lat};
    coord.name  = [s{:}];
    coord.type = 'Cartesian';
    [x,y]             = ddb_coordConvert(x,y,dataCoord,coord);
end

% Timestep is projected orientation
timestep = ddb_determinetimestepDelft3DFLOW(x,y,z);
handles.model.delft3dflow.domain(ad).timeStep = timestep;

% Make history and map files deelbaar door timestep
% Maybe not such a great idea. We want to have control over our output
% times.
handles = ddb_fixtimestepDelft3DFLOW(handles, ad);
setHandles(handles);

handles = getHandles;
%     ddb_updateOutputTimesDelft3DFLOW
%     handles.model.delft3dflow.domain(ad).mapStopTime = handles.model.delft3dflow.domain(ad).stopTime;
%     handles.model.delft3dflow.domain(ad).hisStopTime = handles.model.delft3dflow.domain(ad).stopTime;
%     handles.model.delft3dflow.domain(ad).comStopTime = handles.model.delft3dflow.domain(ad).stopTime;

% Finish
setHandles(handles);
gui_updateActiveTab;

%%
function changeTimes
% Check time step
handles = getHandles;
ddb_fixtimestepDelft3DFLOW(handles, ad);

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

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY,'number',1)
    
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

%%
function generateGrid

handles=getHandles;
npmax=20000000;
if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY<=npmax
    handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateGrid(handles,ad);
    setHandles(handles);
else
    ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
end

%%
function generateBathymetry
handles=getHandles;
% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
ad = handles.activeDomain;
handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBathymetry(handles,ad,datasets);
setHandles(handles);

%%
function generateOpenBoundaries
handles=getHandles;

% First edit type of boundary etc.
h.type=handles.toolbox.modelmaker.delft3d.boundary_type;
h.forcing=handles.toolbox.modelmaker.delft3d.boundary_forcing;
h.minimum_depth=handles.toolbox.modelmaker.delft3d.boundary_minimum_depth;
h.auto_section_length=handles.toolbox.modelmaker.delft3d.boundary_auto_section_length;
xmldir=handles.model.delft3dflow.xmlDir;
xmlfile='model.delft3dflow.modelmaker.boundaryoptions.xml';
[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',1);
if ok
    handles.toolbox.modelmaker.delft3d.boundary_type=h.type;
    handles.toolbox.modelmaker.delft3d.boundary_forcing=h.forcing;
    handles.toolbox.modelmaker.delft3d.boundary_minimum_depth=h.minimum_depth;
    handles.toolbox.modelmaker.delft3d.boundary_auto_section_length=h.auto_section_length;
else
    return
end

[filename, pathname, filterindex] = uiputfile('*.bnd', 'Boundary File Name',[handles.model.delft3dflow.domain(ad).attName '.bnd']);
if pathname~=0    
    handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBoundaryLocations(handles,ad,filename);
    setHandles(handles);
end

%%
function generateBoundaryConditions
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.bca', 'Boundary Conditions File Name',[handles.model.delft3dflow.domain(ad).attName '.bca']);
if pathname~=0    
    handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBoundaryConditions(handles,ad,filename);
    setHandles(handles);
end

%%
function generateInitialConditions
handles=getHandles;
f=str2func(['ddb_generateInitialConditions' handles.model.delft3dflow.name]);
try
    handles=feval(f,handles,ad,'ddb_test','ddb_test');
catch
    ddb_giveWarning('text',['Initial conditions generation not supported for ' handles.model.delft3dflow.longName]);
    return
end
if ~isempty(handles.model.delft3dflow.domain(ad).grdFile)
    attName=handles.model.delft3dflow.domain(ad).attName;
    handles.model.delft3dflow.domain(ad).iniFile=[attName '.ini'];
    handles.model.delft3dflow.domain(ad).initialConditions='ini';
    handles.model.delft3dflow.domain(ad).smoothingTime=0.0;
    handles=feval(f,handles,ad,handles.model.delft3dflow.domain(ad).iniFile);
else
    ddb_giveWarning('Warning','First generate or load a grid');
end
setHandles(handles);


%% Make matching wave grid
function generateFlowWaveModel

% Start
handles=getHandles;

% Get popup
h.waveinterval = 60;
h.windspeed = 5;
h.winddirection = 180;
h.coarseratio = 2;

xmldir=handles.model.delft3dflow.xmlDir;
xmlfile='model.delft3dflow.modelmaker.flowwave.xml';
[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',1);

if ok == 1
    
    % First save mdf
    handles.model.delft3dflow.domain(1).waves = 1;
    handles.model.delft3dflow.domain(1).onlineWave = 1;
    handles.model.delft3dflow.domain(1).comStartTime = handles.model.delft3dflow.domain(1).mapStartTime;
    handles.model.delft3dflow.domain(1).comStopTime = handles.model.delft3dflow.domain(1).mapStopTime;
    handles.model.delft3dflow.domain(1).comInterval = h.waveinterval;
    setHandles(handles);
    ddb_saveDelft3DFLOW('saveall')

    % Name
    handles=getHandles;
    namemodel=handles.model.delft3dflow.domain(ad).attName;
    ratioFLOWWAVE = h.coarseratio;
    
    %% If true than normal model maker from scratch
    if ~(handles.toolbox.modelmaker.xOri == 0 & handles.toolbox.modelmaker.yOri == 0)
    dx_old=handles.toolbox.modelmaker.dX; handles.toolbox.modelmaker.dX = handles.toolbox.modelmaker.dX *ratioFLOWWAVE;
    dy_old=handles.toolbox.modelmaker.dY; handles.toolbox.modelmaker.dY = handles.toolbox.modelmaker.dY *ratioFLOWWAVE;
    nx_old=handles.toolbox.modelmaker.nX; handles.toolbox.modelmaker.nX = handles.toolbox.modelmaker.nX / ratioFLOWWAVE;
    ny_old=handles.toolbox.modelmaker.nY;  handles.toolbox.modelmaker.nY = handles.toolbox.modelmaker.nY / ratioFLOWWAVE;

    % Create a wave grid
    filename = ([namemodel '_swn.grd']);
    handles.model.delft3dwave.domain.gridnames = filename;
    handles.model.delft3dwave.domain(1).gridname = filename;
    handles = ddb_ModelMakerToolbox_Delft3DWAVE_generateGrid(handles,'option','new', 'filename', filename);

    % Generate bathymetry
    datasets(1).name=handles.screenParameters.backgroundBathymetry;
    filename = ([namemodel '_swn.dep']); handles.model.delft3dwave.domain.domains(awg).bedlevel = filename;
    handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateBathymetry(handles,datasets,'filename', filename);
    
    %% Otherwise use previous grid
    else 
    wb = waitbox('Generating grid based on FLOW model');        
    % FLOW grid
    xgrid = handles.model.delft3dflow.domain(ad).gridX;
    ygrid = handles.model.delft3dflow.domain(ad).gridY;
    zgrid = handles.model.delft3dflow.domain(ad).depth;
    [nx ny] = size(xgrid);

    % WAVE grid
    xgrid_wave = xgrid((1:ratioFLOWWAVE:end),(1:ratioFLOWWAVE:end));
    ygrid_wave = ygrid((1:ratioFLOWWAVE:end),(1:ratioFLOWWAVE:end));
    zgrid_wave = zgrid((1:ratioFLOWWAVE:end),(1:ratioFLOWWAVE:end));

    % Make it slighly larger


    % 1. Grid
    filename = ([namemodel '_swn.grd']);
    handles.model.delft3dwave.domain.nrgrids=handles.model.delft3dwave.domain.nrgrids+1;
    nrgrids= 1
    domains = ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,nrgrids);
    handles.model.delft3dwave.domain.domains = domains;
    handles.model.delft3dwave.domain.domains(nrgrids).gridnames=filename(1:end-4);
    handles.activeWaveGrid=nrgrids;
    enc=ddb_enclosure('extract',xgrid_wave,ygrid_wave);
    attName=filename(1:end-4);
    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        coord='Spherical';
    else
        coord='Cartesian';
    end
    ddb_wlgrid('write','FileName',[attName '.grd'],'X',xgrid_wave,'Y',ygrid_wave,'Enclosure',enc,'CoordinateSystem',coord);
    handles.model.delft3dwave.domain.domains(nrgrids).coordsyst = coord;
    handles.model.delft3dwave.domain.domains(nrgrids).grid      = [filename '.grd'];
    handles.model.delft3dwave.domain.domains(nrgrids).grdFile   = [filename '.grd'];
    handles.model.delft3dwave.domain.domains(nrgrids).encFile   = [filename '.enc'];
    handles.model.delft3dwave.domain.domains(nrgrids).gridname  = filename;
    handles.model.delft3dwave.domain.domains(nrgrids).gridx     = xgrid_wave;
    handles.model.delft3dwave.domain.domains(nrgrids).gridy     = ygrid_wave;
    nans=zeros(size(xgrid_wave));
    nans(nans==0)=NaN;
    handles.model.delft3dwave.domain.domains(nrgrids).depth=nans;
    handles.model.delft3dwave.domain.domains(nrgrids).mmax=size(xgrid_wave,1);
    handles.model.delft3dwave.domain.domains(nrgrids).nmax=size(xgrid_wave,2);
    handles.model.delft3dwave.domain.domains(nrgrids).grid      = [filename '.grd'];

    % 2. Bathy
    id = 1;
    filename = ([namemodel '_swn.dep']);
    handles.model.delft3dwave.domain.domains(id).depth=zgrid_wave;
    handles.model.delft3dwave.domain.domains(id).bedlevel=filename;
    handles.model.delft3dwave.domain.domains(id).depthsource='file';
    ddb_wldep('write',filename,handles.model.delft3dwave.domain.domains(id).depth);
    handles.model.delft3dwave.domain.domains(id).bedlevel=filename;
    handles.model.delft3dwave.domain.domains(id).depthsource='file';

    % Put info back
    setHandles(handles);
    end

    % Finalize
    runid = handles.model.delft3dflow.domain(1).runid;
    handles.model.delft3dwave.domain.referencedate = handles.model.delft3dflow.domain(1).itDate; % same reference time
    handles.model.delft3dwave.domain.projectname = 'Drawboxes';
    handles.model.delft3dwave.domain.description = 'Made with Delft Dashboard';
    handles.model.delft3dwave.domain.windspeed = h.windspeed;
    handles.model.delft3dwave.domain.winddir = h.winddirection;
    handles.model.delft3dwave.domain.mdffile = [runid, '.mdf'];
    handles.model.delft3dwave.domain.mdwfile = [runid, '.mdw']; 
    handles.model.delft3dwave.domain.writecom = 1;
    handles.model.delft3dwave.domain.comwriteinterval = handles.model.delft3dflow.domain(1).comInterval;
    setHandles(handles);

    % Save
    ddb_saveMDW(handles);
    ddb_saveDelft3DFLOW('saveall');
    try
    close(wb);
    catch
    end
else
    return
end