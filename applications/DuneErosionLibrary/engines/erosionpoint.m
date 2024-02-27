function varargout = erosionpoint(z, z2, varargin)
%EROSIONPOINT  find identifier or x-coordinate of erosion point.
%
%   Routine to find the erosion point based on two cross-shore profiles. If
%   no x-vectors are specified, a boolean vector (identifier) is given
%   which indicates the erosion point. If x, and possibly also x2, is
%   specified, the x-coordinate of the erosion point is given as output.
%
%   Syntax:
%   varargout = erosionpoint(z, z2, varargin)
%
%   Input:
%   z         = vector with altitude of cross-shore profile
%   z2        = vector with altitued of secondary cross-shore profile
%   varargin  = propertyname-propertyvalue pairs:
%           - 'threshold' : threshold below which the difference between z
%           and z2 is considered as 0
%           - 'x' : vector of cross-shore profile z (if x2 is not
%           specified, x also holds for profile z2)
%           - 'x2' : vector of cross-shore profile z2
%           - 'positive_landward' : boolean indicating whether the positive
%           x-direction is landward
%
%   Output:
%   varargout = a boolean vector (if no x-coordinates have been specified)
%               or the x-coordinate of the erosion point
%
%   Example
%   erosionpoint
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 08 Jun 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: erosionpoint.m 4890 2011-07-21 14:43:50Z heijer $
% $Date: 2011-07-21 22:43:50 +0800 (Thu, 21 Jul 2011) $
% $Author: heijer $
% $Revision: 4890 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/engines/erosionpoint.m $
% $Keywords: $

%% propertyname-propertyvalue pairs
OPT = struct(...
    'threshold', 1e-5,...
    'x', [],...
    'x2', [],...
    'positive_landward', false,...
    'method', 'intersection',...
    'lowerboundary', 0);

OPT = setproperty(OPT, varargin{:});

%% check and process input
% combine both x-vectors (use "(:)" to prevent problems with column and row
% vectors)
x = unique([OPT.x(:); OPT.x2(:)]);
if isempty(x)
    % no x-vectors specified
    if ~isequal(length(z), length(z2))
        error('z and z2 should have the same length')
    end
    
    if strcmpi(OPT.method, '1in1')
        error('x-vector must be specified')
    end
else
    if ~isempty(OPT.x)
        % interpolate z on the combined x-grid
        z = interp1(OPT.x(:), z(:), x);
    end

    if ~isempty(OPT.x2)
        % interpolate z2 on the combined x-grid
        z2 = interp1(OPT.x2(:), z2(:), x);
    else
        % interpolate z2 on the combined x-grid
        z2 = interp1(OPT.x(:), z2(:), x);
    end
end

if strcmpi(OPT.method, 'intersection')
    %% find erosion point
    % id of positions where profiles meet or leave each other
    id = diff(abs(z-z2) < OPT.threshold);
    % pre-allocate erosionpointid
    erosionpointid = false(size(z));
    if OPT.positive_landward
        erosionpointid(find(id == 1, 1, 'last') + 1) = true;
    else
        erosionpointid(find(id == -1, 1, 'first')) = true;
    end
    
    %% prepare output
    if isempty(x)
        % give boolean vector indicating the erosion point as output
        varargout = {erosionpointid};
    else
        % give x-coordinate of erosion point as output
        varargout = {x(erosionpointid)};
    end
elseif strcmpi(OPT.method, '1in1')
    V = jarkus_getVolume(...
        x, z,...
        'x2', x,...
        'z2', z2,...
        'LowerBoundary', OPT.lowerboundary);
    varargout = {additional_erosionpoint(x, z, -V,...
        'lowerboundary', OPT.lowerboundary,...
        'positive_landward', OPT.positive_landward)};
else
    error(['method "' OPT.method '" unkown'])
end