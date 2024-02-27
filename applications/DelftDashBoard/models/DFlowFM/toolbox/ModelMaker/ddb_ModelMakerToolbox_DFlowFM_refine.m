function ddb_ModelMakerToolbox_DFlowFM_refine(varargin)
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

% $Id: ddb_ModelMakerToolbox_quickMode_DFlowFM.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode_DFlowFM.m $
% $Keywords: $

%%
ddb_zoomOff;

if isempty(varargin)
    
    % New tab selected
    ddb_refreshScreen;
    
else
    
    % Options selected
    opt=lower(varargin{1});
    switch opt
        case{'refine'}
            refine;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'clipmeshpolygon'}
            clipMeshPolygon;
        case{'clipmeshelevationabove'}
            clipMeshElevationAbove;
        case{'clipmeshelevationbelow'}
            clipMeshElevationbelow;
    end
end

%%

function refine
        
handles=getHandles;
        
filename_ori=handles.model.dflowfm.domain(ad).netfile;

[filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
if ~ok
    return
end
handles.model.dflowfm.domain(ad).netfile=filename;


%% Create XYZ file

% if handles.bathymetry.dataset(handles.toolbox.modelmaker.activeDataset).isAvailable

% Find minimum grid resolution (in metres)
%dmin=min(dx,dy);
wb = waitbox('Your Delft3D-FM model is being refined');
dmin=0.02;
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    dmin = dmin*111111;
end

%% Extent of data to be downloaded
xl(1)=min(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x);
xl(2)=max(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x);
yl(1)=min(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y);
yl(2)=max(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y);
dx=xl(2)-xl(1);
dy=yl(2)-yl(1);
xl(1)=xl(1)-0.05*dx;
xl(2)=xl(2)+0.05*dx;
yl(1)=yl(1)-0.05*dy;
yl(2)=yl(2)+0.05*dy;

coord   = handles.screenParameters.coordinateSystem;
iac     = strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name = handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type = handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
[xlb,ylb]= ddb_coordConvert(xl,yl,coord,dataCoord);
[xx,yy,zz,ok]= ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);

[xx,yy]=ddb_coordConvert(xx,yy,dataCoord,handles.screenParameters.coordinateSystem);

np=size(xx,1)*size(xx,2);

xx=reshape(xx,[np,1]);
yy=reshape(yy,[np,1]);
zz=reshape(zz,[np,1]);

data(:,1)=xx;
data(:,2)=yy;
data(:,3)=zz;

save('TMP.xyz','data','-ascii');


nrref=handles.toolbox.modelmaker.dflowfm.nr_refinement_steps;
hmin=0.001;
dtmax=handles.toolbox.modelmaker.dflowfm.dtmax;
directional=0;
outsidecell=0;
connect=1;
maxlevel=1;

drypointsfile='testing123.pol';
drypointsfile='';

% % First write the net file in the old format ... Sigh...
% filename_ori='_TMP_net.nc';
% %netstruc2netcdf_v2(filename_ori,handles.model.dflowfm.domain(ad).netstruc,'cs',handles.screenParameters.coordinateSystem,'format','old');
% 
% netstruc_tmp=handles.model.dflowfm.domain(ad).netstruc;
% 
% netstruc_tmp.edge.NetLink=netstruc_tmp.edge.mesh2d_edge_nodes;
% 
%     netstruc_tmp.node.x=netstruc_tmp.node.mesh2d_node_x;
%     netstruc_tmp.node.y=netstruc_tmp.node.mesh2d_node_y;
%     netstruc_tmp.node.z=netstruc_tmp.node.mesh2d_node_z;
% 
%     if isfield(netstruc_tmp,'face')
%         netstruc_tmp.face.NetElemNode=netstruc_tmp.face.mesh2d_face_nodes';
%     end
% 
% netStruc2nc(filename_ori,netstruc_tmp,'cs',handles.screenParameters.coordinateSystem);

