function varargout = voxel(varargin)
%VOXEL  Plots volumetric data
%
%   More detailed description goes here.
%
%   Syntax:
%       varargout = voxel(varargin)
%
%   Input:
%       varargin  = p,<keyword>,<value> 
%       varargin  = x,y,z,p,<keyword>,<value>
%
%       p:
%           either a double or logical
%           if p is a logical, only the true boxes are plotted, all in the same color
%           if p is a double, all not-nan values are plotted, coloured according to their value
%           
%       x,y,z: 
%              1d vectors where: 
%           size(p)   == [length(y),length(x),length(z)] (center coordinates)
%              1d vectors where: 
%           size(p)+1 == [length(y),length(x),length(z)] (corner coordinates)
%              3d vectors where:
%           size(p)   == size(x) == size(y) == size(z) (center coordinates)
%              3d vectors where:
%           size(p)+1 == size(x) == size(y) == size(z) (corner coordinates)
%
%   Output:
%       varargout = [handle to patch object]
%       varargout = [faces,vertices]
%
%   Example
%     % make some data
%     nn          = 12;
%     [x,y,z]     = deal(-nn:nn);
%     [x,y,z]     = meshgrid(x,y,z);
% 
%     % define logical with all values within sphere set as true
%     p           = x.^2+y.^2+z.^2 < (nn-0.9)^2;
% 
%     % plot the sphere
%     h1          = voxel(p,'triangles',true);
% 
%     % define colored sphere with nan's where no data should be plotted
%     colors      = nan(size(p));
%     colors(p)   = x(p)+y(p);
% 
%     % plot the sphere with colors and mangled y and z 
%     h2          = voxel(2*x,y-5+10*sin(x/-5),z+4*sin(x/-2),colors,'plotSettings',{'EdgeColor',[0 0.5 0]});
% 
%     % make nice plot
%     axis equal; 
%     view([-157 24])
%
%   See also: pcolor

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
% Created: 08 Feb 2012
% Created with Matlab version: 7.14.0.834 (R2012a)

% $Id: voxel.m 5771 2012-02-13 16:20:19Z tda.x $
% $Date: 2012-02-14 00:20:19 +0800 (Tue, 14 Feb 2012) $
% $Author: tda.x $
% $Revision: 5771 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/voxel.m $
% $Keywords: $

%% parse optional properties
OPT.triangles    = false;
OPT.plotSettings = {};

if nargin==0;
    varargout = OPT;
    return;
end

if nargin > 1
    if ischar(varargin{2})
        OPT = setproperty(OPT,varargin(2:end));
        varargin(2:end) = [];
    elseif nargin > 4
        OPT = setproperty(OPT,varargin(5:end));
        varargin(5:end) = [];
    end
end

%% input parsing
switch length(varargin)
    case 1
        p = varargin{1};
        if ndims(p) ~= 3
            error
        end
        x = 0:size(p,2);
        y = 0:size(p,1);
        z = 0:size(p,3);
    case 4
        p = varargin{4};
        if ndims(p) ~= 3
            error
        end
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
    otherwise
        error
end

if islogical(p)
    % ok
    color_faces = false;
else
    c = p;
    p = ~isnan(p);
    color_faces = true;
end

if all([isvector(x),isvector(y),isvector(z)])
    vectorMode = true;
    if  all(size(p) + 1 == [length(y) length(x) length(z)]) 
        x = x(:);
        y = y(:);
        z = z(:);
    elseif all(size(p) == [length(y) length(x) length(z)])
        % expand x, y and z in each direction
        x = center2corner1D(x(:));
        y = center2corner1D(y(:));
        z = center2corner1D(z(:));
    else
        error;
    end
else
    vectorMode = false;
    if ~isequal(size(x),size(y),size(z))
        error
    end
    % x,y and z are equal sizes
    if all(size(p) + 1 ==  size(x))
        % ok
    elseif all(size(p) == size(x))
        % expand x, y and z in each direction
        x = center2corner3D(x);
        y = center2corner3D(y);
        z = center2corner3D(z);
    else
        error;
    end
end



% from here you need X,Y,Z which are all same size 3D. p is size(X,Y,Z) - 1
% in all dimesnions.

