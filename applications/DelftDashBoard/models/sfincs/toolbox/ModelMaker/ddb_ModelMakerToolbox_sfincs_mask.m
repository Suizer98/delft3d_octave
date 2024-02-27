function ddb_ModelMakerToolbox_sfincs_mask(varargin)
%ddb_DrawingToolbox  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DrawingToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DrawingToolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
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

% $Id: ddb_drawingToolbox_export.m 12926 2016-10-15 07:47:58Z ormondt $
% $Date: 2016-10-15 09:47:58 +0200 (Sat, 15 Oct 2016) $
% $Author: ormondt $
% $Revision: 12926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/drawing/ddb_drawingToolbox_export.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotModelMaker('deactivate');
    ddb_plotsfincs('update','active',1,'visible',1);

    h=findobj(gca,'Tag','sfincsincludepolygon');
    if ~isempty(h)
        set(h,'Visible','on');
        uistack(h,'top');
    end
    h=findobj(gca,'Tag','sfincsexcludepolygon');
    if ~isempty(h)
        set(h,'Visible','on');
        uistack(h,'top');
    end
    
    handles=getHandles;
    ddb_sfincs_plot_mask(handles, 'update','domain',ad,'visible',1);
    
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectincludepolygon'}
            selectIncludePolygon;
        case{'drawincludepolygon'}
            drawIncludePolygon;
        case{'deleteincludepolygon'}
            deleteIncludePolygon;
        case{'loadincludepolygon'}
            loadIncludePolygon;
        case{'saveincludepolygon'}
            saveIncludePolygon;

        case{'selectexcludepolygon'}
            selectExcludePolygon;
        case{'drawexcludepolygon'}
            drawExcludePolygon;
        case{'deleteexcludepolygon'}
            deleteExcludePolygon;
        case{'loadexcludepolygon'}
            loadExcludePolygon;
        case{'saveexcludepolygon'}
            saveExcludePolygon;

        case{'selectclosedboundarypolygon'}
            selectClosedBoundaryPolygon;
        case{'drawclosedboundarypolygon'}
            drawClosedBoundaryPolygon;
        case{'deleteclosedboundarypolygon'}
            deleteClosedBoundaryPolygon;
        case{'loadclosedboundarypolygon'}
            loadClosedBoundaryPolygon;
        case{'saveclosedboundarypolygon'}
            saveClosedBoundaryPolygon;

        case{'selectoutflowboundarypolygon'}
            selectOutflowBoundaryPolygon;
        case{'drawoutflowboundarypolygon'}
            drawOutflowBoundaryPolygon;
        case{'deleteoutflowboundarypolygon'}
            deleteOutflowBoundaryPolygon;
        case{'loadoutflowboundarypolygon'}
            loadOutflowBoundaryPolygon;
        case{'saveoutflowboundarypolygon'}
            saveOutflowBoundaryPolygon;

        case{'selectwaterlevelboundarypolygon'}
            selectWaterlevelBoundaryPolygon;
        case{'drawwaterlevelboundarypolygon'}
            drawWaterlevelBoundaryPolygon;
        case{'deletewaterlevelboundarypolygon'}
            deleteWaterlevelBoundaryPolygon;
        case{'loadwaterlevelboundarypolygon'}
            loadWaterlevelBoundaryPolygon;
        case{'savewaterlevelboundarypolygon'}
            saveWaterlevelBoundaryPolygon;            
            
        case{'useoptionactivegrid'}
            useOptionActiveGrid;
        case{'removeoptionactivegrid'}
            removeOptionActiveGrid;            
        case{'upoptionactivegrid'}
            upOptionActiveGrid;
        case{'downoptionactivegrid'}
            downOptionActiveGrid;            
            
        case{'useoptionboundarycells'}
            useOptionBoundaryCells;
        case{'removeoptionboundarycells'}
            removeOptionBoundaryCells;            
        case{'upoptionboundarycells'}
            upOptionBoundaryCells;
        case{'downoptionboundarycells'}
            downOptionBoundaryCells;        
            
        case{'generatemask'}
            generateMask;
    end
