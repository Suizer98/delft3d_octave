function ddb_selectModel(mdl)
%DDB_SELECTMODEL  This function is called to change the model in Delft
%Dashboard
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_selectModel(mdl)
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

model=handles.activeModel.name;

% Making previous model invisible
set(handles.model.(model).GUI.element(1).element.handle,'Visible','off');

% Deactivate current model
feval(handles.model.(model).plotFcn,'update','active',0,'visible',1,'domain',0,'wavedomain',0,'deactivate',1);

% Setting new active model
models=fieldnames(handles.model);
ii=strmatch(mdl,models,'exact');
handles.activeModel.name=mdl;
handles.activeModel.nr=ii;

setHandles(handles);

% Make new active model visible
set(handles.model.(mdl).GUI.element(1).element.handle,'Visible','on');

% Change menu items (file, domain and view)
ddb_menuFile;
%ddb_menuView;
%ddb_changeFileMenuItems;

% Set the domain menu
if handles.model.(mdl).supportsMultipleDomains
    set(handles.GUIHandles.Menu.Domain.Main,'Enable','on');
else
    if isfield(handles.GUIHandles.Menu,'Domain')
        set(handles.GUIHandles.Menu.Domain.Main,'Enable','off');
    end
end

% Make the map panel a child of the present model tab panel
set(handles.GUIHandles.mapPanel,'Parent',handles.model.(mdl).GUI.element(1).element.handle);

% Select toolbox
ddb_selectToolbox;

