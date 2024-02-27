function [x ix] = xb_get_activeprofile(xb, varargin)
%XB_GET_ACTIVEPROFILE  Determines the range of the profile that is active
%
%   Determines the x-range of the profile that is active by locating the
%   area in which a certain percentage of the bed level change is located.
%   By default, this percentage is 90%.
%
%   Syntax:
%   [x ix] = xb_get_activeprofile(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = dzfrac:     Fraction of total profile change that should be
%                           included in the range returned
%
%   Output:
%   x         = Array with minimum and maximum x-locations with in between
%               the requested percentage of bed level change
%   xi        = Array with the corresponding indices in the x-grid
%
%   Example
%   x = xb_get_activeprofile(xb)
%   [x xi] = xb_get_activeprofile(xb)
%   [x xi] = xb_get_activeprofile(xb, 'dzfrac', .8)
%
%   See also xb_get_profile

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Jul 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_activeprofile.m 11891 2015-04-22 13:06:59Z bieman $
% $Date: 2015-04-22 21:06:59 +0800 (Wed, 22 Apr 2015) $
% $Author: bieman $
% $Revision: 11891 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_analysis/xb_get_activeprofile.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'dzfrac', .9 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine profiles

xb      = xb_get_transect(xb);

x       = xs_get(xb, 'DIMS.globalx_DATA');
nx      = xs_get(xb, 'DIMS.nx');
if size(x,2) ~= (nx+1)
    x = x';
end
x       = squeeze(x(1,:));

% determine bathymetry
if xs_exist(xb, 'zb')
    zb      = xs_get(xb,'zb');
else
    error('No bathymetry data found');
end

%% determine profile change

dz  = zb(end,:)-zb(1,:);

notnan = ~isnan(dz);
x  = x(notnan);
dz = dz(notnan);

%% determine active profile

% total profile change
At = abs(trapz(x,abs(dz)));

% maximum profile change
i1 = max(find(dz==max(dz),1,'first')-1,1);
i2 = min(i1+2,length(x));

A = 0; n = 0;
while A/At<OPT.dzfrac && length(x)>n
    A = abs(trapz(x(i1:i2),abs(dz(i1:i2))));
    
    i1n = max(i1-1,1);
    i2n = min(i2+1,length(x));
    
    A1 = abs(trapz(x(i1n:i2),abs(dz(i1n:i2))));
    A2 = abs(trapz(x(i1:i2n),abs(dz(i1:i2n))));
    
    if A1>A2
        i1 = i1n;
    else
        i2 = i2n;
    end
    
    n = n + 1;
end

%% prepare output

ix = [i1 i2];
try
    [x i] = sort(x(ix));
    ix = ix(i);
end
