function [crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi)
%GRID_ORTH_GETDATAONLINE Linearly interpolates Z values for all crossings of a grid and a line 
%
%   [crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi)
%
% X and Y are expected to be created with meshgrid or similar. 
% Orthogonal as well as Curvi-linear grids are supported
% 
% xi and yi are vectors that contain the end and start point of a
% linesegment. polygons are not supported (must be given piecewise)
%
% crossing_* contain all intersections of the lines with the grid X and Y.
%
% See also: grid_orth_getFixedMapOutlines, grid_orth_createFixedMapsOnAxes,
%           grid_orth_identifyWhichMapsAreInPolygon, grid_orth_getDataFromNetCDFGrid
%           nc_cf_gridset_getData, poly_fun, arbcross (from delft3d)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_getDataOnLine.m 4770 2011-07-06 14:53:29Z boer_g $
% $Date: 2011-07-06 22:53:29 +0800 (Wed, 06 Jul 2011) $
% $Author: boer_g $
% $Revision: 4770 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getDataOnLine.m $
% $Keywords: $

%% input

if mean(nanmean(diff(X,[],2)))<0;
    X = fliplr(X);
    Y = fliplr(Y);
    if length(size(Z))==3
        Z = Z(:,end:-1:1,:);
    else
        Z = fliplr(Z);
    end
end

if mean(nanmean(diff(Y,[],1)))<0;
    X = flipud(X);
    Y = flipud(Y);
    if length(size(Z))==3
        Z = Z(end:-1:1,:,:);
    else
        Z = flipud(Z);
    end
end

if xor(xi(1)>xi(2),yi(1)>yi(2))
    xi      = xi([2 1]);
    yi      = yi([2 1]);
    reverse = true;
else
    reverse = false;
end

dx_max = max(diff(X(1,:)));
dy_max = max(diff(Y(:,1)));

%% crop area to search for crossings to line
temp = ...
    X>=min(xi)-dx_max&X<=max(xi)+dx_max&...
    Y>=min(yi)-dy_max&Y<=max(yi)+dy_max;
mm   = max([1 find(any(temp,2),1,'first')-2]):1:min([size(X,1) find(any(temp,2),1,'last')+2]);
nn   = max([1 find(any(temp,1),1,'first')-2]):1:min([size(X,2) find(any(temp,1),1,'last')+2]);

%% lengthen search line
dx               = xi(2) - xi(1);
dy               = yi(2) - yi(1);
lengthen_factor  = min(dy_max / abs(dy), dx_max / abs(dx))*1.1;
xi2              = xi + [-dx dx]*lengthen_factor;
yi2              = yi + [-dy dy]*lengthen_factor;

%% pre allocate
crossing_x = nan(numel(mm)+numel(nn),1);
crossing_y = nan(numel(mm)+numel(nn),1);
crossing_z = nan(numel(mm)+numel(nn),size(Z,3));

jj = 0;

%% find all locations of crossings with rows
for ii = mm
    P = InterX([X(ii,nn);Y(ii,nn)],[xi2;yi2]);
    if ~isempty(P)
        jj = jj+1;
        crossing_x(jj) = P(1,1);
        crossing_y(jj) = P(2,1);
        a = find(X(ii,:)<=crossing_x(jj),1, 'last');
        b = find(X(ii,:)>=crossing_x(jj),1,'first');
        if a~=b
            c = (crossing_x(jj) - X(ii,a))/(X(ii,b) - X(ii,a));
        else
            c = 1;
        end
        if length(size(Z))==3
            crossing_z(jj,:) = Z(ii,a,:) * (1-c) + Z(ii,b,:) * c;
        else
            crossing_z(jj  ) = Z(ii,a  ) * (1-c) + Z(ii,b  ) * c;
        end
    end
end

%% find all locations of crossings with columns
for ii = nn
    P = InterX([X(mm,ii)';Y(mm,ii)'],[xi2;yi2]);
    if ~isempty(P)
        jj = jj+1;
        crossing_x(jj) = P(1,1);
        crossing_y(jj) = P(2,1);
        a = find(Y(:,ii)<=crossing_y(jj),1, 'last');
        b = find(Y(:,ii)>=crossing_y(jj),1,'first');
        if a~=b
            c = (crossing_y(jj) - Y(a,ii))/(Y(b,ii) - Y(a,ii));
        else
            c = 1;
        end
        if length(size(Z))==3
            crossing_z(jj,:) = Z(a,ii,:) * (1-c) + Z(b,ii,:) * c;
        else
            crossing_z(jj  ) = Z(a,ii  ) * (1-c) + Z(b,ii  ) * c;
        end
        
    end
end

%% delete nan data
if length(size(Z))==3
    crossing_z(isnan(crossing_x),:) = [];
else
    crossing_z(isnan(crossing_x)) = [];
end
crossing_y(isnan(crossing_x)) = [];
crossing_x(isnan(crossing_x)) = [];

