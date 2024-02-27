function handles = ddb_initializeBoundary(handles, id, nb)
%DDB_INITIALIZEBOUNDARY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeBoundary(handles, id, nb)
%
%   Input:
%   handles =
%   id      =
%   nb      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeBoundary
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
handles.model.delft3dflow.domain(id).openBoundaries(nb).name='unknown';
handles.model.delft3dflow.domain(id).openBoundaries(nb).alpha=0.0;
handles.model.delft3dflow.domain(id).openBoundaries(nb).compA='unnamed';
handles.model.delft3dflow.domain(id).openBoundaries(nb).compB='unnamed';
handles.model.delft3dflow.domain(id).openBoundaries(nb).type='Z';
handles.model.delft3dflow.domain(id).openBoundaries(nb).forcing='A';
handles.model.delft3dflow.domain(id).openBoundaries(nb).profile='Uniform';
handles.model.delft3dflow.domain(id).openBoundaries(nb).THLag=[0 0];

[xb,yb,zb,side,orientation]=delft3dflow_getBoundaryCoordinates(handles,id,nb);
handles.model.delft3dflow.domain(id).openBoundaries(nb).x=xb;
handles.model.delft3dflow.domain(id).openBoundaries(nb).y=yb;
handles.model.delft3dflow.domain(id).openBoundaries(nb).depth=zb;
handles.model.delft3dflow.domain(id).openBoundaries(nb).side=side;
handles.model.delft3dflow.domain(id).openBoundaries(nb).orientation=orientation;

% Timeseries
t0=handles.model.delft3dflow.domain(id).startTime;
t1=handles.model.delft3dflow.domain(id).stopTime;
handles.model.delft3dflow.domain(id).openBoundaries(nb).timeSeriesT=[t0;t1];
handles.model.delft3dflow.domain(id).openBoundaries(nb).timeSeriesA=[0.0;0.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).timeSeriesB=[0.0;0.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).nrTimeSeries=2;

% Harmonic
handles.model.delft3dflow.domain(id).openBoundaries(nb).harmonicAmpA=zeros(1,handles.model.delft3dflow.domain(id).nrHarmonicComponents);
handles.model.delft3dflow.domain(id).openBoundaries(nb).harmonicAmpB=zeros(1,handles.model.delft3dflow.domain(id).nrHarmonicComponents);
handles.model.delft3dflow.domain(id).openBoundaries(nb).harmonicPhaseA=zeros(1,handles.model.delft3dflow.domain(id).nrHarmonicComponents);
handles.model.delft3dflow.domain(id).openBoundaries(nb).harmonicPhaseB=zeros(1,handles.model.delft3dflow.domain(id).nrHarmonicComponents);

% QH
handles.model.delft3dflow.domain(id).openBoundaries(nb).QHDischarge =[0.0 100.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).QHWaterLevel=[0.0 0.0];

% Salinity
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.nrTimeSeries=2;
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.timeSeriesT=[t0;t1];
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.timeSeriesA=[31.0;31.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.timeSeriesB=[31.0;31.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.profile='Uniform';
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.interpolation='Linear';
handles.model.delft3dflow.domain(id).openBoundaries(nb).salinity.discontinuity=1;

% Temperature
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.nrTimeSeries=2;
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.timeSeriesT=[t0;t1];
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.timeSeriesA=[20.0;20.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.timeSeriesB=[20.0;20.0];
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.profile='Uniform';
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.interpolation='Linear';
handles.model.delft3dflow.domain(id).openBoundaries(nb).temperature.discontinuity=1;

% Sediments
for i=1:handles.model.delft3dflow.domain(id).nrSediments
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).nrTimeSeries=2;
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).timeSeriesT=[t0;t1];
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).timeSeriesA=[0.0;0.0];
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).timeSeriesB=[0.0;0.0];
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).profile='Uniform';
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).interpolation='Linear';
    handles.model.delft3dflow.domain(id).openBoundaries(nb).sediment(i).discontinuity=1;
end

% Tracers
for i=1:handles.model.delft3dflow.domain(id).nrTracers
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).nrTimeSeries=2;
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).timeSeriesT=[t0;t1];
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).timeSeriesA=[0.0;0.0];
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).timeSeriesB=[0.0;0.0];
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).profile='Uniform';
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).interpolation='Linear';
    handles.model.delft3dflow.domain(id).openBoundaries(nb).tracer(i).discontinuity=1;
end


