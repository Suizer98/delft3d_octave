function ddb_makeWindDataPlot(handles)
%DDB_MAKEWINDDATAPLOT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_makeWindDataPlot(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_makeWindDataPlot
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ii=get(handles.GUIHandles.ListStations,'Value');
stations=get(handles.GUIHandles.ListStations,'String');
windData=handles.Toolbox(tb).Input.windData;

if isempty(windData)
    giveWarning([],'No data available for this station and period');
    return;
end

fig=MakeNewWindow('Wind Data Time Series',[600 400],[handles.SettingsDir filesep 'icons' filesep 'deltares.gif']);
set(fig,'renderer','painters');
figure(fig);

tbh = uitoolbar;

subplot(3,1,1);
plot(windData(:,1),windData(:,2));
datetick('x',19,'keepticks','keeplimits');
ylabel('wind speed [m/s]');
grid on;
subplot(3,1,2)
plot(windData(:,1),windData(:,3));
datetick('x',19,'keepticks','keeplimits');
ylabel('wind direction [deg N]');
grid on;
subplot(3,1,3)
plot(windData(:,1),windData(:,4));
datetick('x',19,'keepticks','keeplimits');
ylabel('air pressure [mbar]');
grid on;
% md_paper('a4p','wl',{strvcat(['Wind data for station: ' stations{ii}],['Source: ' handles.Toolbox(tb).Input.Source]),' ',' ',' ',' ',' '});


