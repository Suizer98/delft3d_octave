function handles = ddb_initializeSalinity(handles, id)
%DDB_INITIALIZESALINITY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeSalinity(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeSalinity
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
handles.model.delft3dflow.domain(id).salinity.ICOpt='Constant';
handles.model.delft3dflow.domain(id).salinity.ICConst=31;
handles.model.delft3dflow.domain(id).salinity.ICPar=[0 0];
handles.model.delft3dflow.domain(id).salinity.BCOpt='Constant';
handles.model.delft3dflow.domain(id).salinity.BCConst=31;
handles.model.delft3dflow.domain(id).salinity.BCPar=[0 0];

t0=handles.model.delft3dflow.domain(id).startTime;
t1=handles.model.delft3dflow.domain(id).stopTime;

for j=1:handles.model.delft3dflow.domain(id).nrOpenBoundaries
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.nrTimeSeries=2;
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.timeSeriesT=[t0;t1];
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.timeSeriesA=[0.0;0.0];
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.timeSeriesB=[0.0;0.0];
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.profile='Uniform';
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.interpolation='Linear';
    handles.model.delft3dflow.domain(id).openBoundaries(j).salinity.discontinuity=1;
end

for j=1:handles.model.delft3dflow.domain(id).nrDischarges
    handles.model.delft3dflow.domain(id).discharges(j).salinity.timeSeries=[0.0;0.0];
end

