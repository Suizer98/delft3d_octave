function [distance,xD,yD,segmentInd,type] = distance_from_polyline(x,y,xv,yv)
%DISTANCE_FROM_POLYLINE calculates the shortest distance of a coordinate to a (poly)line
%
%   More detailed description goes here.
%
%   Syntax:
%   [distance,xD,yD,segmentInd,type] = distance_from_polyline(x,y,xv,yv)
%
%   Input: For <keyword,value> pairs call DISTANCE_FROM_POLYLINE() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%     %% Example 1
%     x = [2 2 5];
%     y = [10 4 4];
%     xv = 10*rand(10);
%     yv = 10*rand(10);
%     plot(x,y,'r-',xv,yv,'bx')
% 
%     [dist,xD,yD] = geometry.distance_from_polyline(x,y,xv,yv);
%     plot(x,y,'k','lineWidth',3)
%     hold on 
%     plot([xv(:) xD(:)]',[yv(:) yD(:)]')
%
%     %% Example 2
%     poly.x = [3.9977 3.9055 4.2281 5.1959 5.9793 6.3479 6.6244 0.6106 0.9332 2.2696 3.2604];
%     poly.y = [2.2953 5.1901 5.5994 5.6579 5.3070 5.0146 7.0322 9.0205 8.4942 8.2310 9.0789];
%       
%     [xv,yv] = meshgrid(0:.2:10,0:.2:10);
%     [dist,xD,yD] = geometry.distance_from_polyline(poly.x,poly.y,xv,yv);
%     plot(poly.x,poly.y,'k','lineWidth',3)
%     hold on 
%     plot(xv,yv,'r.')
%     plot([xv(:) xD(:)]',[yv(:) yD(:)]','b')
%     contour(xv,yv,-dist,10)
%     axis equal
%
%   See also: pointTOline

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
% Created: 28 Sep 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: distance_from_polyline.m 8587 2013-05-07 13:31:25Z tda.x $
% $Date: 2013-05-07 21:31:25 +0800 (Tue, 07 May 2013) $
% $Author: tda.x $
% $Revision: 8587 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+geometry/distance_from_polyline.m $
% $Keywords: $

%% input check
assert(isequal(size(x),size(y)));
if iscolumn(x)
    x = x';
    y = y';
end
assert(isvector(x),'x and y should be vectors')

% split line into line segments
A = [x(1:end-1); y(1:end-1)]';
B = [x(2:end-0); y(2:end-0)]';

% remove line parts with nan's
nn = isnan(A)&~isnan(B);
A(nn) = B(nn);

nn = isnan(B)&~isnan(A);
B(nn) = A(nn);

% define anonymous functions for algorithm
% http://www.topcoder.com/tc?d1=tutorials&d2=geometry1&module=Static#line_point_distance
vcross        = @(A,B,nn) A(nn,1).*B(nn,2) - A(nn,2).*B(nn,1);
vdot          = @(A,B,nn) A(nn,1).*B(nn,1) + A(nn,2).*B(nn,2);

% loop through every individual point
[distance,xD,yD,segmentInd,type] = deal(nan(size(xv)));
for ii = 1:numel(xv)
    % A: line segment start coordinate (vectorized)
    % B: line segment end   coordinate (vectorized)
    % C: point of interest (not vecorized)
    % D: closest point to C on line AB
    C             = [xv(ii),yv(ii)];
    C             = C(ones(size(A,1),1),:);
    dist2         = nan(size(A,1),1);
    typ           = uint8(zeros(size(A,1),1));
    
    % Case1: D = B
    mm            = find(typ == 0);
    dot1          = vdot((C-B),(B-A),mm);
    % when dot1 < 0 the projection of C on line AB is before point B, so B-C is
    % greater than AB-C or A-C
    nn            = dot1>=0;
    dist2(mm(nn)) = vdot((B-C),(B-C),mm(nn));
    typ(mm(nn))  = 1;
    
    % Case2: D = A
    mm            = find(typ == 0);
    dot2          = vdot((C-A),(A-B),mm);
    % when dot2 < 0 the projection of C on line AB after point A, so A-C is
    % greater than AB-C or A-C
    nn            = dot2>=0;
    dist2(mm(nn)) = vdot((A-C),(A-C),mm(nn));
    typ(mm(nn))  = 2;
    
    % Case3: D is on line AB
    nn            = find(typ == 0);
    dist2(nn)     = vcross((B-A),(C-A),nn).^2 ./ vdot((B-A),(B-A),nn);
    typ((nn))    = 3;
    
    % find the nearest linesegment
    [dist2,ind]  = min(dist2);
    
    distance(ii)  = sqrt(dist2);
    typ           = typ(ind);
    
    switch typ 
        case 1
            D    = B(ind,:);
        case 2
            D    = A(ind,:);
        case 3
            % 
            AC2 = (A(ind,1) - C(ind,1))^2 + (A(ind,2) - C(ind,2))^2;
            AD  = sqrt(AC2 - dist2);
            AB  = sqrt((A(ind,1) - B(ind,1))^2 + (A(ind,2) - B(ind,2))^2);
            D   = A(ind,:) + (B(ind,:)-A(ind,:)) * (AD / AB);
    end
    xD(ii) = D(1);
    yD(ii) = D(2);
    segmentInd(ii) = ind;
    type(ii) = typ;
end
