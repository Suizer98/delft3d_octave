function [C] = tricontourc(tri, x, y, z, N)
%TRICONTOURC Contouring over triangulated surface.
%
%   TRICONTOURC calculates the contour matrix C for use by TRICONTOUR,
%       TRICONTOUR3, or TRICONTOURF to draw the actual contour plot.
%   The output is equivalent to matlab's built in CONTOURS funtion
%   TRICONTOURS(X,Y,Z,N) computes N contour lines,
%      overriding the default automatic value.
%   TRICONTOURS(X,Y,Z,V) computes LENGTH(V) contour
%      lines at the values specified in vector V.
%
%   Syntax:
%   C = tricontourc(tri, x, y, z, N)
%
%   Input:
%   tri = triangulation
%   x   = x coordinates(row vector)
%   y   = y coordinates(row vector)
%   z   = z coordinates(row vector)
%   N   = Heights to draw contours
%
%   Output:
%   The contour matrix C is a two row matrix of contour lines. Each
%   contiguous drawing segment contains the value of the contour,
%   the number of (x,y) drawing pairs, and the pairs themselves.
%   The segments are appended end-to-end as
%
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
%   Example
%   
%   TODO:
%    - Probably the function can bee speeded up a lot by making use of the
%      TriRep functionality. Only found out about it's existence too late..
%
% See also: tricontours, TRICONTOUR3, TRICONTOURF, TRICONTOUR, CONTOURS, CONTOUR, CONTOUR3 and CONTOURF.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 21 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: tricontourc.m 2458 2010-04-18 21:53:48Z thijs@damsma.net $
% $Date: 2010-04-19 05:53:48 +0800 (Mon, 19 Apr 2010) $
% $Author: thijs@damsma.net $
% $Revision: 2458 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/tricontourc.m $
% $Keywords: $

%% Function start

% Find levels on which to draw contours
if numel(N)==1&&N==fix(N)&&N>0
    contourLevels = linspace(min(z),max(z),N+2);
    contourLevels = contourLevels(2:end-1);
else
    contourLevels = N;
end

% determine all the unique vertices in the triangluated mesh
vertices         = [tri(:,[1 2]);tri(:,[2 3]);tri(:,[3 1])];
vertices         = sort(vertices,2);

% also find the triangles of which each vertex is a boundary
vertex_tri_index = repmat((1:length(tri))',3,1);

% sort the vertices and the associated triangle indices
[vertices ndx]   = sortrows(vertices,[1 2]);
vertex_tri_index = vertex_tri_index(ndx);
[dummy,ndx1]     = unique(vertices,'rows','first');
[vertices,ndx2]  = unique(vertices,'rows','last');
vertex_tri_index = [vertex_tri_index(ndx1) vertex_tri_index(ndx2)];

% find the vertices which are on an edge of the 
vertices_on_edge      = vertex_tri_index(:,1)==vertex_tri_index(:,2);

% remove superfluous variables
clear ndx ndx1 ndx2

% declare C, initial size based on number of nodes 
C  = nan(2,length(x));
jj = 1;

for contourLevel = contourLevels;
    
    % find the vertices which cross the contour
    vertices_on_contour = xor(z(vertices(:,1))<contourLevel,z(vertices(:,2))<contourLevel);
   
    while any(vertices_on_contour)
        
        % search for interrupted loops;
        interrupted_vertices_start_vertex_options = find(vertices_on_contour & vertices_on_edge);
        if isempty(interrupted_vertices_start_vertex_options)
            interrupted_loop = false;
        else
            interrupted_loop = true;
        end
        
        % first start with the interrupted loops, then continous loops
        triangles_on_contour = unique([vertex_tri_index(vertices_on_contour,1);vertex_tri_index(vertices_on_contour,2)]);
        if interrupted_loop
            contour_tri = vertex_tri_index(interrupted_vertices_start_vertex_options(1),1);
        else
            contour_tri = triangles_on_contour(1);
        end

        temp = find(vertices_on_contour);
        contour_vertex_options = temp((vertex_tri_index(vertices_on_contour,1)==contour_tri|...
            vertex_tri_index(vertices_on_contour,2)==contour_tri));

        contour_vertex = nan(length(triangles_on_contour),1);
        
        if interrupted_loop
            if all(ismember(contour_vertex_options,find(vertices_on_edge)))
                contour_vertex(1:2) = contour_vertex_options;
                stop = true;
            else
                contour_vertex(1) = contour_vertex_options( ismember(contour_vertex_options,find(vertices_on_edge)));
                contour_vertex(2) = contour_vertex_options(~ismember(contour_vertex_options,find(vertices_on_edge)));
                stop = false;
            end
            ii = 2; 
        else
            contour_vertex(1) = contour_vertex_options(1); % doesn't mater on which vertex the contour starts, it is a loop anyway
            ii = 1;
             stop = false;
        end
        
        contour_tri_options = vertex_tri_index(contour_vertex(ii),:);
        contour_tri = contour_tri_options(contour_tri_options~=contour_tri);
        vertex_tri_index2 = vertex_tri_index(vertices_on_contour,:);
        vertex_tri_index3 = find(vertices_on_contour);
       
        
        while ~stop
            
            ii = ii+1;

            contour_vertex_options = vertex_tri_index3(vertex_tri_index2(:,1)==contour_tri|...
                vertex_tri_index2(:,2)==contour_tri);
            
            contour_vertex(ii) = contour_vertex_options(...
                contour_vertex_options~=contour_vertex(ii-1));
            
            contour_tri_options = vertex_tri_index(contour_vertex(ii),:);
            contour_tri = contour_tri_options(contour_tri_options~=contour_tri);
            if interrupted_loop
                stop =  any(interrupted_vertices_start_vertex_options == contour_vertex(ii));
            else
                stop = contour_vertex(ii)==contour_vertex(1);
            end
        end
        contour_vertex(ii+1:end) = [];
        %% find where a contour vertex crosses
        
        temp1     = z(vertices(contour_vertex,:))-contourLevel;
        temp2     = abs([temp1(:,2)./(temp1(:,1)-temp1(:,2)),...
                         temp1(:,1)./(temp1(:,1)-temp1(:,2))]);
        x_contour =  sum(temp2.*x(vertices(contour_vertex,:)),2);
        y_contour =  sum(temp2.*y(vertices(contour_vertex,:)),2);
        
        % assign coordinates to C
        nn              = length(x_contour);
        C(:,jj)         = [contourLevel;nn];
        jj              = jj+1;
        C(1,jj:jj+nn-1) = x_contour;
        C(2,jj:jj+nn-1) = y_contour;
        jj              = jj + nn;
        % remove the handled vertices omn the contour
        vertices_on_contour(contour_vertex) = 0;
    end
end
C(:,jj:end) = [];