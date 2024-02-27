function [slp dz dx] = jarkus_slope(transects, varargin)
%JARKUS_SLOPE  derive slope of jarkus profile
%
%   Function to derive the slope of jarkus profiles between specific
%   contours and/or min or max altitude values. 
%
%   Syntax:
%   [slp dz dx] = jarkus_slope(transects, varargin)
%
%   Input:
%   transects = jarkus_transects structure
%   varargin  = propertyname propertyvalue pairs:
%             'upper_contour' - upper contour level, either value of
%               function handle (default @max)
%             'upper_ranking' - 'first' (default) or 'last' value (positive
%               seaward)
%             'lower_contour' - lower contour level, either value of
%               function handle (default @min)
%             'lower_ranking' - 'first' (default) or 'last' value (positive
%               seaward)
%
%   Output:
%   slp = array with slopes of transects
%
%   Example
%   % derive the slope between the -4 contours and the deepest points
%   transects = jarkus_transects('year', 2010, 'areacode', 7);
%   slp = jarkus_slope(transects...
%         'upper_contour', -4,...
%         'upper_ranking', 'first',...
%         'lower_contour', @min,...
%         'lower_ranking', 'first');
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 27 Feb 2012
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_slope.m 5820 2012-03-01 11:08:45Z heijer $
% $Date: 2012-03-01 19:08:45 +0800 (Thu, 01 Mar 2012) $
% $Author: heijer $
% $Revision: 5820 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_slope.m $
% $Keywords: $

%%
OPT = struct(...
    'upper_contour', @max,...
    'upper_ranking', 'first',...
    'lower_contour', @min,...
    'lower_ranking', 'first');

OPT = setproperty(OPT, varargin);

%% check
if ~jarkus_check(transects, 'cross_shore', 'altitude')
    error('Invalid jarkus transect structure');
end

%% preallocate contour matrix
size_altitude = size(transects.altitude);
dims = size_altitude(1:end-1);
dimscell = mat2cell(dims, 1 , ones(size(dims)));
c = NaN(2, dimscell{:});

%% gather contour properties
contour = struct(...
    'type', {class(OPT.upper_contour) class(OPT.lower_contour)},...
    'value', {OPT.upper_contour OPT.lower_contour},...
    'ranking', {OPT.upper_ranking OPT.lower_ranking});

%% loop over all transects
[x z] = deal(NaN(size(c)));
for ic = 1:size(c,1)
    for it = 1:size(c,2)
        for ip = 1:size(c,3)
            [x(ic,it,ip) z(ic,it,ip)] = find_contour(transects.cross_shore, squeeze(transects.altitude(it,ip,:)), contour(ic));
        end
    end
end

%% derive slopes
dz = squeeze(-diff(z,1,1));
dx = squeeze(diff(x,1,1));

slp = dx ./ dz;

%%
function [x_contour z_contour] = find_contour(x, z, contour_specs)
% remove nans
nnid = ~isnan(z);
[x z] = deal(x(nnid), z(nnid));
% preallocate
[x_contour z_contour] = deal(NaN);
if isempty(x)
    return
end
if strcmp(contour_specs.type, 'function_handle')
    % find location specified by function handle
    [z_contour ix] = feval(contour_specs.value, z);
    if ~isnan(z_contour)
        x_contour = x(ix);
        if ~isscalar(x_contour)
            x_contour = x_contour(find(ones(size(x_contour)), 1, contour_specs.ranking));
        end
    end
else
    % interpolate contour
    z_contour = contour_specs.value;
    xcr = findCrossings(x(:), z(:), x, repmat(z_contour, size(x)));
    if ~isempty(xcr)
        x_contour = x(find(ones(size(xcr)), 1, contour_specs.ranking));
    end
end