function handles=ddb_addModelViewMenu(handles)
%DDB_CHANGEFILEMENUITEMS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_changeFileMenuItems
%
%   Input:

%
%
%
%
%   Example
%   ddb_changeFileMenuItems
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

% $Id: ddb_changeFileMenuItems.m 8254 2013-03-01 13:55:47Z ormondt $
% $Date: 2013-03-01 14:55:47 +0100 (Fri, 01 Mar 2013) $
% $Author: ormondt $
% $Revision: 8254 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/menu/ddb_changeFileMenuItems.m $
% $Keywords: $

%%
hmain=handles.GUIHandles.Menu.View.Main;
isep='on';
models=fieldnames(handles.model);
for ii=1:length(models)
    model=models{ii};
    if ~isempty(handles.model.(model).GUI.menu.view)
        g=uimenu(hmain,'Label',handles.model.(model).longName,'separator',isep);
        isep='off';
        % And the attributes
        for iatt=1:length(handles.model.(model).GUI.menu.view)
            string=handles.model.(model).GUI.menu.view(iatt).string;
            callback=handles.model.(model).GUI.menu.view(iatt).callback;
            argin=handles.model.(model).GUI.menu.view(iatt).option;
            checked='on';
%             if isfield(handles.model.(model).GUI.menu,'menuview')
%                 if isfield(handles.model.(model).menuview,argin)
%                     if handles.model.(model).menuview.(argin)==0
%                         checked='off';
%                     end
%                 end
%             end
            uimenu(g,'Label',string,'Callback',{callback,argin},'Checked',checked);
        end
    end
end