%% determine what faces to plot per dimension
faces  = [];
colors = [];
for dimension = 1:3;
    n = [0 0 0];
    n(dimension) = 1;
    sides = false(size(p)+n);
    
    % determine which sides to plot
    switch dimension
        case 1
            sides(2:end-1,:,:) = diff(p,1,dimension) ~= 0;
            sides([1 end],:,:) = p([1 end],:,:);
        case 2
            sides(:,2:end-1,:) = diff(p,1,dimension) ~= 0;
            sides(:,[1 end],:) = p(:,[1 end],:);
        case 3
            sides(:,:,2:end-1) = diff(p,1,dimension) ~= 0;
            sides(:,:,[1 end]) = p(:,:,[1 end]);
    end
    
    % determine which color to plot them
    if color_faces
        switch dimension
            case 1
                c_temp_1 = c([1   1:end],:,:);
                c_temp_2 = c([1:end end],:,:);
            case 2
                c_temp_1 = c(:,[1   1:end],:);
                c_temp_2 = c(:,[1:end end],:);
            case 3
                c_temp_1 = c(:,:,[1   1:end]);
                c_temp_2 = c(:,:,[1:end end]);
        end
        c_temp   = nanmean([c_temp_1(:) c_temp_2(:)],2);
    end
    
    % determine connectivity matrix of all four corners
    [s1,s2,s3,s4] = deal(false(size(p)+1));
    switch dimension
        case 1
            s1(:,1:end-1,1:end-1) = sides;
            s2(:,1:end-1,2:end-0) = sides;
            s3(:,2:end-0,2:end-0) = sides;
            s4(:,2:end-0,1:end-1) = sides;
        case 2
            s1(1:end-1,:,1:end-1) = sides;
            s2(1:end-1,:,2:end-0) = sides;
            s3(2:end-0,:,2:end-0) = sides;
            s4(2:end-0,:,1:end-1) = sides;
        case 3
            s1(1:end-1,1:end-1,:) = sides;
            s2(1:end-1,2:end-0,:) = sides;
            s3(2:end-0,2:end-0,:) = sides;
            s4(2:end-0,1:end-1,:) = sides;
    end
    
    % append connectivity as squares or triangles
    if OPT.triangles
        faces  = [faces; [[find(s1) find(s2) find(s3)]; [find(s3) find(s4) find(s1)]]]; %#ok<AGROW>
        if color_faces
            colors = [colors; c_temp(sides); c_temp(sides)]; %#ok<AGROW>
        end
    else
        faces = [faces; [find(s1) find(s2) find(s3) find(s4)]]; %#ok<AGROW>
        if color_faces
            colors = [colors; c_temp(sides)]; %#ok<AGROW>
        end
    end
    
    
end

[iV,~,iF] = unique(faces);
if vectorMode
    [iVy,iVx,iVz] = ind2sub(size(p)+1,iV);
    verts   = [x(iVx) y(iVy) z(iVz)];
else
    verts   = [x(iV) y(iV) z(iV)];
end
faces   = reshape(iF,size(faces));

switch nargout
    case {0,1}
        if color_faces
            varargout{1} = patch('Faces',faces,'Vertices',verts,'FaceVertexCData',colors,'FaceColor','flat',OPT.plotSettings{:});
        else
            varargout{1} = patch('Faces',faces,'Vertices',verts,'FaceVertexCData',0,'FaceColor','flat',OPT.plotSettings{:});
        end
        view(3)
    case {2,3}
        varargout{1} = faces;
        varargout{2} = verts;
        varargout{3} = colors;
end

function v = center2corner3D(v)
v = [2*v(1,:,:) -  v(2,:,:); v; 2*v(end,:,:) -  v(end-1,:,:)];
v = (v(1:end-1,:,:) + v(2:end,:,:))/2;

v = [2*v(:,1,:) -  v(:,2,:)  v  2*v(:,end,:) -  v(:,end-1,:)];
v = (v(:,1:end-1,:) + v(:,2:end,:))/2;

v =  permute(v,[2,3,1]);
v = (v(:,1:end-1,:) + v(:,2:end,:))/2;
v = [2*v(:,1,:) -  v(:,2,:)  v 2*v(:,end,:)  -  v(:,end-1,:)];
v =  permute(v,[3,1,2]);

function v = center2corner1D(v)
v = [2*v(1) -  v(2); v; 2*v(end) -  v(end-1)];
v = (v(1:end-1) + v(2:end))/2;
