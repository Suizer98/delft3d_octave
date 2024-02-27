function transects = jarkus_interpolatenans(transects, varargin)
%JARKUS_INTERPOLATENANS  Interpolates the missing altitude values in jarkus transects
%
%   Removes the NaN's from the altitude property of a JARKUS transect
%   struct resulting from the jarkus_transects function by interpolation.
%
%   Syntax:
%   transects = jarkus_interpolatenans(transects, varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 prop      = property to be interpolated (default:
%                               altitude)
%                 interp    = property to be used for interpolation
%                               (default: cross_shore)
%                 dim       = dimension to be used for interpolation
%                               (default: 3)
%                 method    = interpolation method (default: linear)
%                 extrap    = boolean indicating whether extrapolation must
%                               be applied (default: false)
%                 maxgap    = limit to number of points to interpolate
%                               (default: Inf). Note: this does not apply
%                               to points to extrapolate
%
%   Output:
%   transects   = interpolated version of transects struct
%
%   Example
%   transects = jarkus_interpolatenans(transects)
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Jan 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: jarkus_interpolatenans.m 8418 2013-04-10 07:02:09Z heijer $
% $Date: 2013-04-10 15:02:09 +0800 (Wed, 10 Apr 2013) $
% $Author: heijer $
% $Revision: 8418 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_interpolatenans.m $
% $Keywords$

%% settings

OPT = struct( ...
    'prop', 'altitude', ...
    'interp', 'cross_shore', ...
    'dim', 3, ...
    'method', 'linear', ...
    'extrap', false,...
    'maxgap', Inf ...
);

OPT = setproperty(OPT, varargin{:});

%% check

if ~jarkus_check(transects, {OPT.prop OPT.dim}, OPT.interp)
    error('Invalid jarkus transect structure');
end

%% interpolate

dims = size(transects.(OPT.prop));
dims(OPT.dim) = 1;

% define method and whether or not extrap should be applied
options = {OPT.method};
if OPT.extrap
    options = [options {'extrap'}];
end

n = prod(dims);
for i = 1:n
    coords = num2cell(numel2coord(dims, i));
    coords{OPT.dim} = ':';
    
    property = squeeze(transects.(OPT.prop)(coords{:}));
    interpolate = squeeze(transects.(OPT.interp));
    
    notnan = ~isnan(property(:)); % (:) is to make sure that it results in a column vector
    
    if isfinite(OPT.maxgap)
        % identify the gaps
        % take the cumulative sum of the inverse mask
        % the parts in the middle where the cumsum is constant over more
        % than maxgap must be identified in the final mask
        csa = cumsum(notnan); % ascending
        csd = flipud(cumsum(flipud(notnan))); % descending
        % turn the cumsums to zero at the original points
        csa(notnan) = 0;
        csd(notnan) = 0;
        % count the unique values in the cumsum
        [n_occurrences, c] = count(csa);
        % create a mask indicating the groups of nans with more the maxgap
        % points. The additional requirements of csa and csd to be larger
        % than zero will prevent the leading and trailing nans to be
        % masked.
        mask = ismember(csa, c(n_occurrences>OPT.maxgap)) & csa>0 & csd>0;
        % update coords with based on the mask
        coords{OPT.dim} = ~mask;
    else
        mask = false(size(notnan));
    end
    
    if sum(notnan) > 1
        % apply interp1 along the specified dimension with the given
        % options
        transects.(OPT.prop)(coords{:}) = interp1(interpolate(notnan), ...
            property(notnan), interpolate(~mask), options{:});
    elseif OPT.extrap && strcmp(OPT.method, 'nearest') && sum(notnan) == 1
        % in this case the single available data point in this dimension is
        % copied along the whole dimension
        % interp1 cannot deal with only one point
        transects.(OPT.prop)(coords{:}) = deal(property(notnan));
    end
end