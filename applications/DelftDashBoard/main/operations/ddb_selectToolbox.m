function ddb_selectToolbox
%DDB_SELECTTOOLBOX  This function is called to change the toolbox in Delft
%Dashboard
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_selectToolbox

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

handles=getHandles;

name=handles.activeToolbox.name;

%% Get handle of model tab panel
parent=handles.model.(handles.activeModel.name).GUI.element(1).element.handle;

%% Get element structure of tab panel
element=getappdata(parent,'element');

%% And now add the new elements
toolboxelements=handles.toolbox.(name).GUI.element;

model=handles.activeModel.name;

iok=1;

if ~isempty(handles.toolbox.(name).formodel)
    imatch=strmatch(lower(handles.model.(model).name),lower(handles.toolbox.(name).formodel),'exact');
    if isempty(imatch)
        % Toolbox not to be used for this model
        toolboxelements=[];
        toolboxelements(1).element.style='text';
        toolboxelements(1).element.text=['Sorry, the ' handles.toolbox.(name).longName ' toolbox is not available for ' handles.model.(model).longName ' ...'];
        toolboxelements(1).element.position=[50 100 300 20];
        toolboxelements(1).element.tag='text';
        toolboxelements(1).element.horal='left';
        toolboxelements(1).element.tooltipstring='';
        toolboxelements(1).element.enable=1;
        toolboxelements(1).element.parenthandle=parent;
        toolboxelements(1).element.parent=[];
        iok=0;        
    end
end

if iok
    % Check if toolbox has tabs
    % If so, find tabs that are model specific
    if length(toolboxelements)==1
        if strcmpi(toolboxelements(1).element.style,'tabpanel')
            toolboxelements0=toolboxelements;
            toolboxelements0.element.tab=[];
            ntabs=0;
            for itab=1:length(toolboxelements(1).element.tab)
                iadd=0;
                if isempty(toolboxelements(1).element.tab(itab).tab.formodel)
                    % Tab added to all models
                    iadd=1;
                else
                    if isstruct(toolboxelements(1).element.tab(itab).tab.formodel)
                        % Multiple models get this tab
                        for im=1:length(toolboxelements(1).element.tab(itab).tab.formodel)
                            if strcmpi(toolboxelements(1).element.tab(itab).tab.formodel(im).formodel,handles.model.(model).name)
                                iadd=1;
                            end
                        end
                    else
                        % Only one model gets this tab
                        if strcmpi(toolboxelements(1).element.tab(itab).tab.formodel,handles.model.(model).name)
                            iadd=1;
                        end
                    end
                end
                if iadd
                    % Tab specific to active model
                    ntabs=ntabs+1;
                    toolboxelements0(1).element.tab(ntabs).tab=toolboxelements(1).element.tab(itab).tab;
                end
            end
            toolboxelements=toolboxelements0;
        end
    end
    
end

%% Change elements in element structure of model tab panel
element.tab(1).tab.element=toolboxelements;

if iok
    element.tab(1).tab.callback=handles.toolbox.(name).callFcn;
else
    element.tab(1).tab.callback=[];
end

setappdata(parent,'element',element);

setHandles(handles);

drawnow;

% And finally select the toolbox tab
tabpanel('select','handle',handles.model.(model).GUI.element.element.handle,'tabname','toolbox');
