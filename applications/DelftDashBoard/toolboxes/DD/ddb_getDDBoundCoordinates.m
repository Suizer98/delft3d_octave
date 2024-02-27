function handles = ddb_getDDBoundCoordinates(handles)
%DDB_GETDDBOUNDCOORDINATES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_getDDBoundCoordinates(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_getDDBoundCoordinates
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

% $Id: ddb_getDDBoundCoordinates.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/DD/ddb_getDDBoundCoordinates.m $
% $Keywords: $

%% Computes coordinates of dd boundaries

for i=1:length(handles.model.delft3dflow.domain)
    rids{i}=handles.model.delft3dflow.domain(i).runid;
end

for idb=1:length(handles.model.delft3dflow.DDBoundaries)
    ddbnd=handles.model.delft3dflow.DDBoundaries(idb);
    ii=strmatch(ddbnd.runid1,rids,'exact');
    if ddbnd.m1a~=ddbnd.m1b
        k=0;
        if ddbnd.m1a<ddbnd.m1b
            for i=ddbnd.m1a:ddbnd.m1b
                k=k+1;
                handles.model.delft3dflow.DDBoundaries(idb).x(k)=handles.model.delft3dflow.domain(ii).gridX(i,ddbnd.n1a);
                handles.model.delft3dflow.DDBoundaries(idb).y(k)=handles.model.delft3dflow.domain(ii).gridY(i,ddbnd.n1a);
            end
        else
            for i=ddbnd.m1b:ddbnd.m1a
                k=k+1;
                handles.model.delft3dflow.DDBoundaries(idb).x(k)=handles.model.delft3dflow.domain(ii).gridX(i,ddbnd.n1a);
                handles.model.delft3dflow.DDBoundaries(idb).y(k)=handles.model.delft3dflow.domain(ii).gridY(i,ddbnd.n1a);
            end
        end
    else
        k=0;
        if ddbnd.n1a<ddbnd.n1b
            for i=ddbnd.n1a:ddbnd.n1b
                k=k+1;
                handles.model.delft3dflow.DDBoundaries(idb).x(k)=handles.model.delft3dflow.domain(ii).gridX(ddbnd.m1a,i);
                handles.model.delft3dflow.DDBoundaries(idb).y(k)=handles.model.delft3dflow.domain(ii).gridY(ddbnd.m1a,i);
            end
        else
            for i=ddbnd.m1b:ddbnd.m1a
                k=k+1;
                handles.model.delft3dflow.DDBoundaries(idb).x(k)=handles.model.delft3dflow.domain(ii).gridX(ddbnd.m1a,i);
                handles.model.delft3dflow.DDBoundaries(idb).y(k)=handles.model.delft3dflow.domain(ii).gridY(ddbnd.m1a,i);
            end
        end
    end
end

