function ddb_resetAll
%DDB_RESETALL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_resetAll
%
%   Input:

%
%
%
%
%   Example
%   ddb_resetAll
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

% Delete new axes that is sometimes created for no apparent reason. Another
% fix for this should be found!!!
h=findobj(gcf,'Type','axes');
for i=1:length(h)
    if isempty(get(h(i),'Tag'));
        delete(h(i));
    end
end

handles=getHandles;

models=fieldnames(handles.model);

for i=1:length(models)
    try
        feval(handles.model.(models{i}).plotFcn,'delete');
    end
end

fldnames=fieldnames(handles.toolbox);
for i=1:length(fldnames)
    try
        feval(handles.toolbox.(fldnames{i}).plotFcn,'delete');
    end
end

% Want to keep current model active, so store in icurrentmodel
currentmodel=handles.activeModel.name;

ddb_initialize('all');

% ddb_initialize set current model to delft3d-flow, so set back to original
% model

handles=getHandles;
handles.activeModel.name=currentmodel;
setHandles(handles);

ddb_selectModel(handles.activeModel.name);
