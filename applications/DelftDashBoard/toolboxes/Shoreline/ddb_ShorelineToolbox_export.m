function ddb_ShorelineToolbox_export(varargin)
%DDB_SHORELINETOOLBOX_EXPORT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ShorelineToolbox_export(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_ShorelineToolbox_export
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

% $Id: ddb_ShorelineToolbox_export.m 11763 2015-03-03 11:03:13Z ormondt $
% $Date: 2015-03-03 19:03:13 +0800 (Tue, 03 Mar 2015) $
% $Author: ormondt $
% $Revision: 11763 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Shoreline/ddb_ShorelineToolbox_export.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    selectDataset;
    % setUIElements('shorelinepanel.export');
    ddb_plotShoreline('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectdataset'}
            selectDataset;
            %        case{'selectscale'}
            %            selectScale;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'exportlandboundary'}
            exportLandBoundary;
        case{'export'}
            exportData;
    end
end

%%
function selectDataset
handles=getHandles;
handles.toolbox.shoreline.scaleText=[];
scl=handles.shorelines.shoreline(handles.toolbox.shoreline.activeDataset).scale;
for i=1:length(scl)
    handles.toolbox.shoreline.scaleText{i}=['1 : ' num2str(scl(i),'%20.0f')];
end
setHandles(handles);

%%
function exportData

handles=getHandles;

filename=handles.toolbox.shoreline.shorelineFile;

if handles.shorelines.shoreline(handles.toolbox.shoreline.activeDataset).isAvailable
    
    wb = waitbox('Exporting shoreline ...');pause(0.1);
    
    cs.name=handles.shorelines.shoreline(handles.toolbox.shoreline.activeDataset).horizontalCoordinateSystem.name;
    cs.type=handles.shorelines.shoreline(handles.toolbox.shoreline.activeDataset).horizontalCoordinateSystem.type;
    
    % Convert polygon to coordinate system of shoreline database
    [xx,yy]=ddb_coordConvert(handles.toolbox.shoreline.polygonX,handles.toolbox.shoreline.polygonY,handles.screenParameters.coordinateSystem,cs);
    
    % Determine limits
    xlim(1)=min(xx);
    xlim(2)=max(xx);
    ylim(1)=min(yy);
    ylim(2)=max(yy);
    
    % Fetch shoreline
    [x,y]=ddb_getShoreline(handles,xlim,ylim,handles.toolbox.shoreline.activeScale);
    
    % Convert to local coordinate system
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    
    % Remove points outside polygon
    inp=inpolygon(x,y,handles.toolbox.shoreline.polygonX,handles.toolbox.shoreline.polygonY);
    x(~inp)=NaN;
    y(~inp)=NaN;
    
    close(wb);
    
    % Save shoreline
    xy=[x' y'];
    fix_ldb_from_dashboard('xy',xy,'filename_out',filename,'minarea',0,'close',1);
    
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','ShorelinePolygon');
if ~isempty(h)
    delete(h);
end
UIPolyline(gca,'draw','Tag','ShorelinePolygon','Marker','o','Callback',@changePolygon,'closed',1);
setHandles(handles);

%%
function deletePolygon
handles=getHandles;
handles.toolbox.shoreline.polygonX=[];
handles.toolbox.shoreline.polygonY=[];
handles.toolbox.shoreline.polyLength=0;
h=findobj(gcf,'Tag','ShorelinePolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);

%%
function changePolygon(x,y,varargin)
handles=getHandles;
handles.toolbox.shoreline.polygonX=x;
handles.toolbox.shoreline.polygonY=y;
handles.toolbox.shoreline.polyLength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function loadPolygon
handles=getHandles;
[x,y]=landboundary('read',handles.toolbox.shoreline.polygonFile);
handles.toolbox.shoreline.polygonX=x;
handles.toolbox.shoreline.polygonY=y;
handles.toolbox.shoreline.polyLength=length(x);
h=findobj(gca,'Tag','ShorelinePolygon');
delete(h);
UIPolyline(gca,'plot','Tag','ShorelinePolygon','Marker','o','Callback',@changePolygon,'closed',1,'x',x,'y',y);
setHandles(handles);

%%
function savePolygon
handles=getHandles;
x=handles.toolbox.shoreline.polygonX;
y=handles.toolbox.shoreline.polygonY;
if size(x,1)==1
    x=x';
end
if size(y,1)==1
    y=y';
end
landboundary('write',handles.toolbox.shoreline.polygonFile,x,y);

%%
function saveLdb(filename,x,y,cstype)

npol=0;
for i=1:length(x)
    if ~isnan(x(i))
        if i==1 && ~isnan(x(1))
            % Start of new polygon
            npol=npol+1;
            ipol=1;
            xx{npol}(ipol)=x(i);
            yy{npol}(ipol)=y(i);
        elseif i==1 && isnan(x(1))
            % Do nothing
        elseif ~isnan(x(i)) && isnan(x(i-1))
            % Start of new polygon
            npol=npol+1;
            ipol=1;
            xx{npol}(ipol)=x(i);
            yy{npol}(ipol)=y(i);
        elseif ~isnan(x(i)) && ~isnan(x(i-1))
            % Next point in polygon
            ipol=ipol+1;
            xx{npol}(ipol)=x(i);
            yy{npol}(ipol)=y(i);
        end
    end
end

switch lower(cstype)
    case{'geographic'}
        fmt='%11.6f %11.6f\n';
    otherwise
        fmt='%11.1f %11.1f\n';
end

fid=fopen(filename,'wt');

for j=1:npol
    fprintf(fid,'%s\n',['BL' num2str(j,'%0.5i')]);
    fprintf(fid,'%s\n',[num2str(length(xx{j})) ' 2']);
    for i=1:length(xx{j})
        fprintf(fid,fmt,xx{j}(i),yy{j}(i));
    end
end
fclose(fid);


