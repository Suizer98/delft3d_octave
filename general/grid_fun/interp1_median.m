function vi = interp1_median(x,v,xi)
%INTERP1_MEDIAN  Interpolates to median value of data points nearest to xi.
%
%   INTERP1_MEDIAN interpolates values v at positions x to interpolation
%   positions xi based on the nearest-neighbour principle. The median value
%   is taken over all points x that are nearest to xi, ignoring nan's.
%   If there are no values closest to xi(n), interp1_median returns a nan in
%   vi(n).
%
%   This routine is especially useful when downsampling.
%   E.g. length(x) >> length(xi).
%
%   Syntax:
%   vi = interp1_median(x,v,xi)
%
%   Input:
%       x: vector of positions.
%       v: vector of values.
%       xi: vector of interpolation positions.
%
%   Output:
%       vi: vector of interpolated values.
%
%   Example:
%   x=rand(50,1); v=x.^2; xi=[0:0.1:1];
%   vi=interp1_median(x,v,xi);
%   figure; plot(x,v,'.r',xi,vi,'.-k');
%
%   See also: interp1, interp1_mean, griddata_average

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be
%       l.w.m.roest@tudelft.nl
%
%       Spoorwegstraat 12
%       8200 Bruges
%       Belgium
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
% Created: 07 Jun 2019
% Created with Matlab version: 9.5.0.1067069 (R2018b) Update 4

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

% % %%
% % OPT.keyword=value;
% % % return defaults (aka introspection)
% % if nargin==0;
% %     varargout = {OPT};
% %     return
% % end
% % % overwrite defaults with user arguments
% % OPT = setproperty(OPT, varargin);
%% Input Checks
%Check input arguments. Must be vectors.
if ~isvector(x) || ~isvector(v) || ~isvector(xi)
    error('All input arguments must be vectors.');
end

%Check for equal size of x and v.
if size(x)~=size(v)
    error('x and v must be sized equally.');
end

%Check for increasing x-values.
if ~issorted(x,'strictascend')
    [x,idx] = sort(x,'ascend');
    v = v(idx);
end

%% Interpolation
%Determine boundaries between xi-points. Based on nearest neighbor.
xb=center2corner1(xi);

%Pre-allocate vi
vi=nan(size(xi));
% if nargout>1;
%     st=struct([]);
% end

%Determine median value for points closest to xi
for n=1:length(xi)
    mask= x>=xb(n) & x<xb(n+1);
    vi(n)=median(v(mask),'omitnan');
%     if nargout>1
%         st(n)=allstats(v(mask));
%     end
end