refine_netfile(filename_ori,filename,'TMP.xyz',nrref,hmin,dtmax,directional,outsidecell,connect,maxlevel,drypointsfile, handles.model.dflowfm.exedir);

handles.model.dflowfm.domain(ad).netfile=filename;

netstruc=ddb_DFlowFM_read_netstruc(filename);

handles.model.dflowfm.domain(ad).netstruc=netstruc;

close(wb);

%handles.model.dflowfm.domain(ad).netstruc=loadnetstruc2(filename);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',ad);
handles=ddb_DFlowFM_plotBathymetry(handles,'plot','domain',ad);

setHandles(handles);

%%
function drawPolygon

handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','clippolygon');
if ~isempty(h)
    delete(h);
end

handles.toolbox.modelmaker.polygonX=[];
handles.toolbox.modelmaker.polygonY=[];
handles.toolbox.modelmaker.polyLength=0;

handles.toolbox.modelmaker.polygonhandle=gui_polyline('draw','tag','clippolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.polygonhandle=h;
handles.toolbox.modelmaker.polygonX=x;
handles.toolbox.modelmaker.polygonY=y;
handles.toolbox.modelmaker.polyLength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon
handles=getHandles;
handles.toolbox.modelmaker.polygonX=[];
handles.toolbox.modelmaker.polygonY=[];
handles.toolbox.modelmaker.polyLength=0;
h=findobj(gcf,'Tag','clippolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
handles.toolbox.modelmaker.polygonX=x;
handles.toolbox.modelmaker.polygonY=y;
handles.toolbox.modelmaker.polyLength=length(x);
setHandles(handles);

%%
function loadPolygon
handles=getHandles;
[x,y]=landboundary('read',handles.toolbox.modelmaker.polygonFile);
handles.toolbox.modelmaker.polygonX=x;
handles.toolbox.modelmaker.polygonY=y;
handles.toolbox.modelmaker.polyLength=length(x);
h=findobj(gca,'Tag','bathymetrypolygon');
delete(h);
h=gui_polyline('plot','x',x,'y',y,'tag','clippolygon','marker','o', ...
        'changecallback',@changePolygon);
handles.toolbox.modelmaker.polygonhandle=h;
setHandles(handles);

%%
function savePolygon
handles=getHandles;
x=handles.toolbox.modelmaker.polygonX;
y=handles.toolbox.modelmaker.polygonY;
if size(x,1)==1
    x=x';
end
if size(y,1)==1
    y=y';
end

landboundary('write',handles.toolbox.modelmaker.polygonFile,x,y);
setHandles(handles);

%%
function clipMeshPolygon

handles=getHandles;

[filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
if ~ok
    return
end

if isnan(nanmax(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z))
    ddb_giveWarning('text','Could not clip polygon! Please generate bathymetry first.');
    return
end

handles.model.dflowfm.domain(ad).netfile=filename;

x=handles.toolbox.modelmaker.polygonX;
y=handles.toolbox.modelmaker.polygonY;

handles.model.dflowfm.domain(ad).netstruc=dflowfm_clip_mesh_in_polygon(handles.model.dflowfm.domain(ad).netstruc,x,y);

cs.name=handles.screenParameters.coordinateSystem.name;
switch lower(handles.screenParameters.coordinateSystem.type(1:3))
    case{'pro','car'}
        cs.type='projected';
    otherwise
        cs.type='geographic';
end

netstruc2netcdf(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cs',cs);

%netStruc2nc(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cstype',handles.screenParameters.coordinateSystem.type,'csname', handles.screenParameters.coordinateSystem.name);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',ad);

setHandles(handles);

%%
function clipMeshElevationAbove

handles=getHandles;

[filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
if ~ok
    return
end

if isnan(nanmax(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z))
    ddb_giveWarning('text','Could not clip maximum elevation! Please generate bathymetry first.');
    return
end

handles.model.dflowfm.domain(ad).netfile=filename;

zmax=handles.toolbox.modelmaker.clipzmax;

xp=handles.toolbox.modelmaker.polygonX;
yp=handles.toolbox.modelmaker.polygonY;
handles.model.dflowfm.domain(ad).netstruc=dflowfm_clip_shallow_areas(handles.model.dflowfm.domain(ad).netstruc,zmax,'max',xp,yp);

% netStruc2nc(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cstype',handles.screenParameters.coordinateSystem.type,'csname', handles.screenParameters.coordinateSystem.name);

cs.name=handles.screenParameters.coordinateSystem.name;
switch lower(handles.screenParameters.coordinateSystem.type(1:3))
    case{'pro','car'}
        cs.type='projected';
    otherwise
        cs.type='geographic';
end

netstruc2netcdf(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cs',cs);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',ad);

setHandles(handles);


%%
function clipMeshElevationbelow

handles=getHandles;

[filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
if ~ok
    return
end

if isnan(nanmax(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_z))
    ddb_giveWarning('text','Could not clip minimum elevation! Please generate bathymetry first.');
    return
end

handles.model.dflowfm.domain(ad).netfile=filename;

zmin=handles.toolbox.modelmaker.clipzmin;

xp=handles.toolbox.modelmaker.polygonX;
yp=handles.toolbox.modelmaker.polygonY;
handles.model.dflowfm.domain(ad).netstruc=dflowfm_clip_shallow_areas(handles.model.dflowfm.domain(ad).netstruc,zmin, 'min', xp, yp);

netstruc2netcdf(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cs',handles.screenParameters.coordinateSystem);
%netStruc2nc(handles.model.dflowfm.domain(ad).netfile,handles.model.dflowfm.domain(ad).netstruc,'cstype',handles.screenParameters.coordinateSystem.type,'csname', handles.screenParameters.coordinateSystem.name);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',ad);

%clipMeshElevationbelowNewboundarypoints(handles); % call new basic function to change the boundary location points and reload the boundary conditions

setHandles(handles);

%%
function clipMeshElevationbelowNewboundarypoints(handles)
% transfers current boundary points to nearest node point
% first simply in a loop (might be time-consuming for large grids / lot of boundary points)

% handles=getHandles;

boundaries = handles.model.dflowfm.domain.boundaries;
ipol=length(boundaries);

xmodel = handles.model.dflowfm.domain.netstruc.node.mesh2d_node_x; %active model
ymodel = handles.model.dflowfm.domain.netstruc.node.mesh2d_node_y;

xnew = [];
ynew = [];
distance = [];

for ii = 1:ipol
    xtmp = boundaries(ii).x; 
    ytmp = boundaries(ii).y;
    
    for jj = 1:length(xtmp) 
        for kk = 1:length(xmodel) %loop through model nodes to get distances
           distance(kk) = sqrt( (xtmp(jj) - xmodel(kk))^2 + (ytmp(jj) - ymodel(kk))^2);
        end
        [min_distance, id] = nanmin(distance); %determine closest point and take over coordinates
        xnew(ii,jj) = xmodel(id); %temp to check
        ynew(ii,jj) = ymodel(id);
        
        handles.model.dflowfm.domain.boundaries(ii).x(jj) = xmodel(id);
        handles.model.dflowfm.domain.boundaries(ii).y(jj) = ymodel(id);
        
    end
end

% Plot new locations
handles = ddb_DFlowFM_plotBoundaries(handles,'plot','Visible','on','active',1);

% Save new boundary points
boundaries = handles.model.dflowfm.domain.boundaries;
ipol=length(boundaries);
ddb_DFlowFM_saveBoundaryPolygons('.\',boundaries,ipol); 

% Give warning
ddb_giveWarning('text','Note; the open boundary locations are changed to their respective closest boundary point')

ddb_giveWarning('text','Note; the boundary conditions are being re-calculated. Use option with care!');

% Redo the generateBoundaryConditions sequence

ddb_ModelMakerToolbox_DFlowFM_quickMode('generateboundaryconditions')

setHandles(handles);

