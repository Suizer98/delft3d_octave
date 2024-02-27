function [handles ok] = ddb_getDDBoundaries(handles, id1, id2, runid1, runid2)
%DDB_GETDDBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handles ok] = ddb_getDDBoundaries(handles, id1, id2, runid1, runid2)
%
%   Input:
%   handles =
%   id1     =
%   id2     =
%   runid1  =
%   runid2  =
%
%   Output:
%   handles =
%   ok      =
%
%   Example
%   ddb_getDDBoundaries
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
ok=0;

% DD Boundaries
x1=handles.model.delft3dflow.domain(id1).gridX;
y1=handles.model.delft3dflow.domain(id1).gridY;
x2=handles.model.delft3dflow.domain(id2).gridX;
y2=handles.model.delft3dflow.domain(id2).gridY;

ddb=ddb_makeDDModelBoundaries(x1,y1,x2,y2,runid1,runid2);

if ~isempty(ddb)
    ok=1;
end

ndb=length(handles.toolbox.dd.DDBoundaries);
for k=1:length(ddb)
    handles.toolbox.dd.DDBoundaries(ndb+k).runid1=ddb(k).runid1;
    handles.toolbox.dd.DDBoundaries(ndb+k).runid2=ddb(k).runid2;
    handles.toolbox.dd.DDBoundaries(ndb+k).m1a=ddb(k).m1a;
    handles.toolbox.dd.DDBoundaries(ndb+k).m1b=ddb(k).m1b;
    handles.toolbox.dd.DDBoundaries(ndb+k).n1a=ddb(k).n1a;
    handles.toolbox.dd.DDBoundaries(ndb+k).n1b=ddb(k).n1b;
    handles.toolbox.dd.DDBoundaries(ndb+k).m2a=ddb(k).m2a;
    handles.toolbox.dd.DDBoundaries(ndb+k).m2b=ddb(k).m2b;
    handles.toolbox.dd.DDBoundaries(ndb+k).n2a=ddb(k).n2a;
    handles.toolbox.dd.DDBoundaries(ndb+k).n2b=ddb(k).n2b;
end

ddb_saveDDBoundFile(handles.toolbox.dd.DDBoundaries,'ddbound');

