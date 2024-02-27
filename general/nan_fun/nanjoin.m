function x_combined = nanjoin(x,dim)
%NANJOIN Join cells with arrays with nans as separator
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nanjoin(varargin)
%
%   Input: For <keyword,value> pairs call nanjoin() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nanjoin
%
%   See also: nansplit

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       TDA
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 06 Jun 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nanjoin.m 10341 2014-03-06 15:50:24Z tda.x $
% $Date: 2014-03-06 23:50:24 +0800 (Thu, 06 Mar 2014) $
% $Author: tda.x $
% $Revision: 10341 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/nan_fun/nanjoin.m $
% $Keywords: $

%%
assert(iscell(x),'Expected input to be a cell array')

% remove empty entries
x(cellfun(@isempty,x)) = [];

% input check
m = size(x{1},dim);
assert(all(cellfun(@(x) size(x,dim),x)==m));
assert(all(cellfun(@isfloat,x)));

% determine other dimension
if dim == 1
    dim2 = 2;
elseif dim==2
    dim2 = 1;
end

n = sum(cellfun(@(x) size(x,dim2),x)) + numel(x) - 1;

if dim == 1
    x_combined = nan(m,n);
elseif dim == 2
    x_combined = nan(n,m);
end

i1 = 1;
for ii = 1:length(x);
    i2 = i1+size(x{ii},dim2)-1;
    if dim==1
        x_combined(:,i1:i2) = x{ii};
    else
        x_combined(i1:i2,:) = x{ii};
    end
    i1 = i2+2;
end
