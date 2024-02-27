function [tri,x1,y1,z1] = delaunay_simplified(x,y,z,tolerance,varargin)
% DELAUNAY_SIMPLIFIED makes a simplified delaunay triangulated mesh
%
%   [tri,x1,y1,z1] = delaunay_simplified(x,y,z,tolerance,<keyword,value>)
% 
% creates meshes that resemble a more complex mesh to a certain
% degree, specified by tolerance, the maximum error that may exist
% between the final grid and the original datapoints.
%
% All NaN edges within the grid are used in triangulation, but no 
% triangles are created where NaN's are available.   
%
% The script is does not find an optimum solution, but works well 
% enough in reducing triangles.
%
% Example1
%
%   % some input
%     [lat,lon] = meshgrid(54:.1:57,2:.1:5);
%     z = peaks(31); z = abs(z);  z(z<1) = nan;
%    
%   % call function
%     h1 = subplot(2,1,1);
%       tolerance = .5;
%       tri1 = delaunay_simplified(lat,lon,z,tolerance);
%       trisurf(tri1,lat,lon,z);
%     h2 = subplot(2,1,2);
%       tri2 = delaunay(lat,lon);
%       trisurf(tri2,lat,lon,z);
%
% Example2 (play with different values for tolerance:
%   % data from netCDF
%     url = vaklodingen_url; url = url{127};
%     x = nc_varget(url,'x');
%     y = nc_varget(url,'y');
%     z = nc_varget(url,'z',[0,0,0],[1,-1,-1]);
%     [x,y] = meshgrid(x,y);
%

%     disp(['elements: ' num2str(sum(~isnan(z(:))))]);
%     tolerance = .5; 
%     tri = delaunay_simplified(x,y,z,tolerance,'maxSize',10000);
%     [lon,lat] = convertCoordinates(x,y,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
%     z= (z+15)*2;
%   % plot in Google Earth
%     KMLtrisurf(tri,lat,lon,z)
%   
% See also: delaunay, trisurf, KMLtrisurf 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% $Id: delaunay_simplified.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/delaunay_simplified.m $
% $Keywords: $

%%

%% process varargin

OPT.maxSize       = 1000;
OPT.maxIterations = 100;

[OPT, Set, Default] = setproperty(OPT, varargin);

%% find convex hull of not nan z values

A = ~isnan(z);
%left
Aleft = [A(:,2:end) false(size(A,1),1)];
%right
Aright = [false(size(A,1),1) A(:,1:end-1)];
% up
Aup = [ A(2:end,:);false(1,size(A,2))];
% down
Adown = [false(1,size(A,2));A(1:end-1,:)];

A = A|Aleft|Aright|Aup|Adown;
nans = isnan(z);
ind = find(isnan(z)&A);
z(nans) = ceil(max(z(:))+2*tolerance+15);

%% assign start values

ind = [ind; convhull(x,y)];

ind = unique(ind);

%% iteration
fault     = inf;
iteration = 0;
tri2      = 0;
while fault>tolerance && size(tri2,1)<OPT.maxSize && iteration<OPT.maxIterations
    iteration = iteration+1;
    % Triangulate the data
    try
        tri2 = delaunayn([x(ind) y(ind)]);
    catch
        tri2 = delaunayn([x(ind) y(ind)],{'QJ','Pp'});
    end
   
    % Find the nearest triangle (t)
    t = tsearch(x(ind),y(ind),tri2,x,y);
        % Only keep the relevant triangles.
     out = find(isnan(t));
     if ~isempty(out), t(out) = ones(size(out)); end
    tri = tri2(t(:),:);
    tri = ind(tri);
    % Compute Barycentric coordinates (w).  P. 78 in Watson.
    del = (x(tri(:,2))-x(tri(:,1))) .* (y(tri(:,3))-y(tri(:,1))) - ...
        (x(tri(:,3))-x(tri(:,1))) .* (y(tri(:,2))-y(tri(:,1)));
    w(:,3) = ((x(tri(:,1))-x(:)).*(y(tri(:,2))-y(:)) - (x(tri(:,2))-x(:)).*(y(tri(:,1))-y(:))) ./ del;
    w(:,2) = ((x(tri(:,3))-x(:)).*(y(tri(:,1))-y(:)) - (x(tri(:,1))-x(:)).*(y(tri(:,3))-y(:))) ./ del;
    w(:,1) = ((x(tri(:,2))-x(:)).*(y(tri(:,3))-y(:)) - (x(tri(:,3))-x(:)).*(y(tri(:,2))-y(:))) ./ del;
    w(out,:) = zeros(length(out),3);
    z3 = z(ind).'; % Treat z as a row so that code below involving
    % z(tri) works even when tri is 1-by-3.
    z2 = sum(z3(tri2(t,:)) .* w,2);
    
    % find triangles that need to be refined.

    fault = z(:)-z2;
%     t_unique = unique(t(error>tolerance));

    
    temp = 0.1/ceil(max(abs(fault)));
    M = t(:)+fault*temp;
    [M,ind2] = sort(M);
    addInd   = ind2([true;diff(M)>.3]|[diff(M)>.3;true]) ;
    addInd   = addInd(abs(fault(addInd))>tolerance);
    %add newCoords
    ind      = unique([ind; addInd]);

    [fault,ind2] = max(abs(fault(~nans)));
  
    disp(sprintf('iteration: % 3d  Number of triangles:% 6d  error = % 6.2f at index % 4d',...
        iteration,size(tri2,1),fault,ind2));
        
end

tri  = delaunay(x(ind),y(ind));
%% find triangles with nan values inside
ind2 = ismember(tri,find(z(ind)==max(z(:))));
ind2 = any(ind2,2);

%% delete triangles with nan values
tri(ind2,:) = [];

if nargout == 1
    tri     = ind(tri);
elseif nargout==4
    x1      = x(ind);
    y1      = y(ind);
    z(nans) = nan;
    z1      = z(ind);
    
else
    error('nargout must be 1 or 4');
end

disp(sprintf('Completed,  % 6d triangles created',...
        size(tri,1)));