end




%%
function selectIncludePolygon
handles=getHandles;
setHandles(handles);


%%
function drawIncludePolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.includepolygonhandle=gui_polyline('draw','tag','sfincsincludepolygon','marker','o', ...
    'createcallback',@createIncludePolygon,'changecallback',@changeIncludePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createIncludePolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteIncludePolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon;
if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.includepolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.includepolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.includepolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=max(handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=min(handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon,handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons);

if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons==0
    handles.toolbox.modelmaker.sfincs.mask.includepolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.includepolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=1;
end

setHandles(handles);

%%
function changeIncludePolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons
    if handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadIncludePolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.includepolygon=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=0;
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames={''};

h=findobj(gca,'Tag','sfincsincludepolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.includepolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.includepolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincsincludepolygon','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveIncludePolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.includepolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.includepolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).y(ix)]);
    end
end
fclose(fid);



%%
function selectExcludePolygon
handles=getHandles;
setHandles(handles);


%%
function drawExcludePolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.excludepolygonhandle=gui_polyline('draw','tag','sfincsexcludepolygon','color','b','marker','o', ...
    'createcallback',@createExcludePolygon,'changecallback',@changeExcludePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createExcludePolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteExcludePolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon;
if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.excludepolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.excludepolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=max(handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=min(handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon,handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons);

if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons==0
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=1;
end

setHandles(handles);

%%
function changeExcludePolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons
    if handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadExcludePolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.excludepolygon=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=0;
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames={''};

h=findobj(gca,'Tag','sfincsexcludepolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincsexcludepolygon','color','b','marker','o', ...
        'changecallback',@changeExcludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveExcludePolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).y(ix)]);
    end
end
fclose(fid);




%%
function selectClosedBoundaryPolygon
handles=getHandles;
setHandles(handles);


%%
function drawClosedBoundaryPolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonhandle=gui_polyline('draw','tag','sfincsclosedboundarypolygon','color','b','marker','o', ...
    'createcallback',@createClosedBoundaryPolygon,'changecallback',@changeClosedBoundaryPolygon, ...
    'closed',1);

setHandles(handles);

%%
function createClosedBoundaryPolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons=handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteClosedBoundaryPolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon;
if handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons=max(handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon=min(handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon,handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons);

if handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons==0
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon=1;
end

setHandles(handles);

%%
function changeClosedBoundaryPolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons
    if handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadClosedBoundaryPolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon=[];
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons=0;
handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames={''};

h=findobj(gca,'Tag','sfincsclosedboundarypolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activeclosedboundarypolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincsclosedboundarypolygon','color','b','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveClosedBoundaryPolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrclosedboundarypolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon(ip).y(ix)]);
    end
end
fclose(fid);






%%
function selectOutflowBoundaryPolygon
handles=getHandles;
setHandles(handles);


%%
function drawOutflowBoundaryPolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonhandle=gui_polyline('draw','tag','sfincsoutflowboundarypolygon','color','b','marker','o', ...
    'createcallback',@createOutflowBoundaryPolygon,'changecallback',@changeOutflowBoundaryPolygon, ...
    'closed',1);

setHandles(handles);

%%
function createOutflowBoundaryPolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons=handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteOutflowBoundaryPolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon;
if handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons=max(handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon=min(handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon,handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons);

if handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons==0
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon=1;
end

setHandles(handles);

%%
function changeOutflowBoundaryPolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons
    if handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadOutflowBoundaryPolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon=[];
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons=0;
handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames={''};

h=findobj(gca,'Tag','sfincsoutflowboundarypolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activeoutflowboundarypolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincsoutflowboundarypolygon','color','b','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveOutflowBoundaryPolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon(ip).y(ix)]);
    end
end
fclose(fid);

%%
function selectWaterlevelBoundaryPolygon
handles=getHandles;
setHandles(handles);


%%
function drawWaterlevelBoundaryPolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonhandle=gui_polyline('draw','tag','sfincswaterlevelboundarypolygon','color','b','marker','o', ...
    'createcallback',@createWaterlevelBoundaryPolygon,'changecallback',@changeWaterlevelBoundaryPolygon, ...
    'closed',1);

setHandles(handles);

%%
function createWaterlevelBoundaryPolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons=handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteWaterlevelBoundaryPolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon;
if handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons=max(handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon=min(handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon,handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons);

if handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons==0
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon=1;
end

setHandles(handles);

%%
function changeWaterlevelBoundaryPolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons
    if handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadWaterlevelBoundaryPolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon=[];
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons=0;
handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames={''};

h=findobj(gca,'Tag','sfincswaterlevelboundarypolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activewaterlevelboundarypolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincswaterlevelboundarypolygon','color','b','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveWaterlevelBoundaryPolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon(ip).y(ix)]);
    end
end
fclose(fid);

%%
function useOptionActiveGrid

handles=getHandles;

id=handles.toolbox.modelmaker.sfincs.mask.activegrid_index;
name=handles.toolbox.modelmaker.sfincs.mask.activegrid_options{id};

% Check if dataset is already selected
usedd=1;
for ii=1:handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options
    if strcmpi(handles.toolbox.modelmaker.sfincs.mask.activegrid_action{ii},name)
        usedd=0;
        break
    end
end

if usedd

    handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options=handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options+1;
    n=handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options;
    
    handles.toolbox.modelmaker.sfincs.mask.activegrid_action{n}=name;    
    handles.toolbox.modelmaker.sfincs.mask.activegrid_option=n;    

end

setHandles(handles);
gui_updateActiveTab;

%%
function removeOptionActiveGrid
% Remove selected dataset

handles=getHandles;

if handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options>0
    iac=handles.toolbox.modelmaker.sfincs.mask.activegrid_option;  
    
    handles.toolbox.modelmaker.sfincs.mask.activegrid_action=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.activegrid_action, iac);
    
    handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options=handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options-1;
    handles.toolbox.modelmaker.sfincs.mask.activegrid_option=max(min(iac,handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options),1);
    
    setHandles(handles);
    gui_updateActiveTab;
end

%%
function upOptionActiveGrid
% Move selected dataset up
handles=getHandles;

if handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options>0
    iac=handles.toolbox.modelmaker.sfincs.mask.activegrid_option;  

    handles.toolbox.modelmaker.sfincs.mask.activegrid_action=moveUpDownInCellArray(handles.toolbox.modelmaker.sfincs.mask.activegrid_action, iac,'up');
    
    handles.toolbox.modelmaker.sfincs.mask.activegrid_option=iac-1;
    
    setHandles(handles);
end

%%
function downOptionActiveGrid

% Move selected dataset down
handles=getHandles;

if handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options>0
    iac=handles.toolbox.modelmaker.sfincs.mask.activegrid_option;  

    handles.toolbox.modelmaker.sfincs.mask.activegrid_action=moveUpDownInCellArray(handles.toolbox.modelmaker.sfincs.mask.activegrid_action, iac,'down');
    
    handles.toolbox.modelmaker.sfincs.mask.activegrid_option=iac-1;
    
    setHandles(handles);
end

%%
function useOptionBoundaryCells

handles=getHandles;

id=handles.toolbox.modelmaker.sfincs.mask.boundarycells_index;
name=handles.toolbox.modelmaker.sfincs.mask.boundarycells_options{id};

% Check if dataset is already selected
usedd=1;
for ii=1:handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options
    if strcmpi(handles.toolbox.modelmaker.sfincs.mask.boundarycells_action{ii},name)
        usedd=0;
        break
    end
end

if usedd

    handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options=handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options+1;
    n=handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options;
    
    handles.toolbox.modelmaker.sfincs.mask.boundarycells_action{n}=name;    
    handles.toolbox.modelmaker.sfincs.mask.boundarycells_option=n;    

end

setHandles(handles);
gui_updateActiveTab;

%%
function removeOptionBoundaryCells
% Remove selected dataset

handles=getHandles;

if handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options>0
    iac=handles.toolbox.modelmaker.sfincs.mask.boundarycells_option;  
    
    handles.toolbox.modelmaker.sfincs.mask.boundarycells_action=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.boundarycells_action, iac);
    
    handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options=handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options-1;
    handles.toolbox.modelmaker.sfincs.mask.boundarycells_option=max(min(iac,handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options),1);
    
    setHandles(handles);
    gui_updateActiveTab;
end

%%
function upOptionBoundaryCells
% Move selected dataset up
handles=getHandles;

if handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options>0
    iac=handles.toolbox.modelmaker.sfincs.mask.boundarycells_option;  

    handles.toolbox.modelmaker.sfincs.mask.boundarycells_action=moveUpDownInCellArray(handles.toolbox.modelmaker.sfincs.mask.boundarycells_action, iac,'up');
    
    handles.toolbox.modelmaker.sfincs.mask.boundarycells_option=iac-1;
    
    setHandles(handles);
end

%%
function downOptionBoundaryCells

% Move selected dataset down
handles=getHandles;

if handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options>0
    iac=handles.toolbox.modelmaker.sfincs.mask.boundarycells_option;  

    handles.toolbox.modelmaker.sfincs.mask.boundarycells_action=moveUpDownInCellArray(handles.toolbox.modelmaker.sfincs.mask.boundarycells_action, iac,'down');
    
    handles.toolbox.modelmaker.sfincs.mask.boundarycells_option=iac-1;
    
    setHandles(handles);
end

%%
function generateMask

handles=getHandles;

id=ad;

%% Grid mask
msk=handles.model.sfincs.domain(id).mask;

%% Now make the mask matrix
zmin=handles.toolbox.modelmaker.sfincs.zmin;
zmax=handles.toolbox.modelmaker.sfincs.zmax;
zlev = [zmin zmax];
zlev_polygon=handles.toolbox.modelmaker.sfincs.zlev_polygon;

xy_in=handles.toolbox.modelmaker.sfincs.mask.includepolygon;
xy_ex=handles.toolbox.modelmaker.sfincs.mask.excludepolygon;
xy_closedboundary=handles.toolbox.modelmaker.sfincs.mask.closedboundarypolygon;
xy_outflowboundary=handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon;
xy_waterlevelboundary=handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon;

if xy_in(1).length==0
    xy_in=[];
end
if xy_ex(1).length==0
    xy_ex=[];
end
if xy_closedboundary(1).length==0
    xy_closedboundary=[];
end
if xy_outflowboundary(1).length==0
    xy_outflowboundary=[];
end
if xy_waterlevelboundary(1).length==0
    xy_waterlevelboundary=[];
end

clear varargin
varargin_id = 1;
varargin{varargin_id} = 'zlev_polygon';
varargin_id = varargin_id + 1;        
varargin{varargin_id} = zlev_polygon;

% loop over active grid options
for ii=1:handles.toolbox.modelmaker.sfincs.mask.nr_activegrid_options
    
    name = handles.toolbox.modelmaker.sfincs.mask.activegrid_action{ii};
    
    if strcmp(name, 'current mask')   
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'reuse';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = msk;
        
    elseif strcmp(name, 'elevation')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'zlev';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = zlev;  
        
    elseif strcmp(name, 'include polygon')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'includepolygon';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = xy_in;   
        
    elseif strcmp(name, 'exclude polygon')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'excludepolygon';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = xy_ex;           
    end
end

% same for boundary cell options
for ii=1:handles.toolbox.modelmaker.sfincs.mask.nr_boundarycells_options
    
    name = handles.toolbox.modelmaker.sfincs.mask.boundarycells_action{ii};
    
    if strcmp(name, 'waterlevel boundary')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'waterlevelboundarypolygon';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = xy_waterlevelboundary;  
        
    elseif strcmp(name, 'outflow boundary')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'outflowboundarypolygon';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = xy_outflowboundary;          
        
    elseif strcmp(name, 'closed boundary')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'closedboundarypolygon';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = xy_closedboundary;   
        
    elseif strcmp(name, 'elevation')
        varargin_id = varargin_id + 1;        
        varargin{varargin_id} = 'backwards_compatible';

        varargin_id = varargin_id + 1;
        varargin{varargin_id} = 1;  %not used         
    end
end

if ~isempty(handles.model.sfincs.domain(id).buq)
    varargin_id = varargin_id + 1;
    varargin{varargin_id} = 'quadtree';
    varargin_id = varargin_id + 1;
    varargin{varargin_id} = handles.model.sfincs.domain(id).buq;
end

% reload bathy > means in case of reuse that read-in dep-file is not used!
xg=handles.model.sfincs.domain(id).gridx;
yg=handles.model.sfincs.domain(id).gridy; % These are the centre points !!!
zg=handles.model.sfincs.domain(id).gridz;
gridtype='structured';

% [filename,ok]=gui_uiputfile('*.dep', 'Depth File Name',handles.model.sfincs.domain(id).input.depfile);

%% Select bathymetry sources
clear datasets
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets == 0
   datasets(1).name=handles.screenParameters.backgroundBathymetry; % use active bathymetry
 
else    
    for ii=1:handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets
        nr=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).number;
        datasets(ii).name=handles.bathymetry.datasets{nr};
        datasets(ii).startdates=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).startDate;
        datasets(ii).searchintervals=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).searchInterval;
        datasets(ii).zmin=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).zMin;
        datasets(ii).zmax=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).zMax;
        datasets(ii).verticaloffset=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).verticalLevel;
    end
end

% %% Generate bathymetry
% [xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',1,'gridtype',gridtype,'modeloffset',0);

%% Update model data

% run sfincs_make_mask_advanced!
[msk,zg]=sfincs_make_mask_advanced(xg,yg,zg,varargin);

% msk=sfincs_make_mask(xg,yg,zg,'zlev',[zmin zmax],'includepolygon',xy_in,'excludepolygon',xy_ex,'closedboundarypolygon',xy_closedboundary,'outflowboundarypolygon',xy_outflowboundary,'waterlevelboundarypolygon',xy_waterlevelboundary);

zg(isnan(msk)) = NaN; 

%% Update model data
handles.model.sfincs.domain(id).gridz=zg;
handles.model.sfincs.domain(id).mask=msk;

%% And save the files
indexfile=handles.model.sfincs.domain(id).input.indexfile;
bindepfile=handles.model.sfincs.domain(id).input.depfile;
binmskfile=handles.model.sfincs.domain(id).input.mskfile;

% handles.model.sfincs.domain(id).input.inputformat='asc';

if strcmpi(handles.model.sfincs.domain(id).input.inputformat,'bin')
    sfincs_write_binary_inputs(zg,msk,indexfile,bindepfile,binmskfile);
%    hurrywave_write_binary_inputs(zg,msk,indexfile,bindepfile,binmskfile);
else
    sfincs_write_ascii_inputs(zg,msk,bindepfile,binmskfile);
end

%handles = ddb_sfincs_plot_bathymetry(handles, 'plot');

if ~isempty(handles.model.sfincs.domain(id).buq)
    handles.model.sfincs.domain(id).input.qtrfile='sfincs.qtr';
    qtr = handles.model.sfincs.domain(id).buq;
    buq_save_buq_file(qtr, handles.model.sfincs.domain(id).mask, handles.model.sfincs.domain(id).input.qtrfile);
end

handles = ddb_sfincs_plot_mask(handles, 'plot');

setHandles(handles);

