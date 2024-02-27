function [xMKL, volume, varargout] = jarkus_getMKL(x, z, UpperBoundary, LowerBoundary, varargin)
%JARKUS_GETMKL returns the cross shore coordinate of the volume based coastal indicator MKL 
%
%  input:
%  x                   = column array with x points (increasing index and positive x in seaward direction)
%  z                   = column array with z points
%  UpperBoundary       = upper horizontal plane of MKL area 
%  LowerBoundary       = lower horizontal plane of MKL area 
%  varargin            = 
%
%  output: 
%  xMKL                  = cross shore coordinate of MKL
%  volume                = MKL volume
%  varargout: result     = jarkus_getVolume result structure
%             Boundaries = jarkus_getVolume Boundaries
%
% See also: jarkus_getVolume, jarkus_getVolumeFast

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
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

% $Id: jarkus_getMKL.m 13857 2017-10-27 10:07:23Z l.w.m.roest.x $
% $Date: 2017-10-27 18:07:23 +0800 (Fri, 27 Oct 2017) $
% $Author: l.w.m.roest.x $
% $Revision: 13857 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_getMKL.m $
% $Keywords: $

%%
mask=~isnan(z); %Use only non-NaN points, otherwise crossings may be missed.
x=x(mask);
z=z(mask);

LandwardBoundary = max(jarkus_findCrossings(x,z,[x(1) x(end)],[UpperBoundary UpperBoundary])); %most landward crossing
SeawardBoundary  = max(jarkus_findCrossings(x,z,[x(1) x(end)],[LowerBoundary LowerBoundary])); %most seaward crossing

if isempty(LandwardBoundary)
    warning('transect does not cross UpperBoundary')
    xMKL = NaN;
    volume=NaN;
    return
end

if isempty(SeawardBoundary)
    warning('transect does not cross LowerBoundary')
    xMKL = NaN;
    volume=NaN;
    return
end

if LandwardBoundary >= SeawardBoundary
    warning('can''t calculate MKL position: LandwardBoundary >= SeawardBoundary')
    xMKL = NaN;
    volume=NaN;
    return
end

% jarkus_getVolume is really slow, use jarkus_getVolumeFast instead
if nargout > 2
    % jarkus_getVolume is much slower than jarkus_getVolumeFast, but gives
    % additional output arguments "result" and "Boundaries"
    [volume, result, Boundaries] = jarkus_getVolume(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary, [], [], varargin);
    varargout = {result Boundaries};
else
    % use the faster jarkus_getVolumeFast if only the xMKL is of interest,
    % and possibly the volume
    volume = jarkus_getVolumeFast(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary, varargin{:});
end

xMKL = LandwardBoundary + volume / (UpperBoundary - LowerBoundary);
