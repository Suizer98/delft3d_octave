function ddb_resize(src, evt)
%DDB_RESIZE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_resize(src, evt)
%
%   Input:
%   src =
%   evt =
%
%
%
%
%   Example
%   ddb_resize
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

sz=get(gcf,'Position');

screensize=get(0,'ScreenSize');

if sz(3)<1040 || sz(4)<600
    sz(3)=max(sz(3),1040);
    sz(4)=max(sz(4),600);
    if sz(2)+sz(4)>screensize(4)-60
        sz(2)=screensize(4)-sz(4)-60;
    end
    set(gcf,'Position',sz);
end

ihres=0;
if screensize(3)>1900
    ihres=1;
end

% First change size of model tab panels
models=fieldnames(handles.model);
for ii=1:length(models)
    tabpanel('resize','handle',handles.model.(models{ii}).GUI.element.element.handle,'resize','position',[9 6 sz(3)-10 sz(4)-30]);
end

% Now change size of map panel
hp=get(handles.GUIHandles.mapPanel,'Parent');
posp=get(hp,'Position');

if ihres
    pos=[5 204 posp(3)-10 posp(4)-232];
else
    pos=[5 170 posp(3)-10 posp(4)-193];
end

set(handles.GUIHandles.mapPanel,'Position',pos);

% Now change size of map axis panel
posp=pos;
pos=[40 20 posp(3)-120 posp(4)-50];
set(handles.GUIHandles.mapAxisPanel,'Position',pos);

% Now change size of map axis
set(handles.GUIHandles.mapAxis,'Position',[1 1 pos(3)-5 pos(4)-5]);

% Now change size of colorbar
if verLessThan('matlab', '8.4')
    pos=[posp(3)-35 20 20 posp(4)-50];
    set(handles.GUIHandles.colorBarPanel,'Position',pos);
    pos=[2 2 15 posp(4)-55];
    set(handles.GUIHandles.colorBar,'Position',pos);
else
    pos=[posp(3)-80 10 70 posp(4)-30];
    set(handles.GUIHandles.colorBarPanel,'Position',pos);
    pos=[55 12 15 posp(4)-55];
    set(handles.GUIHandles.colorBar,'Position',pos);
end

% Now change size of coordinate system text
set(handles.GUIHandles.textXCoordinate,'Position',[350 posp(4)-25 80 15]);
set(handles.GUIHandles.textYCoordinate,'Position',[440 posp(4)-25 80 15]);
set(handles.GUIHandles.textZCoordinate,'Position',[530 posp(4)-25 80 15]);
set(handles.GUIHandles.textCoordinateSystem,'Position',[90 posp(4)-25 200 15]);
set(handles.GUIHandles.textBathymetry,'Position',[620 posp(4)-25 400 15]);
set(handles.GUIHandles.textAnchor,'Position',[1000 posp(4)-25 400 15]);

xl=get(handles.GUIHandles.mapAxis,'XLim');
yl=get(handles.GUIHandles.mapAxis,'YLim');

[xl,yl]=CompXYLim(xl,yl,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);

set(handles.GUIHandles.mapAxis,'XLim',xl,'YLim',yl);
handles.screenParameters.xLim=xl;
handles.screenParameters.yLim=yl;

setHandles(handles);

