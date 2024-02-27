function ddb_menuToolbox(hObject, eventdata, varargin)
%DDB_MENUTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuToolbox(hObject, eventdata)
%
%   Input:
%   hObject   =
%   eventdata =
%
%
%
%
%   Example
%   ddb_menuToolbox
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
   
if isempty(varargin)

    % Fill menu on initialization

    toolboxes=fieldnames(handles.toolbox);
%     toolboxes0=fieldnames(handles.toolbox);
%     % First sort toolboxes, ModelMaker toolbox must be the first one
%     toolboxes{1}='modelmaker';
%     n=1;
%     for k=1:length(toolboxes0)
%         if ~strcmpi(toolboxes0{k},'modelmaker')
%             n=n+1;
%             toolboxes{n}=toolboxes0{k};
%         end
%     end
    
    p=findobj(gcf,'Tag','menutoolbox');

    firstadditional=1;
    for k=1:length(toolboxes)
        
        name=toolboxes{k};
        
        if handles.toolbox.(name).enable
            enab='on';
        else
            enab='off';
        end
        
        % Separator below ModelMaker toolbox
        if k==2
            sep='on';
        elseif (strcmpi(handles.toolbox.(name).toolbox_type,'additional') && firstadditional)
            firstadditional=0;
            sep='on';
        else
            sep='off';
        end
        
%        if k==1
        if strcmpi(handles.activeToolbox.name,name)
            checked='on';
        else
            checked='off';
        end
        
        uimenu(p,'Label',handles.toolbox.(name).longName,'Callback',{@ddb_menuToolbox,0},'separator',sep,'enable',enab,'checked',checked,'tag',name);
        
    end
    
else

    % Toolbox selected from menu
    
    % Check the selected toolbox in the menu
    h=get(hObject,'Parent');
    ch=get(h,'Children');
    set(ch,'Checked','off');
    set(hObject,'Checked','on');    
    
    % Set the new active toolbox
    tbname=get(hObject,'Tag');
    if ~strcmpi(handles.activeToolbox.name,tbname)
        handles.activeToolbox.name=tbname;
%         handles.activeToolbox.nr=strmatch(tbname,toolboxes,'exact');
        % Now add the new GUI elements to toolbox tab
        setHandles(handles);
        % Select toolbox
        set(gcf,'Pointer','watch');
        ddb_selectToolbox;
        set(gcf,'Pointer','arrow');
    end

end
