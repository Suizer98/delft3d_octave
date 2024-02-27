function openBoundaries = delft3dflow_initializeOpenBoundary(openBoundaries, nb, t0, t1, nrsed, nrtrac, nrharmo, x, y, depthZ, kcs, kmax, varargin)
%DELFT3DFLOW_INITIALIZEOPENBOUNDARY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   openBoundaries = delft3dflow_initializeOpenBoundary(openBoundaries, nb, t0, t1, nrsed, nrtrac, nrharmo, x, y, depthZ, kcs, varargin)
%
%   Input:
%   openBoundaries =
%   nb             =
%   t0             =
%   t1             =
%   nrsed          =
%   nrtrac         =
%   nrharmo        =
%   x              =
%   y              =
%   depthZ         =
%   kcs            =
%   varargin       =
%
%   Output:
%   openBoundaries =
%
%   Example
%   delft3dflow_initializeOpenBoundary
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: delft3dflow_initializeOpenBoundary.m 9986 2014-01-09 16:01:49Z ormondt $
% $Date: 2014-01-10 00:01:49 +0800 (Fri, 10 Jan 2014) $
% $Author: ormondt $
% $Revision: 9986 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/delft3dflow_initializeOpenBoundary.m $
% $Keywords: $

%%
cs='projected';
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'coordinatesystem'}
                % Coordiate system type (projected or geographic)
                cs=varargin{i+1};
        end
    end
end

openBoundaries(nb).THLag=[0 0];

[xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(openBoundaries(nb),x,y,depthZ,kcs,'coordinatesystem',cs);

openBoundaries(nb).x=xb;
openBoundaries(nb).y=yb;
openBoundaries(nb).depth=zb;
openBoundaries(nb).side=side;
openBoundaries(nb).alphau=alphau;
openBoundaries(nb).alphav=alphav;
openBoundaries(nb).orientation=orientation;


zeros2d=zeros(2,1);
zeros3d=zeros(2,kmax);

% Timeseries
openBoundaries(nb).timeSeriesT=[t0;t1];
switch lower(openBoundaries(nb).profile)
    case{'3d-profile'}
        openBoundaries(nb).timeSeriesA=zeros3d;
        openBoundaries(nb).timeSeriesB=zeros3d;
    otherwise
        openBoundaries(nb).timeSeriesA=zeros2d;
        openBoundaries(nb).timeSeriesB=zeros2d;
end
openBoundaries(nb).nrTimeSeries=2;

% Harmonic
openBoundaries(nb).harmonicAmpA=zeros(1,nrharmo);
openBoundaries(nb).harmonicAmpB=zeros(1,nrharmo);
openBoundaries(nb).harmonicPhaseA=zeros(1,nrharmo);
openBoundaries(nb).harmonicPhaseB=zeros(1,nrharmo);

% QH
openBoundaries(nb).QHDischarge =[0.0 100.0];
openBoundaries(nb).QHWaterLevel=[0.0 0.0];

% Salinity
openBoundaries(nb).salinity.nrTimeSeries=2;
openBoundaries(nb).salinity.timeSeriesT=[t0;t1];
openBoundaries(nb).salinity.timeSeriesA=[31.0;31.0];
openBoundaries(nb).salinity.timeSeriesB=[31.0;31.0];
openBoundaries(nb).salinity.profile='Uniform';
openBoundaries(nb).salinity.interpolation='Linear';
openBoundaries(nb).salinity.discontinuity=1;

% Temperature
openBoundaries(nb).temperature.nrTimeSeries=2;
openBoundaries(nb).temperature.timeSeriesT=[t0;t1];
openBoundaries(nb).temperature.timeSeriesA=[20.0;20.0];
openBoundaries(nb).temperature.timeSeriesB=[20.0;20.0];
openBoundaries(nb).temperature.profile='Uniform';
openBoundaries(nb).temperature.interpolation='Linear';
openBoundaries(nb).temperature.discontinuity=1;

% Sediments
for i=1:nrsed
    openBoundaries(nb).sediment(i).nrTimeSeries=2;
    openBoundaries(nb).sediment(i).timeSeriesT=[t0;t1];
    openBoundaries(nb).sediment(i).timeSeriesA=[0.0;0.0];
    openBoundaries(nb).sediment(i).timeSeriesB=[0.0;0.0];
    openBoundaries(nb).sediment(i).profile='Uniform';
    openBoundaries(nb).sediment(i).interpolation='Linear';
    openBoundaries(nb).sediment(i).discontinuity=1;
end

% Tracers
for i=1:nrtrac
    openBoundaries(nb).tracer(i).nrTimeSeries=2;
    openBoundaries(nb).tracer(i).timeSeriesT=[t0;t1];
    openBoundaries(nb).tracer(i).timeSeriesA=[0.0;0.0];
    openBoundaries(nb).tracer(i).timeSeriesB=[0.0;0.0];
    openBoundaries(nb).tracer(i).profile='Uniform';
    openBoundaries(nb).tracer(i).interpolation='Linear';
    openBoundaries(nb).tracer(i).discontinuity=1;
end


