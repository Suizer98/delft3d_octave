function ddb_plotTimeSeries(times, prediction, name)
%DDB_PLOTTIMESERIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotTimeSeries(times, prediction, name)
%
%   Input:
%   times      =
%   prediction =
%   name       =
%
%
%
%
%   Example
%   ddb_plotTimeSeries
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

fig=MakeNewWindow('Time Series',[600 400],[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

c=load([handles.settingsDir filesep 'icons' filesep 'icons_muppet.mat']);

figure(fig);

tbh = uitoolbar;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,1,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,2,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);

% h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
% set(h,'ClickedCallback',{@ddb_zoomInOutPan,3,'dummy',[],[],[]}');
% set(h,'Tag','UIToggleToolPan');
% set(h,'cdata',cpan.icons.pan);

handles.screenParameters.xMaxRange=[0 1000000];
handles.screenParameters.yMaxRange=[-1000 1000];
guidata(gcf,handles);

plot(times,prediction);
xtck=datestr(get(gca,'Xtick'),24);
%xtck=datestr(get(gca,'Xtick'));
set(gca,'XTickLabel',xtck);
grid on;
xlabel('Date');
ylabel('Water Level (m)');
title(name);


