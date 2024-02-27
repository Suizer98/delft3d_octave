function handles = ddb_readBndFile(handles, id)
%DDB_READBNDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readBndFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readBndFile
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
handles.model.delft3dflow.domain(id).openBoundaryNames=[];

% Set some values for initializing (Dashboard specific)
t0=handles.model.delft3dflow.domain(id).startTime;
t1=handles.model.delft3dflow.domain(id).stopTime;
nrsed=handles.model.delft3dflow.domain(id).nrSediments;
nrtrac=handles.model.delft3dflow.domain(id).nrTracers;
nrharmo=handles.model.delft3dflow.domain(id).nrHarmonicComponents;
x=handles.model.delft3dflow.domain(id).gridX;
y=handles.model.delft3dflow.domain(id).gridY;
z=handles.model.delft3dflow.domain(id).depthZ;
kcs=handles.model.delft3dflow.domain(id).kcs;
kmax=handles.model.delft3dflow.domain(id).KMax;

% Read boundaries into structure
openBoundaries=delft3dflow_readBndFile(handles.model.delft3dflow.domain(id).bndFile);

% Initialize individual boundary sections
for i=1:length(openBoundaries)
    openBoundaries=delft3dflow_initializeOpenBoundary(openBoundaries,i,t0,t1,nrsed,nrtrac,nrharmo,x,y,z,kcs,kmax);
end

% Copy open boundaries to Dashboard structure
handles.model.delft3dflow.domain(id).openBoundaries=openBoundaries;
handles.model.delft3dflow.domain(id).nrOpenBoundaries=length(openBoundaries);

for i=1:length(openBoundaries)
    handles.model.delft3dflow.domain(id).openBoundaryNames{i}=openBoundaries(i).name;
end

% Count number of harmonic, time series etc.
handles=ddb_countOpenBoundaries(handles,id);

