function ddb_Delft3DFLOW_grid(varargin)
%DDB_DELFT3DFLOW_GRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_grid(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_grid
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

% $Id: ddb_Delft3DFLOW_grid.m 11463 2014-11-27 13:29:28Z ormondt $
% $Date: 2014-11-27 21:29:28 +0800 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11463 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_grid.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dflow.domain.domainpanel.grid');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
        case{'selectzmodel'}
            selectZModel;
        case{'editztop'}
            editZTop;
        case{'editzbot'}
            editZBot;
    end
end

%%
function selectGrid
handles=getHandles;
filename=handles.model.delft3dflow.domain(ad).grdFile;
[x,y,enc]=ddb_wlgrid('read',filename);
handles.model.delft3dflow.domain(ad).gridX=x;
handles.model.delft3dflow.domain(ad).gridY=y;
handles.model.delft3dflow.domain(ad).MMax=size(x,1)+1;
handles.model.delft3dflow.domain(ad).NMax=size(x,2)+1;
[handles.model.delft3dflow.domain(ad).gridXZ,handles.model.delft3dflow.domain(ad).gridYZ]=getXZYZ(x,y);
handles.model.delft3dflow.domain(ad).kcs=determineKCS(handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
nans=zeros(size(handles.model.delft3dflow.domain(ad).gridX));
nans(nans==0)=NaN;
handles.model.delft3dflow.domain(ad).depth=nans;
handles.model.delft3dflow.domain(ad).depthZ=nans;
setHandles(handles);
% setUIElement('delft3dflow.domain.domainpanel.grid.textgridm');
% setUIElement('delft3dflow.domain.domainpanel.grid.textgridn');
handles=getHandles;
handles=ddb_Delft3DFLOW_plotGrid(handles,'plot');
setHandles(handles);

%%
function selectEnclosure
handles=getHandles;
mn=ddb_enclosure('read',handles.model.delft3dflow.domain(ad).encFile);
[handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY]=ddb_enclosure('apply',mn,handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
[handles.model.delft3dflow.domain(ad).gridXZ,handles.model.delft3dflow.domain(ad).gridYZ]=getXZYZ(handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
handles.model.delft3dflow.domain(ad).kcs=determineKCS(handles.model.delft3dflow.domain(ad).gridX,handles.model.delft3dflow.domain(ad).gridY);
handles=ddb_Delft3DFLOW_plotGrid(handles,'plot');
setHandles(handles);

%%
function generateLayers
ddb_Delft3DFLOW_generateLayers;

%%
function changeLayers
handles=getHandles;
handles.model.delft3dflow.domain(ad).sumLayers=sum(handles.model.delft3dflow.domain(ad).thick);
setHandles(handles);
% gui_updateActiveTab;

%%
function loadLayers
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.lyr', 'Load layers file','');
if pathname~=0
    lyrs=load([pathname filename]);
    sm=sum(lyrs);
    if abs(sm-100)<1e-8
        handles.model.delft3dflow.domain(ad).thick=lyrs;
        handles.model.delft3dflow.domain(ad).sumLayers=100;
        handles.model.delft3dflow.domain(ad).KMax=length(lyrs);
        setHandles(handles);
    else
        ddb_giveWarning('Text','Sum of layers does not equal 100%');
    end
end

%%
function saveLayers
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.lyr', 'Save layers file','');
if ~isempty(pathname)
    lyrs=handles.model.delft3dflow.domain(ad).thick;
    save([pathname filename],'lyrs','-ascii');
end

%%
function editKMax
handles=getHandles;
kmax0=handles.model.delft3dflow.domain(ad).lastKMax;
kmax=handles.model.delft3dflow.domain(ad).KMax;
if kmax~=kmax0
    handles.model.delft3dflow.domain(ad).lastKMax=kmax;
    handles.model.delft3dflow.domain(ad).thick=[];
    if kmax==1
        handles.model.delft3dflow.domain(ad).thick=100;
    else
        for i=1:kmax
            thick(i)=0.01*round(100*100/kmax);
        end
        sumlayers=sum(thick);
        dif=sumlayers-100;
        thick(kmax)=thick(kmax)-dif;
        for i=1:kmax
            handles.model.delft3dflow.domain(ad).thick(i)=thick(i);
        end
    end
    setHandles(handles);
    handles.model.delft3dflow.domain(ad).sumLayers=sum(handles.model.delft3dflow.domain(ad).thick);
end

%%
function selectZModel
handles=getHandles;
switch handles.model.delft3dflow.domain(ad).dpuOpt
    case{'MEAN','UPW','MOR'}
        handles.model.delft3dflow.domain(ad).dpuOpt='MIN';
        setHandles(handles);
        ddb_giveWarning('text','DPUOPT set to MIN in numerical options!');
end



%%
function editZTop
handles=getHandles;
zmax=nanmax(nanmax(handles.model.delft3dflow.domain(ad).depth));
if zmax>handles.model.delft3dflow.domain(ad).zTop
    ButtonName = questdlg(['Maximum height model bathymetry (' num2str(zmax) ' m) exceeds Z Top! Adjust bathymetry?'], ...
        'Adjust bathymetry?', ...
        'No', 'Yes', 'Yes');
    switch ButtonName
        case 'Yes'
            [filename, pathname, filterindex] = uiputfile('*.dep', 'Select depth file',handles.model.delft3dflow.domain(ad).depFile);
            if ~isempty(pathname)
                handles.model.delft3dflow.domain(ad).depFile=filename;
                isn=isnan(handles.model.delft3dflow.domain(ad).depth);
                handles.model.delft3dflow.domain(ad).depth=min(handles.model.delft3dflow.domain(ad).depth,handles.model.delft3dflow.domain(ad).zTop);
                handles.model.delft3dflow.domain(ad).depth(isn)=NaN;
                ddb_wldep('write',filename,handles.model.delft3dflow.domain(ad).depth);
                handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',ad);
            end
    end    
end
setHandles(handles);

%%
function editZBot
handles=getHandles;
zmin=nanmin(nanmin(handles.model.delft3dflow.domain(ad).depth));
if zmin<handles.model.delft3dflow.domain(ad).zBot
    ddb_giveWarning('text',['Maximum depth in model (' num2str(zmin) ' m) exceeds Z Bot!']);
end
setHandles(handles);
