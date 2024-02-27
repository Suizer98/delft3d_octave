function handles = ddb_ModelMakerToolbox_DFlowFM_generateGrid(handles, id, varargin)
%DDB_GENERATEGRIDDFlowFM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateGridDFlowFM(handles, id, x, y, varargin)
%
%   Input:
%   handles  =
%   id       =
%   x        =
%   y        =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateGridDFlowFM
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_generateGridDFlowFM.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/toolbox/ModelMaker/ddb_generateGridDFlowFM.m $
% $Keywords: $

%%
if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

handles.model.dflowfm.domain(ad).netfile=[handles.model.dflowfm.domain(ad).attName '_net.nc'];
[filename,ok]=gui_uiputfile('*_net.nc', 'Net File Name',handles.model.dflowfm.domain(ad).netfile);
if ~ok
    return
end
    
% Values
wb      = waitbox('Generating grid ...'); pause(0.1);
xori    = handles.toolbox.modelmaker.xOri;
nx      = handles.toolbox.modelmaker.nX;
dx      = handles.toolbox.modelmaker.dX;
yori    = handles.toolbox.modelmaker.yOri;
ny      = handles.toolbox.modelmaker.nY;
dy      = handles.toolbox.modelmaker.dY;
rot     = pi*handles.toolbox.modelmaker.rotation/180;
zmax    = handles.toolbox.modelmaker.zMax;

% Find minimum grid resolution (in metres)
dmin=min(dx,dy);
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    dmin = dmin*111111;
end

% Find coordinates of corner points
x(1)= xori;
y(1)= yori;
x(2)= x(1)+nx*dx*cos(pi*handles.toolbox.modelmaker.rotation/180);
y(2)= y(1)+nx*dx*sin(pi*handles.toolbox.modelmaker.rotation/180);
x(3)= x(2)+ny*dy*cos(pi*(handles.toolbox.modelmaker.rotation+90)/180);
y(3)= y(2)+ny*dy*sin(pi*(handles.toolbox.modelmaker.rotation+90)/180);
x(4)= x(3)+nx*dx*cos(pi*(handles.toolbox.modelmaker.rotation+180)/180);
y(4)= y(3)+nx*dx*sin(pi*(handles.toolbox.modelmaker.rotation+180)/180);

% Limits for the bathy
xl(1)= min(x);
xl(2)= max(x);
yl(1)= min(y);
yl(2)= max(y);
dbuf = (xl(2)-xl(1))/20;
xl(1)= xl(1)-dbuf;
xl(2)= xl(2)+dbuf;
yl(1)= yl(1)-dbuf;
yl(2)= yl(2)+dbuf;

% Get bathy
coord   = handles.screenParameters.coordinateSystem;
iac     = strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name = handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type = handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
[xlb,ylb]= ddb_coordConvert(xl,yl,coord,dataCoord);
[xx,yy,zz,ok]= ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);

% xx and yy are in coordinate system of bathymetry (usually WGS 84)
% convert bathy grid to active coordinate system
if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
    dmin=min(dx,dy);
    [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
    [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
    zz=interp2(xx,yy,zz,xgb,ygb);
else
    xg=xx;
    yg=yy;
end

% Generate grid
[x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xg,yg,zz);

close(wb);

ddb_plotDFlowFM('delete','domain',id);
handles=ddb_initializeDFlowFMdomain(handles,'griddependentinput',id,handles.model.dflowfm.domain(id).runid);
set(gcf,'Pointer','arrow');

%[netstruc,circ]=curv2net_new(x,y,z);
[netstruc,circ]=curv2net_v3(x,y,z);

% Set depths to NaN
nans=zeros(size(netstruc.node.mesh2d_node_z));
nans(nans==0)=NaN;
netstruc.node.z=nans;

handles.model.dflowfm.domain(id).netfile=filename;
handles.model.dflowfm.domain(id).netstruc=netstruc;

circumference=delft3dfm_find_net_circumference(netstruc);

handles.model.dflowfm.domain.circumference=circumference;

%handles.model.dflowfm.domain.circumference=ddb_findNetCircumference(handles.model.dflowfm.domain(id).netstruc);

% % Clip shallow areas
% netstruc=dflowfm_clip_shallow_areas(netstruc,zmax);

%netstruc.edge.NetLink=netstruc.edge.NetLink';

netstruc2netcdf(handles.model.dflowfm.domain(id).netfile,handles.model.dflowfm.domain(ad).netstruc,'cs',handles.screenParameters.coordinateSystem);

%netStruc2nc(handles.model.dflowfm.domain(id).netfile,netstruc,'cstype',handles.screenParameters.coordinateSystem.type, 'csname', handles.screenParameters.coordinateSystem.name);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',id);


