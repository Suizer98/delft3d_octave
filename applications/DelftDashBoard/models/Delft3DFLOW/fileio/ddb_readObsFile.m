function handles = ddb_readObsFile(handles, id)
%DDB_READOBSFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readObsFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readObsFile
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
[name,m,n] = textread(handles.model.delft3dflow.domain(id).obsFile,'%21c%f%f');

for i=1:length(m)
    handles.model.delft3dflow.domain(id).observationPoints(i).name=deblank(name(i,:));
    handles.model.delft3dflow.domain(id).observationPoints(i).M=m(i);
    handles.model.delft3dflow.domain(id).observationPoints(i).N=n(i);
    handles.model.delft3dflow.domain(id).observationPoints(i).x=handles.model.delft3dflow.domain(id).gridXZ(m(i),n(i));
    handles.model.delft3dflow.domain(id).observationPoints(i).y=handles.model.delft3dflow.domain(id).gridYZ(m(i),n(i));
    handles.model.delft3dflow.domain(id).observationPointNames{i}=handles.model.delft3dflow.domain(id).observationPoints(i).name;
end

handles.model.delft3dflow.domain(id).nrObservationPoints=length(m);

