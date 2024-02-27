function ddb_addModelTabPanels
%DDB_ADDMODELTABPANELS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_addModelTabPanels
%
%   Input:

%
%
%
%
%   Example
%   ddb_addModelTabPanels
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

% $Id: ddb_addModelTabPanels.m 17881 2022-03-31 12:28:55Z ormondt $
% $Date: 2022-03-31 20:28:55 +0800 (Thu, 31 Mar 2022) $
% $Author: ormondt $
% $Revision: 17881 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_addModelTabPanels.m $
% $Keywords: $

%%
handles=getHandles;

% Model tabs
models=fieldnames(handles.model);
for i=1:length(models)
    model=models{i};
    handles.activeModel.nr = i;
    setHandles(handles);
%     disp(model);
%    if strcmpi(model,'none')
    if isfield(handles.model.(model),'GUI')
        element=handles.model.(model).GUI.element;
        if ~isempty(element)
            %        element.element.tab(1).tab.callback=@ddb_selectToolbox;
            element=gui_addElements(gcf,element,'getFcn',@getHandles,'setFcn',@setHandles);
            set(element(1).element.handle,'Visible','off');
            handles.model.(model).GUI.element=element;
        end
    end
%    end
end

handles.activeModel.nr = 1;
setHandles(handles);
