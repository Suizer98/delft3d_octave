function ddb_initializeFigure
%DDB_INITIALIZEFIGURE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_initializeFigure
%
%   Input:

%
%
%
%
%   Example
%   ddb_initializeFigure
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

handles.GUIHandles.mainWindow=MakeNewWindow(handles.configuration.title,[1300 700],[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
h=handles.GUIHandles.mainWindow;
set(h,'WindowState','maximized');

set(h,'Tag','MainWindow','Visible','off');

set(h,'Renderer','opengl');

handles.backgroundColor=get(h,'Color');

figure(h);

fh = get(h,'JavaFrame'); % Get Java Frame
fh.setFigureIcon(javax.swing.ImageIcon([handles.settingsDir filesep 'icons' filesep 'deltares.gif']));

set(h,'toolbar','figure');
set(h,'Tag','MainWindow');

handles=ddb_makeMenu(handles);

handles=ddb_makeToolBar(handles);

%set(h,'Tag','MainWindow','Visible','off');

str=['WGS 84 / UTM zone ' num2str(handles.screenParameters.UTMZone{1}) 'N'];
try
    set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',str);
end

% set(handles.GUIHandles.mainWindow,'Visible','off');

set(handles.GUIHandles.mainWindow,'WindowKeyPressFcn',{@ddb_pan,'start',@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
set(handles.GUIHandles.mainWindow,'WindowKeyReleaseFcn',{@ddb_pan,'stop',@ddb_updateDataInScreen,[],@ddb_updateDataInScreen,[]});
handles.GUIHandles.panning=0;

setHandles(handles);

set(h,'Tag','MainWindow','Visible','off');

drawnow;
