function varargout = reduce(x,y,tolerance,maximum_nr_of_points)
%REDUCE  Iteratively reduce density of points in vector data
%
% Reduce a set of x,y points by linearizing over a subset,
% and iteratively adding the point with largest error to
% the subset, as in the Ramer–Douglas–Peucker algorithm
% but with only y distance as critrion
% 
% Routine continues until either tolerance criterion
% or maximum_nr_of_points criterion is met
% 
% The calling syntax is either:
%
%		[indices,max_error]                     = reduce(x,y,tolerance,max nr of points)
%       [reduced_x,reduced_y,indices,max_error] = reduce(x,y,tolerance,max nr of points)
%
%   Input:
%       x           	  =  sorted vector
%       y                 =  vector of size(x)
%       tolerance         =  scalar
%       max nr of points  =  scalar
%
%   Output:
%       indices           = indices of the points in y and y needed to
%                           fullfill the maximum_nr_of_points and/or tolerance criterion
%
%
%
%   See also: running_median_filter
%   Example_code:
%{

% generate some data
x = (1:5000)';
y = 2*sind(x) + 3*sind(x/2) + 4*sind(x/3);

subplot(3,2,1)
max_nr_of_points = 10;
[ind,max_error]= reduce(x,y,0,max_nr_of_points);
plot(x,y,x(ind),y(ind),x(ind),[y(ind)+max_error y(ind)-max_error],'r:')
title(sprintf('max points set at %d ==> max error %.1f',length(ind),max_error))

subplot(3,2,3)
max_nr_of_points = 15;
[ind,max_error]= reduce(x,y,0,max_nr_of_points);
plot(x,y,x(ind),y(ind),x(ind),[y(ind)+max_error y(ind)-max_error],'r:')
title(sprintf('max points set at %d ==> max error %.1f',length(ind),max_error))

subplot(3,2,5)
max_nr_of_points = 250;
[ind,max_error]= reduce(x,y,0,max_nr_of_points);
plot(x,y,x(ind),y(ind),x(ind),[y(ind)+max_error y(ind)-max_error],'r:')
title(sprintf('max points set at %d ==> max error %.1f',length(ind),max_error))

subplot(3,2,2)
tolerance = 5;
[ind,max_error]= reduce(x,y,tolerance,length(x));
plot(x,y,x(ind),y(ind),x(ind),[y(ind)+max_error y(ind)-max_error],'r:')
title(sprintf('tolerance set at %.1f ==> %d points needed',tolerance,length(ind)))

subplot(3,2,4)
tolerance = 3;
[ind,max_error]= reduce(x,y,tolerance,length(x));
plot(x,y,x(ind),y(ind),x(ind),[y(ind)+max_error y(ind)-max_error],'r:')
title(sprintf('tolerance set at %.1f ==> %d points needed',tolerance,length(ind)))

subplot(3,2,6)
tolerance = 0.1;
[ind,max_error]= reduce(x,y,tolerance,length(x));
plot(x,y,x(ind),y(ind),x(ind),[y(ind)+max_error y(ind)-max_error],'r:')
title(sprintf('tolerance set at %.1f ==> %d points needed',tolerance,length(ind)))

%}

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 19 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: reduce.m 11294 2014-10-24 14:14:49Z gerben.deboer.x $
% $Date: 2014-10-24 22:14:49 +0800 (Fri, 24 Oct 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11294 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/reduce.m $
% $Keywords: $

%% input check
assert(~isempty(x),'x is empty');
assert(isvector(x),'x is not a vector');
assert(isvector(y),'y is not a vector');
assert(isequal(size(x),size(y)),'x and y are not equal in size');
assert(issorted(x),'x is not sorted');
narginchk(3,4);
assert(~any(isnan(x)),'there are nan''s in x');
assert(~any(isnan(y)),'there are nan''s in y');
assert(~any(isinf(x)),'there are inf''s in x');
assert(~any(isinf(y)),'there are inf''s in y');
assert(isscalar(tolerance),'tolerance is not a scalar');
assert(isscalar(maximum_nr_of_points),'maximum_nr_of_points is not a scalar');

% also allow three inputs
if nargin==3
    maximum_nr_of_points = length(x);
end
assert(isscalar(maximum_nr_of_points));
assert(maximum_nr_of_points>0);
assert(~isinf(maximum_nr_of_points),'maximum_nr_of_points is inf');
assert(~isnan(maximum_nr_of_points),'maximum_nr_of_points is nan');
%% call mex function
[indices,max_error,starts,ends,max_err_locs,max_err_vals] = reduce(double(x),double(y),double(tolerance),uint32(maximum_nr_of_points)); %#ok<ASGLU,NASGU>

%% prepare output
if nargout == 2
    varargout = {indices,max_error};
else
   varargout = {x(indices),y(indices),indices,max_error}; 
end