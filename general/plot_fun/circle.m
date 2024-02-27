function h = circle(x,y,r,varargin)
%CIRCLE plots a circle with centre at [x,y] and radius r.
%
% Plots a circle on current axes, with the centre at position (x,y) and
% radius r.
% Circle uses PLOT and accepts property value pairs. By default gca is
% used, other axes can be assigned.
%
%   Syntax:
%     handle = circle(x,y,r,varargin);
%     handle = circle(ax,x,y,r,varargin);
%
%   Input:
%     x: vector with centre x-coordinates
%     y: vector with centre y-coordinates
%     r: vector with radii (or scalar)
%     varargin: see plot.
%
%   Output:
%     h = plot handle
%
%   Example
%     figure;
%     h=circle(1:10,rand(1,10),1);
%
% See also: PLOT.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 TU Delft
%       Bart Roest
%
%       l.w.m.roest@tudelft.nl
%
%       Stevinweg 1
%       2628CN Delft
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
% Created: 13 Jul 2018
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: circle.m 16285 2020-03-04 13:08:21Z l.w.m.roest.x $
% $Date: 2020-03-04 21:08:21 +0800 (Wed, 04 Mar 2020) $
% $Author: l.w.m.roest.x $
% $Revision: 16285 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/circle.m $
% $Keywords: $

%%
%OPT.keyword=value;
% return defaults (aka introspection)
%if nargin==0;
%    varargout = {OPT};
%    return
%else
%% Input check
if isobject(x);%ishandle(x);
    ax=x(:);
    x=y(:);
    y=r(:);
    r=varargin{1};
    if length(varargin)>1
        varargin=varargin(2:end);
    else
        varargin=[];
    end
else
    ax=gca;
    x=x(:);
    y=y(:);
    r=r(:);
end

if size(x)~=size(y)
    error('x and y must be the same size');
elseif any(size(r)~=size(x)) && ~isscalar(r)
    error('r must be of size(x) or scalar');
end

if isscalar(r)
    r=repmat(r,size(x));
end

% overwrite defaults with user arguments
%OPT = setproperty(OPT, varargin);
%% code
hold on
th = 0:pi/50:2*pi;
for n=1:length(x);
    xunit = r(n) * cos(th) + x(n);
    yunit = r(n) * sin(th) + y(n);
    if nargout==0;
        if isempty(varargin);
            plot(ax, xunit, yunit);
        else
            plot(ax, xunit, yunit, varargin{:});
        end
    else
        if isempty(varargin);
            h(n) = plot(ax, xunit, yunit);
        else
            h(n) = plot(ax, xunit, yunit, varargin{:});
        end
    end
end
hold off
%EOF