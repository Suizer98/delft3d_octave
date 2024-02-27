function xb = xb_set_start_time(xb, varargin)
%XB_SET_START_TIME  sets the required start and stop times
%
%   Routine to estimate the time needed for the waves to reach te coast.
%   Based on that the tstart, morstart and tstop can be adjusted. The
%   required time is estimated assuming a wave celerity of sqrt(gh).
%
%   Syntax:
%   varargout = xb_set_start_time(varargin)
%
%   Input:
%   xb        = XBeach input structure
%   varargin  = propertyname-propertyvaluepairs
%               - waterlevel : maximum water level during the simulation
%
%   Output:
%   xb        = XBeach input structure
%
%   Example
%   xb_set_start_time
%
%   See also

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
% Created: 08 Aug 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_set_start_time.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_bc/xb_set_start_time.m $
% $Keywords: $

%%
OPT = struct(...
    'vars2update', {{'tstart' 'morstart' 'tstop'}},...
    'waterlevel', 0,...
    'g', 9.81);

OPT = setproperty(OPT, varargin{:});

%%
[tstart morstart] = xs_get(xb, 'tstart', 'morstart');
if isempty(tstart)
    tstart = 0;
end
if isempty(morstart)
    morstart = 0;
end
[tstop morfac] = xs_get(xb, 'tstop', 'morfac');
if isempty(morfac)
    % if morfac is not in the xb structure, set it to one
    morfac = 1;
end
[x z] = xs_get(xb, 'xfile.xfile', 'depfile.depfile');
% derive duration
duration = tstop - max(morstart, tstart);

% reduce x and z to vectors
if isempty(x)
    % equidistant grid: vardx = 0
    dx = xs_get(xb, 'dx');
    x = 0:dx:(size(z,2)-1)*dx;
else
    % variable grid: vardx = 1
    x = x(1,:);
end
% take minimum z in alongshore direction
z = min(z, [], 1); 

% find part of profile under the surge level
xcr = floor(findCrossings(x, z, x([1 end]), repmat(OPT.waterlevel,1,2)));
wetid = x < min(xcr);
% derive the depth at each profile point
h = OPT.waterlevel - z([false wetid(2:end)]);
% find the minimal start time assuming a wave celerity of sqrt(gh) times
% the morfac
tstart_min = roundoff(sum(diff(x(wetid)) ./ sqrt(OPT.g*h)) * morfac, -1, 'ceil');

% update xb
for var = OPT.vars2update
    switch var{1}
        case 'tstart'
            xb = xs_set(xb, 'tstart', tstart_min);
        case 'morstart'
            xb = xs_set(xb, 'morstart', tstart_min);
        case 'tstop'
            xb = xs_set(xb, 'tstop', tstart_min + duration);
    end
end

if xs_exist(xb, 'bcfile.duration')
    data    = xs_get(xb, 'bcfile.duration');
    dt      = xs_get(xb, 'tstop')-sum(data);
    data(end) = data(end) + dt + 1;
    xb      = xs_set(xb, 'bcfile.duration', data);
end

if xs_exist(xb, 'zs0file.time')
    data    = xs_get(xb, 'zs0file.time');
    dt      = xs_get(xb, 'tstop')-data(end);
    data(end) = data(end) + dt + 1;
    xb      = xs_set(xb, 'zs0file.time', data);
end

