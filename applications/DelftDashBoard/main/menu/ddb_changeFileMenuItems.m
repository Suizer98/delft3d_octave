function ddb_changeFileMenuItems
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

% $Id: ddb_changeFileMenuItems.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/menu/ddb_changeFileMenuItems.m $
% $Keywords: $

%%
handles=getHandles;


hmain=handles.GUIHandles.Menu.File.Main;
ch=get(hmain,'Children');
if ~isempty(ch)
    delete(ch);
end

% New
argin=[];
argin{1}='Callback';
argin{2}=@ddb_resetAll;
handles=ddb_addMenuItem(handles,'File','New','Callback',@ddb_menuSelect,'argin',argin);

model=handles.activeModel.name;

% File open
for i=1:length(handles.model.(model).GUI.menu.openFile)
    str=handles.model.(model).GUI.menu.openFile(i).string;
    cb=handles.model.(model).GUI.menu.openFile(i).callback;
    opt=handles.model.(model).GUI.menu.openFile(i).option;
    %    tag=handles.model.(model).GUI.menu.openFile(i).tag;
    argin=[];
    argin{1}='Callback';
    argin{2}=cb;
    argin{3}='Options';
    argin{4}=opt;
    if i==1
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin,'Separator','on');
    else
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin);
    end
end

% File save
for i=1:length(handles.model.(model).GUI.menu.saveFile)
    str=handles.model.(model).GUI.menu.saveFile(i).string;
    cb=handles.model.(model).GUI.menu.saveFile(i).callback;
    opt=handles.model.(model).GUI.menu.saveFile(i).option;
    %    tag=handles.model.(model).GUI.menu.openFile(i).tag;
    argin=[];
    argin{1}='Callback';
    argin{2}=cb;
    argin{3}='Options';
    argin{4}=opt;
    if i==1
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin,'Separator','on');
    else
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin);
    end
end

% Save all models
argin=[];
argin{1}='Callback';
argin{2}=@ddb_saveAllModelFiles;
handles=ddb_addMenuItem(handles,'File','Save All Model Files','Callback',@ddb_menuSelect,'argin',argin,'Separator','on');

% Working directory
argin=[];
argin{1}='Callback';
argin{2}=@ddb_selectWorkingDirectory;
handles=ddb_addMenuItem(handles,'File','Select Working Directory','Callback',@ddb_menuSelect,'argin',argin,'Separator','on');

% % Proxy settings
% argin=[];
% argin{1}='Callback';
% argin{2}=@ddb_setProxySettings;
% handles=ddb_addMenuItem(handles,'File','Proxy Settings ...','Callback',@ddb_menuSelect,'argin',argin,'Separator','on');
% 
% % SNC settings
% argin=[];
% argin{1}='Callback';
% argin{2}=@ddb_setSNCSettings;
% handles=ddb_addMenuItem(handles,'File','SNC Settings ...','Callback',@ddb_menuSelect,'argin',argin,'Separator','off');

% Exit
argin=[];
argin{1}='Callback';
argin{2}=@ddb_menuExit;
handles=ddb_addMenuItem(handles,'File','Exit',                    'Callback',@ddb_menuSelect,'argin',argin,'Separator','on');

setHandles(handles);

