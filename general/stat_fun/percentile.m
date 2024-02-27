function val = percentile(x, pct)
%PERCENTILE  find the percentile values
%
%   Returns the value of <x> for which <pct>% is smaller and 100 - <pct>%
%   is larger
%
%   Syntax:
%   val = percentile(x, pct)
%
%   Input:
%   x   = data values (can be a matrix)
%   pct = percentile values (can be a vector)
%
%   Output:
%   val = percentile values 
%
%   Example
%     x    = rand(100000,7)*100;
%     pct  = [21 50 75];
%     val  = percentile(x,pct)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com	
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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

% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: percentile.m 8927 2013-07-22 15:58:39Z tda.x $
% $Date: 2013-07-22 23:58:39 +0800 (Mon, 22 Jul 2013) $
% $Author: tda.x $
% $Revision: 8927 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/percentile.m $
% $Keywords: $

%% input check
assert(~any(isnan(x(:))),'Percentile function cannot handle NANs, filter them first')

%% run functions
% sort x
x   = sort(x);

% vectorize pct
pct = pct(:);

% match indices with percentiles
ind = (size(x,1)*(pct/100))+1.5;

% lengthen x
x   = x([1 1:end end],:);

% find interpolation factors a and b
a   = ceil(ind) - ind;
b   = 1-a;

% calculate output values
val = x(floor(ind),:).*repmat(a,1,size(x,2)) + x(ceil(ind),:).*repmat(b,1,size(x,2));
