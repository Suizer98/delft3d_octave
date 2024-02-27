function ddb_menuFile(hObject, eventdata, varargin)
%ddb_menuFile
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

handles=getHandles;

if isempty(varargin)

    model=handles.activeModel.name;
    
    % Create new menu items
    
    % First clear out file menu
    p=findobj(gcf,'Tag','menufile');
    ch=get(p,'Children');
    if ~isempty(ch)
        delete(ch);
    end
    
    % New
    if ~strcmpi(model,'none')
        uimenu(p,'Label','New','Callback',{@ddb_menuFile,@ddb_resetAll});
    end    
    
    % Model open options
    for i=1:length(handles.model.(model).GUI.menu.openFile)
        str=handles.model.(model).GUI.menu.openFile(i).string;
        cb=handles.model.(model).GUI.menu.openFile(i).callback;
        opt=handles.model.(model).GUI.menu.openFile(i).option;
        h=uimenu(p,'Label',str,'Callback',{@ddb_menuFile,cb,opt});
        if i==1
            set(h,'Separator','on');
        else
            set(h,'Separator','off');
        end
    end
    
    % Model save options
    for i=1:length(handles.model.(model).GUI.menu.saveFile)
        str=handles.model.(model).GUI.menu.saveFile(i).string;
        cb=handles.model.(model).GUI.menu.saveFile(i).callback;
        opt=handles.model.(model).GUI.menu.saveFile(i).option;
        h=uimenu(p,'Label',str,'Callback',{@ddb_menuFile,cb,opt});
        if i==1
            set(h,'Separator','on');
        else
            set(h,'Separator','off');
        end
    end
    
    % Select working directory
    if ~strcmpi(model,'none')
        uimenu(p,'Label','Select Working Directory','Callback',{@ddb_menuFile,@ddb_selectWorkingDirectory},'Separator','on');
    end

    % Exit
    uimenu(p,'Label','Exit','Callback',{@ddb_menuFile,@ddb_menuExit},'Separator','on');
    
else    
    % Item selected from menu    
    if length(varargin)==1
        % No options specified
        cb=varargin{1};
        feval(cb);
    else
        % Option specified
        cb=varargin{1};
        opt=varargin{2};
        feval(cb,opt);        
    end
end
