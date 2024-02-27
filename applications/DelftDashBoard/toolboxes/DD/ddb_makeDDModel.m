function [handles cancel] = ddb_makeDDModel(handles, id1, id2, runid)
%DDB_MAKEDDMODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handles cancel] = ddb_makeDDModel(handles, id1, id2, runid)
%
%   Input:
%   handles =
%   id1     =
%   id2     =
%   runid   =
%
%   Output:
%   handles =
%   cancel  =
%
%   Example
%   ddb_makeDDModel
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% wb = waitbox('Generating Subdomain ...');pause(0.1);

runid1=handles.model.delft3dflow.domain(id1).runid;
runid2=runid;

handles.model.delft3dflow.domain(id2)=handles.model.delft3dflow.domain(id1);

% create backup of original model with id0
handles.toolbox.dd.originalDomain=handles.model.delft3dflow.domain(id1);

handles=ddb_initializeFlowDomain(handles,'griddependentinput',id2,runid);

m1=handles.toolbox.dd.firstCornerPointM;
n1=handles.toolbox.dd.firstCornerPointN;
m2=handles.toolbox.dd.secondCornerPointM;
n2=handles.toolbox.dd.secondCornerPointN;
mdd(1)=min(m1,m2);mdd(2)=max(m1,m2);
ndd(1)=min(n1,n2);ndd(2)=max(n1,n2);

% New Domain
% Grid
[handles,mdd,ndd]=ddb_makeDDModelNewGrid(handles,id1,id2,mdd,ndd,runid);

% Original Domain
% Grid
[handles,mcut,ncut,cancel]=ddb_makeDDModelOriginalGrid(handles,id1,mdd,ndd);

if ~cancel
    
    % New Domain
    % Attributes
    handles=ddb_makeDDModelNewAttributes(handles,id1,id2,runid1,runid2);
    
end

% close(wb);

