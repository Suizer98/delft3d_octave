function handles = ddb_initializeTemperature(handles, id)
%DDB_INITIALIZETEMPERATURE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTemperature(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeTemperature
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
handles.model.delft3dflow.domain(id).temperature.ICOpt='Constant';
handles.model.delft3dflow.domain(id).temperature.ICConst=20;
handles.model.delft3dflow.domain(id).temperature.ICPar=[0 0];
handles.model.delft3dflow.domain(id).temperature.BCOpt='Constant';
handles.model.delft3dflow.domain(id).temperature.BCConst=20;
handles.model.delft3dflow.domain(id).temperature.BCPar=[0 0];

t0=handles.model.delft3dflow.domain(id).startTime;
t1=handles.model.delft3dflow.domain(id).stopTime;

for j=1:handles.model.delft3dflow.domain(id).nrOpenBoundaries
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.nrTimeSeries=2;
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.timeSeriesT=[t0;t1];
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.timeSeriesA=[20.0;20.0];
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.timeSeriesB=[20.0;20.0];
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.profile='Uniform';
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.interpolation='Linear';
    handles.model.delft3dflow.domain(id).openBoundaries(j).temperature.discontinuity=1;
end

for j=1:handles.model.delft3dflow.domain(id).nrDischarges
    handles.model.delft3dflow.domain(id).Discharges(j).temperature.timeSeries=[20.0;20.0];
end

