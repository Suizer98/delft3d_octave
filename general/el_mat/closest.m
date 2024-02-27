function [xc ic] = closest(x,y,varargin)
%CLOSEST  Returns values in y closest to values in x
%
%   Returns values in y closest to values in x. Result is a scalar, vector
%   or matrix with the size of x and values of y.
%
%   Syntax:
%   [xc ic] = closest(x, y)
%
%   Input:
%   x         = Values to be searched
%   y         = Values to be searched in
%
%   Output:
%   xc        = Values from y closest to x
%   ic        = Indices in y of values closest to x
%
%   Example
%   x = closest(x,y)
%   [x i] = closest(x,y)
%
%   See also far_away

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
% Created: 18 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: closest.m 13914 2017-11-09 13:58:46Z scheel $
% $Date: 2017-11-09 21:58:46 +0800 (Thu, 09 Nov 2017) $
% $Author: scheel $
% $Revision: 13914 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/closest.m $
% $Keywords: $

%% find closest

if ~isempty(varargin)
    flip = true;
else
    flip = false;
end

xc = nan(size(x));
ic = nan(size(x));

for i = 1:numel(x)
    [m mi]  = min(abs(y(:) - x(i)));
    
    if flip
        ic(i)   = y(mi);
        xc(i)   = mi;
    else
        xc(i)   = y(mi);
        ic(i)   = mi;
    end
end
