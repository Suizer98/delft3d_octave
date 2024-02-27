function ddb_NourishmentsToolbox(varargin)
%DDB_GEOIMAGETOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_GeoImageToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_GeoImageToolbox
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_NourishmentsToolbox_equilibriumConcentration.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-25 06:26:17 +0800 (Tue, 25 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nourishments/ddb_NourishmentsToolbox_equilibriumConcentration.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotNourishments('activate');
    handles=getHandles;
    clearInstructions;
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deleteConcentrationPolygon;
        case{'computenourishment'}
            ddb_computeNourishment;
        case{'selectpolygon'}
            refresh;
    end
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
setHandles(handles);
UIPolyline(gca,'draw','Tag','ConcentrationOutline','Marker','o','Callback',@changePolygon,'closed',1,'LineColor','y','MarkerFaceColor','g','MarkerEdgeColor','k');

%%
function changePolygon(x,y,h)

handles=getHandles;

tp=getappdata(h,'type');

if strcmpi(tp,'vertex')
    % Vertex, so existing polygon
    p=getappdata(h,'parent');
    % Find which polygon this is
    for ii=1:handles.toolbox.nourishments.nrConcentrationPolygons
        if handles.toolbox.nourishments.concentrationPolygons(ii).polygonHandle==p
            iac=ii;
        end
    end
else
    % New nourishment
    iac=handles.toolbox.nourishments.nrConcentrationPolygons+1;
    handles.toolbox.nourishments.nrConcentrationPolygons=iac;
    handles.toolbox.nourishments.concentrationPolygons(iac).concentration=0.02;
    handles.toolbox.nourishments.concentrationNames{iac}=['C' num2str(iac)];
    handles.toolbox.nourishments.concentrationPolygons(iac).polygonHandle=h;
end

handles.toolbox.nourishments.activeConcentrationPolygon=iac;
handles.toolbox.nourishments.concentrationPolygons(iac).polygonX=x;
handles.toolbox.nourishments.concentrationPolygons(iac).polygonY=y;
handles.toolbox.nourishments.concentrationPolygons(iac).polyLength=length(x);

setHandles(handles);

refresh;

%%
function deleteConcentrationPolygon
handles=getHandles;
if handles.toolbox.nourishments.nrConcentrationPolygons>0
    iac=handles.toolbox.nourishments.activeConcentrationPolygon;
    try
        UIPolyline(handles.toolbox.nourishments.concentrationPolygons(iac).polygonHandle,'delete');
    end
    handles.toolbox.nourishments.nrConcentrationPolygons=handles.toolbox.nourishments.nrConcentrationPolygons-1;
    handles.toolbox.nourishments.concentrationPolygons=removeFromStruc(handles.toolbox.nourishments.concentrationPolygons,iac);
    handles.toolbox.nourishments.concentrationNames=[];
    for ii=1:handles.toolbox.nourishments.nrConcentrationPolygons
        handles.toolbox.nourishments.concentrationNames{ii}=['C' num2str(ii)];
    end
    handles.toolbox.nourishments.activeConcentrationPolygon=max(min(handles.toolbox.nourishments.nrConcentrationPolygons,iac),1);
    if handles.toolbox.nourishments.nrConcentrationPolygons==0
        handles.toolbox.nourishments.concentrationPolygons(1).polygonX=[];
        handles.toolbox.nourishments.concentrationPolygons(1).polygonY=[];
        handles.toolbox.nourishments.concentrationPolygons(1).polyLength=0;
        handles.toolbox.nourishments.concentrationPolygons(1).concentration=0.02;
    end
    setHandles(handles);
    refresh;
end

%%
function refresh
% setUIElement('nourishmentspanel.equilibriumconcentration.listpolygons');
% setUIElement('nourishmentspanel.equilibriumconcentration.editconcentration');
