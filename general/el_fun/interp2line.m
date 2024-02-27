function [zc xc yc d] = interp2line(x, y, z, x0, y0, varargin)
%INTERP2LINE  Interpolates on a 3D line using the closest point on the line
%
%   Determines the point closest to a given point on the given curve. Then
%   find the z-value of that point by linear interpolation.
%
%   Syntax:
%   [zc xc yc d] = interp2line(x, y, z, x0, y0, varargin)
%
%   Input:
%   x           = x-coordinates of line
%   y           = y-coordinates of line
%   z           = z-coordinates of line
%   x0          = x-coordinate of point
%   y0          = y-coordinate of point
%   varargin    = plot:     boolean to determine whether result should be
%                           plotted or not
%
%   Output:
%   zc          = z-coordinate of interpolation point on line
%   xc          = x-coordinate of interpolation point on line
%   yc          = y-coordinate of interpolation point on line
%   d           = distance from given point to interpolation point on line
%
%   Example
%   z0 = interp2line(x,y,z,x0,y0);
%   z0 = interp2line(x,y,z,x0,y0,'plot',true);
%   [zc xc yc d] = interp2line(x,y,z,x0,y0);
%
%   See also interp1 interp2

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 27 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: interp2line.m 3765 2010-12-29 14:38:29Z hoonhout $
% $Date: 2010-12-29 22:38:29 +0800 (Wed, 29 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3765 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/interp2line.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'plot', false ...
);

OPT = setproperty(OPT, varargin{:});

%% check input

if ~isvector(x) || ~isvector(y) || ~isvector(z)
    error('Input should be all vectors');
end

if size(x,1) > size(x,2); x = x'; end;
if size(y,1) > size(y,2); y = y'; end;
if size(z,1) > size(z,2); z = z'; end;

%% determine nearest point

dims = [2 1 length(x)-1];

% determine line segments
P0 = reshape([x0 ; y0]*ones(1, length(x)-1), dims);
P1 = reshape([x(1:end-1) ; y(1:end-1)], dims);
P2 = reshape([x(2:end) ; y(2:end)], dims);

% find perpendicular crossings with line segments
R = (   ones(2,1)*squeeze(dot(P0-P2, P1-P2))' .* squeeze(P1) + ...
        ones(2,1)*squeeze(dot(P0-P1, P2-P1))' .* squeeze(P2)  ) ./ ...
        (ones(2,1)*squeeze(dot(P2-P1, P2-P1))');

% determine length of segments and relative location of crossings
L0 = sqrt(sum((squeeze(P1)-squeeze(P2)).^2));
L1 = sqrt(sum((squeeze(P1)-R).^2));
L2 = sqrt(sum((squeeze(P2)-R).^2));
L = L1 + L2;

% find crossings that are within segments
idx = find(abs(L - L0) < 1e-10);

if isempty(idx)
    % no perpendicular point found, take closest known point
    d = sqrt(sum(([x ; y]-[x0 ; y0]*ones(1, length(x))).^2));
    idx = find(d == min(d), 1);
    
    d = d(idx);
    xc = x(idx);
    yc = y(idx);
    zc = z(idx);
else
    d = sqrt(sum((squeeze(P0)-R).^2));
    
    if length(idx) > 1
        idx = idx(find(d(idx) == min(d(idx)), 1));
    end
    
    d = d(idx);
    xc = R(1,idx);
    yc = R(2,idx);
    zc = z(idx)*L2(idx)/L(idx)+z(idx+1)*L1(idx)/L(idx);
end

%% plot

if OPT.plot
    figure; hold on;
    plot3(x,y,z,'-or');
    plot3(x,y,0*z,'-ok');
    plot3([x0 xc],[y0 yc],[0 0],'-ob');
    plot3([xc xc],[yc yc],[0 zc],'-og');
    grid on; box on;
    view(30,30);
end