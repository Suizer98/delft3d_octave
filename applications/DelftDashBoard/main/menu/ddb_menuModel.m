function ddb_menuModel(hObject, eventdata, varargin)
%DDB_MENUMODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuModel(hObject, eventdata)
%
%   Input:
%   hObject   =
%   eventdata =
%
%
%
%
%   Example
%   ddb_menuModel
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
   
models=fieldnames(handles.model);

if isempty(varargin)

    % Fill menu on initialization

%     % First sort models, Delft3D-FLOW must be the first one
%     models{1}='delft3dflow';
%     n=1;
%     for k=1:length(models0)
%         if ~strcmpi(models0{k},'delft3dflow')
%             n=n+1;
%             models{n}=models0{k};
%         end
%     end
    
    p=findobj(gcf,'Tag','menumodel');

    for k=1:length(models)
        
        name=models{k};
        
        if ~strcmpi(name,'none')
            if handles.model.(name).enable
                sep='off';
                if strcmpi(handles.activeModel.name,name)
                    %            if k==1
                    checked='on';
                else
                    checked='off';
                end
                uimenu(p,'Label',handles.model.(name).longName,'Callback',{@ddb_menuModel,0},'separator',sep,'checked',checked,'tag',name);
            end
        end
        
    end
else

    % Toolbox selected from menu
    
    % Check the selected toolbox in the menu
    h=get(hObject,'Parent');
    ch=get(h,'Children');
    set(ch,'Checked','off');
    set(hObject,'Checked','on');    
    
    % Set the new active toolbox
    mdlname=get(hObject,'Tag');
    if ~strcmpi(handles.activeModel.name,mdlname)
        % Select model
        set(gcf,'Pointer','watch');
        ddb_selectModel(mdlname);
        set(gcf,'Pointer','arrow');
    end

end




