function ddb_ModelMakerToolbox_modflowusg_lines(varargin)
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
    % Show lines
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box'});
    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'addpolygon'}
            addPolyline('polygon');
        case{'addpolyline'}
            addPolyline('polyline');
        case{'addpoint'}
            addPolyline('point');
        case{'delete'}
            deletePolyline;
        case{'selectpolyline'}
            updateLines;
        case{'plotlines'}
            plotLines;
    end
    
end

%%
function addPolyline(opt)

handles=getHandles;

ddb_zoomOff;

switch opt
    case{'polygon'}
        iclosed=1;
        maxpoints=10000;
    case{'polyline'}
        iclosed=0;
        maxpoints=10000;
    case{'point'}
        iclosed=0;
        maxpoints=1;
end

gui_polyline('draw','tag','gridgenline','marker','o', ...
    'createcallback',@createPolyline,'changecallback',@changePolyline, ...
    'closed',iclosed,'max',maxpoints);

setHandles(handles);

%%
function createPolyline(h,x,y)
handles=getHandles;
nr=handles.toolbox.modelmaker.gridgen.nrlines;
nr=nr+1;
handles.toolbox.modelmaker.gridgen.lines(nr).handle=h;

if length(x)==1
    opt='point';
else
    if x(end)==x(1) && y(end)==y(1)
        opt='polygon';
    else
        opt='polyline';
    end
end

handles.toolbox.modelmaker.gridgen.lines(nr).name=[opt '_' num2str(nr,'%0.3i')];
handles.toolbox.modelmaker.gridgen.lines(nr).x=x;
handles.toolbox.modelmaker.gridgen.lines(nr).y=y;
handles.toolbox.modelmaker.gridgen.lines(nr).refinement_level=2;
handles.toolbox.modelmaker.gridgen.nrlines=nr;
handles.toolbox.modelmaker.gridgen.linenames{nr}=handles.toolbox.modelmaker.gridgen.lines(nr).name;
handles.toolbox.modelmaker.gridgen.activeline=nr;
setHandles(handles);
updateLines;
gui_updateActiveTab;
addPolyline(opt);

%%
function deletePolyline
handles=getHandles;
nr=handles.toolbox.modelmaker.gridgen.nrlines;
iac=handles.toolbox.modelmaker.gridgen.activeline;
if nr>0
    h=handles.toolbox.modelmaker.gridgen.lines(iac).handle;
    if ~isempty(h)
        delete(h);
    end
    handles.toolbox.modelmaker.gridgen.lines = removeFromStruc(handles.toolbox.modelmaker.gridgen.lines, iac); 
    nr=nr-1;
    handles.toolbox.modelmaker.gridgen.nrlines=nr;
    % Update line names
    handles.toolbox.modelmaker.gridgen.linenames=[];
    for ii=1:nr
        handles.toolbox.modelmaker.gridgen.linenames{ii}=handles.toolbox.modelmaker.gridgen.lines(ii).name;
    end
    handles.toolbox.modelmaker.gridgen.activeline=max(min(handles.toolbox.modelmaker.gridgen.activeline,nr),1);
    
    if nr==0
        handles.toolbox.modelmaker.gridgen.lines(1).refinement_level=[];
    end
    
    setHandles(handles);
    updateLines;
end

%%
function changePolyline(h,x,y,varargin)
handles=getHandles;
nr=handles.toolbox.modelmaker.gridgen.nrlines;
% find which line this is
for ii=1:nr
    hs(ii)=handles.toolbox.modelmaker.gridgen.lines(ii).handle;
end
iac=find(hs==h);
handles.toolbox.modelmaker.gridgen.activeline=iac;
handles.toolbox.modelmaker.gridgen.lines(iac).x=x;
handles.toolbox.modelmaker.gridgen.lines(iac).y=y;
setHandles(handles);
updateLines;
gui_updateActiveTab;

%% 
function updateLines
handles=getHandles;
nr=handles.toolbox.modelmaker.gridgen.nrlines;
if nr>0
    for ii=1:nr
        h=handles.toolbox.modelmaker.gridgen.lines(ii).handle;
%        gui_polyline(h,'change','color','b');
        gui_polyline(h,'change','color',[0.7 0.7 0.7]);
        gui_polyline(h,'change','markeredgecolor',[0.4 0.4 0.4]);
        gui_polyline(h,'change','markerfacecolor',[0.4 0.4 0.4]);
    end
    iac=handles.toolbox.modelmaker.gridgen.activeline;
    h=handles.toolbox.modelmaker.gridgen.lines(iac).handle;
    gui_polyline(h,'change','color','g');
    gui_polyline(h,'change','markeredgecolor','r');
    gui_polyline(h,'change','markerfacecolor','r');
end

%% 
function plotLines
handles=getHandles;
nr=handles.toolbox.modelmaker.gridgen.nrlines;
h=findobj(gcf,'tag','gridgenline');
if ~isempty(h)
    delete(h);
end
if nr>0
    for ii=1:nr
        x=handles.toolbox.modelmaker.gridgen.lines(ii).x;
        y=handles.toolbox.modelmaker.gridgen.lines(ii).y;
        h=gui_polyline('plot','x',x,'y',y,'tag','gridgenline','marker','o','changecallback',@changePolyline,'closed',0);
        handles.toolbox.modelmaker.gridgen.lines(ii).handle=h;
    end
end
setHandles(handles);
updateLines;
gui_updateActiveTab;

