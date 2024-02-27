function transects = jarkus_merge(transects, varargin)
%JARKUS_MERGE  Merges transect altitudes in specific dimension
%
%   Merges the altitude property of a JARKUS transect struct resulting from
%   the jarkus_transects function in a specific dimension. The dimensions
%   can either be time, cross_shore or alongshore. Two mergin methods are
%   available: fill, envelope or extend. The fill method fills NaN values
%   with values from other transects, while the envelope takes the maximum
%   values of all transects. The extend option enlarges the coverage area
%   with past measurements.
%
%   Syntax:
%   transects = jarkus_merge(transects, varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 method    = method of merging fill/enevelop/extend
%                               (default: fill)
%                 dim       = dimension to be used for interpolation
%                               time/cross_shore/alongshore (default: time)
%                 reverse   = merge in reversed order (default: false)
%
%   Output:
%   transects   = merged version of transects struct
%
%   Example
%   transects = jarkus_merge(transects)
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
% Created: 26 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: jarkus_merge.m 5619 2011-12-14 14:47:02Z hoonhout $
% $Date: 2011-12-14 22:47:02 +0800 (Wed, 14 Dec 2011) $
% $Author: hoonhout $
% $Revision: 5619 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_merge.m $
% $Keywords$

%% settings

OPT = struct( ...
    'method', 'fill', ...
    'dim', 'time', ...
    'reversed', false ...
);

OPT = setproperty(OPT, varargin{:});

%% check

if ~jarkus_check(transects, 'altitude', OPT.dim)
    error('Invalid jarkus transect structure');
end

%% merge

altitude = [];
sources = [];

% determine variable values for merging dimension
dim_val = transects.(OPT.dim);
last_val = 0;

% loop in merging dimension
for i = 1:length(dim_val)
    
    % determine merging dimension index
    if OPT.reversed
        ii = length(dim_val)-i+1;
    else
        ii = i;
    end
    
    % determine altitudes in current step
    switch OPT.dim
        case 'time'
            alt = transects.altitude(ii,:,:);
        case 'cross_shore'
            alt = transects.altitude(:,:,ii);
        case 'alongshore'
        case 'id'
            alt = transects.altitude(:,ii,:);
    end
    
    % allocate merged altitudes variable
    if isempty(altitude)
        altitude = nan([size(alt)]);
        sources = nan([size(alt)]);
    end
    
    % determine merging method
    switch OPT.method
        case 'fill'
            % overwrite with non-nan values of current altitudes
            valid_ids = ~isnan(alt);
            altitude(valid_ids) = alt(valid_ids);
            sources(valid_ids) = dim_val(ii);
        case 'envelope'
            % update with larger values of current altitudes
            [altitude, idx] = max(altitude, alt);
            sources(idx) = dim_val(ii);
        case 'extend'
            % update only to extend coverage area'
            idx1 = find(~isnan(alt),1,'first');
            idx2 = find(~isnan(alt),1,'last');
            altitude(idx1:idx2) = alt(idx1:idx2);
            sources(idx1:idx2) = dim_val(ii);
    end
    
    % save last used value of merging dimension
    last_val = dim_val(ii);
end

% update transect struct
transects.(OPT.dim) = last_val;
transects.altitude = altitude;
transects.MERGED = struct('dimension', OPT.dim, 'sources', sources);
