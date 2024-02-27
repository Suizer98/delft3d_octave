function transects = jarkus_interpolate_landward(transects, varargin)
%JARKUS_INTERPOLATE_LANDWARD  Interpolate in time to extend the landward side of the jarkus profiles
%
%   Removes the NaN's from the altitude property of a JARKUS transect
%   struct, resulting from the jarkus_transects function, by interpolation.
%   First is interpolated in cross-shore direction, then in time.
%
%   Syntax:
%   transects = jarkus_interpolate_landward(transects, varargin)
%
%   Input:
%   transects   = jarkus data structure as provided by jarkus_transects
%   varargin    = key/value pairs of optional parameters
%                 prop      = property to be interpolated (default:
%                               altitude)
%                 interp1    = property to be used for interpolation
%                               (default: cross_shore)
%                 dim1       = dimension to be used for interpolation
%                               (default: 3)
%                 interp2    = property to be used for interpolation
%                               (default: time)
%                 dim2       = dimension to be used for interpolation
%                               (default: 1)
%
%   Output:
%   transects = JARKUS transects structure
%
%   Example
%   jarkus_interpolate_landward
%
%   See also jarkus_transects jarkus_interpolatenans

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Feb 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: jarkus_interpolate_landward.m 4601 2011-05-27 08:19:32Z heijer $
% $Date: 2011-05-27 16:19:32 +0800 (Fri, 27 May 2011) $
% $Author: heijer $
% $Revision: 4601 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_interpolate_landward.m $
% $Keywords: $

%%

OPT = struct( ...
    'prop', 'altitude',...
    'interp1', 'cross_shore',...
    'dim1', 3,...
    'method1', 'linear', ...
    'extrap1', false,...
    'interp2', 'time',...
    'dim2', 1,...
    'method2', 'linear', ...
    'extrap2', false ...
    );

OPT = setproperty(OPT, varargin{:});

%% check

if ~jarkus_check(transects, {OPT.prop OPT.dim1}, OPT.interp1, {OPT.prop OPT.dim2}, OPT.interp2)
    error('Invalid jarkus transect structure');
end

%% interpolation 1 (by default in cross-shore direction)
transects1 = jarkus_interpolatenans(transects,...
    'interp', OPT.interp1,...
    'dim', OPT.dim1,...
    'method', OPT.method1,...
    'extrap', OPT.extrap1);

%% interpolation 2 (by default in time)
transects2 = jarkus_interpolatenans(transects1,...
    'interp', OPT.interp2,...
    'dim', OPT.dim2,...
    'method', OPT.method2,...
    'extrap', OPT.extrap2);

%%
TODO('Filter to include only the interpolated points at the landward side');
transects = transects2;