%% find end points of crossings
%  determine the nearest crossings on the extended parts of the line at the
%  begin (1) and end (2), store them in crossing_x1 and crossing_x2 etc
crossing_d = ((crossing_x - xi(1)).^2 + (crossing_y-yi(1)).^2).^.5;
if dx>dy
    i1          = find(crossing_x<=min(xi));
    [dummy, b] = min(crossing_d(i1));
    i1          = i1(b);
else
    i1          = find(crossing_y<=min(yi));
    [dummy, b] = min(crossing_d(i1));
    i1          = i1(b);
end

crossing_x1 =  crossing_x(i1);
crossing_y1 =  crossing_y(i1);
crossing_d1 = -crossing_d(i1);
if length(size(Z))==3
    crossing_z1 =  crossing_z(i1,:);
else
    crossing_z1 =  crossing_z(i1);
end

if dx>dy
    i2 = find(crossing_x>=max(xi));
    [dummy, b]  = min(crossing_d(i2));
    i2 = i2(b);
else
    i2 = find(crossing_y>=max(yi));
    [dummy, b]  = min(crossing_d(i2));
    i2 = i2(b);
end

crossing_x2 =  crossing_x(i2);
crossing_y2 =  crossing_y(i2);
crossing_d2 =  crossing_d(i2);
if length(size(Z))==3
    crossing_z2 =  crossing_z(i2,:);
else
    crossing_z2 =  crossing_z(i2);
end

%% sort the crossings by distance
%  find the 'body' of the crossings, the final line will be 
%  [startpoint body endpoint]. The start and enpoints are linearly
%  interpolated between the edges of the body, and the crossing_x1 and
%  crossing_x2 points

[dummy,ind] = sort(crossing_d);

if dx>dy
    ind = ind(crossing_x(ind)>min(xi)&crossing_x(ind)<max(xi));
else
    ind = ind(crossing_y(ind)>min(yi)&crossing_y(ind)<max(yi));
end

if ~isempty(crossing_x1) && ~(isempty(i2)&&isempty(ind))
    if isempty(ind)
        ii = i2;
    else
        ii = ind(1);
    end
    if dx>dy
        a = (crossing_x(ii) - min(xi))/(crossing_x(ii) - crossing_x1);
    else
        a = (crossing_y(ii) - min(yi))/(crossing_y(ii) - crossing_y1);
    end
    crossing_x1 = crossing_x1*a + crossing_x(ii)*(1-a);
    crossing_y1 = crossing_y1*a + crossing_y(ii)*(1-a);
    crossing_d1 = 0;
    if length(size(Z))==3
        crossing_z1 = crossing_z1*a + crossing_z(ii,:)*(1-a);
    else
        crossing_z1 = crossing_z1*a + crossing_z(ii  )*(1-a);
    end
end


if ~isempty(crossing_x2) && ~(isempty(i1)&&isempty(ind))
    if isempty(ind)
        ii = i1;
    else
        ii = ind(end);
    end
    if dx>dy
        a = (crossing_x(ii) - max(xi))/(crossing_x(ii) - crossing_x2);
    else
        a = (crossing_y(ii) - max(yi))/(crossing_y(ii) - crossing_y2);
    end
    crossing_x2 = crossing_x2*a + crossing_x(ii)*(1-a);
    crossing_y2 = crossing_y2*a + crossing_y(ii)*(1-a);
    crossing_d2 = ((xi(2) - xi(1)).^2 + (yi(2)-yi(1)).^2)^.5;
    if length(size(Z))==3
        crossing_z1 = crossing_z1*a + crossing_z(ii,:)*(1-a);
    else
        crossing_z2 = crossing_z2*a + crossing_z(ii  )*(1-a);
    end
end

crossing_x    =[crossing_x1; crossing_x(ind); crossing_x2];
crossing_y    =[crossing_y1; crossing_y(ind); crossing_y2];
crossing_d    =[crossing_d1; crossing_d(ind); crossing_d2];

if length(size(Z))==3
    crossing_z    =[crossing_z1; crossing_z(ind,:); crossing_z2];
else
    crossing_z    =[crossing_z1; crossing_z(ind  ); crossing_z2];
end

if reverse
    crossing_x = flipud(crossing_x);
    crossing_y = flipud(crossing_y);
    crossing_d = ((crossing_x - xi(2)).^2 + (crossing_y-yi(2)).^2).^.5;
    if length(size(Z))==3
        crossing_z = crossing_z(end:-1:1,:);
    else
        crossing_z = flipud(crossing_z);
    end
end

%% delete nan data
if length(size(Z))==3
    crossing_z(isnan(crossing_x),:) = [];
else
    crossing_z(isnan(crossing_x)  ) = [];
end
crossing_y(isnan(crossing_x)) = [];
crossing_x(isnan(crossing_x)) = [];
