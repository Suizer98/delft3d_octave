function handles = ddb_makeToolBar(handles)
%DDB_MAKETOOLBAR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_makeToolBar(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_makeToolBar
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
delete(findall(gcf,'Type','uitoolbar'));

tbh = uitoolbar;

c=load([handles.settingsDir filesep 'icons' filesep 'icons_muppet.mat']);

% c2=load([handles.settingsDir filesep 'icons' filesep 'icons6.mat']);
cpan=load([handles.settingsDir filesep 'icons' filesep 'icons.mat']);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,1,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);
handles.GUIHandles.toolBar.zoomIn=h;
%set(h,'cdata',c2.ico.zoom_in_32x32);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,2,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);
handles.GUIHandles.toolBar.zoomOut=h;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,3,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]}');
set(h,'Tag','UIToggleToolPan');
set(h,'cdata',cpan.icons.pan);
handles.GUIHandles.toolBar.pan=h;

h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Reset');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,4,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIZoomReset');
set(h,'cdata',cpan.icons.zoomreset);
handles.GUIHandles.toolBar.zoomReset=h;

h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Refresh Bathymetry');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,5,@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(h,'Tag','UIRefreshBathymetry');
set(h,'cdata',cpan.icons.refresh);
handles.GUIHandles.toolBar.refreshBathymetry=h;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Automatically Refresh Bathymetry');
set(h,'ClickedCallback','');
set(h,'Tag','UIAutomaticallyRefreshBathymetry');
set(h,'cdata',cpan.icons.refreshauto);
set(h,'State','on');
handles.GUIHandles.toolBar.autoRefreshBathymetry=h;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Distance calculation with anchor. Press "a" to define anchor location.');
set(h,'ClickedCallback',@ddb_setAnchor);
set(h,'Tag','UIAnchor');
%set(h,'cdata',c.ico.graph_bar16);
set(h,'cdata',cpan.icons.anchor);
set(h,'State','off');
handles.GUIHandles.toolBar.anchor=h;

% h = uitoggletool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Set Anchor');
% set(h,'ClickedCallback','');
% set(h,'Tag','UISetAnchor');
% set(h,'cdata',cpan.icons.refreshauto);
% set(h,'State','on');



% h = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Quickplot');
% %set(h,'ClickedCallback','C:\Delft3D\w32\quickplot\bin\win32\d3d_qp.exe openfile "%1"');
% d3dpath=getenv('D3D_HOME');
% str=['system(''' d3dpath filesep 'w32' filesep 'quickplot' filesep 'bin' filesep 'win32' filesep 'd3d_qp.exe'');'];
% set(h,'ClickedCallback',str);
% set(h,'Tag','UIStartQuickplot');
% %set(h,'cdata',cpan.icons.refresh);
% set(h,'cdata',c.ico.graph_bar16);
% handles.GUIHandles.toolBar.QuickPlot=h;

