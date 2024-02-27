function varargout = edges_tri_grid(tri,x,y,z)
%EDGES_TRI_GRID  finds the edge vertices of a triangluated mesh
%
%      E = edges_tri_grid(tri,x,y,z)
%
%   finds the edge vertices of a triangluated mesh
%
%   Input:
%   tri,x,y,z  = just like for trisurf
%
%   Output:
%   E = is a matrix, contains the coordinates of all points, and their connectivity [x,y,z,loop_index]
%   Alternative syntax:
%   [x,y,z,polygon_number,isNotHoleInAnotherPoly] = edges_tri_grid(tri,x,y,z)
%
%   Example
%   trisurf_edges
%   
%   TODO:
%    - Probably the function can be speeded up a lot by making use of the
%      TriRep functionality. Only found out about it's existence too late..
%
%   See also

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
% Created: 01 Mar 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: edges_tri_grid.m 10039 2014-01-20 09:25:44Z boer_g $
% $Date: 2014-01-20 17:25:44 +0800 (Mon, 20 Jan 2014) $
% $Author: boer_g $
% $Revision: 10039 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/edges_tri_grid.m $
% $Keywords: $
%%

% if triangles overlap, this function fails.
%  duplicate triangles
%  one point in polygon defined by other
% 

% TODO 
% make triangle grid fixer a seperate function



% determine all the unique vertices in the triangluated mesh
tri = int32(tri);

%  remove zero-area triangles
tri(tri(:,1) == tri(:,2) | tri(:,1) == tri(:,3) | tri(:,2) == tri(:,3),:) = [];

%  remove other very small 
tri(polyarea(x(tri),y(tri),2)<0.000001,:) = [];

% make sure triangles are unique (no duplicates)
tri = unique(sort(tri(:,1:3),2),'rows');
tri = tri(:,[1 2 3 1]);

vertices         = [tri(:,[1 2]);tri(:,[2 3]);tri(:,[3 1])];
vertices         = sort(vertices,2);

%% determine if there are intersecting triangles in the grid
figure
plot(x(vertices)',y(vertices)','k:')
hold on
intersectingVertices = false(size(vertices,1),1);
for ii = 1:length(vertices)
    x1 = x(vertices(ii,1));
    x2 = x(vertices(ii,2));
    y1 = y(vertices(ii,1));
    y2 = y(vertices(ii,2));
    
    nn = ii+1:length(vertices);
    n1 = find(max(x(vertices(nn            )),[],2)>=min(x1,x2));
    n2 = find(min(x(vertices(nn(n1        ))),[],2)<=max(x1,x2));
    n3 = find(max(y(vertices(nn(n1(n2    )))),[],2)>=min(y1,y2));
    n4 = find(min(y(vertices(nn(n1(n2(n3))))),[],2)<=max(y1,y2));
    n5 = ~any(ismember(vertices(nn(n1(n2(n3(n4)))),:),vertices(ii,:)),2);
    if any(nn(n1(n2(n3(n4(n5))))))
        for jj = nn(n1(n2(n3(n4(n5)))))
            x3 = x(vertices(jj,1));
            x4 = x(vertices(jj,2));
            y3 = y(vertices(jj,1));
            y4 = y(vertices(jj,2));
            if det([1,1,1;x1,x2,x3;y1,y2,y3])*det([1,1,1;x1,x2,x4;y1,y2,y4]) <= 0
                if det([1,1,1;x1,x3,x4;y1,y3,y4])*det([1,1,1;x2,x3,x4;y2,y3,y4]) <= 0
                    plot([x1 x2],[y1 y2],'r');
                    plot([x3 x4],[y3 y4],'g');
                    intersectingVertices([ii jj]) = true;
                end
            end
        end
    end
end
a = tri(any(ismember(tri,unique(vertices(intersectingVertices,:))),2),:);% = [];

trisurf(a(:,1:3),x,y,z-1);

tri(any(ismember(tri,unique(vertices(intersectingVertices,:))),2),:) = [];
vertices         = [tri(:,[1 2]);tri(:,[2 3]);tri(:,[3 1])];
vertices         = sort(vertices,2);
% vertices(intersectingVertices) = [];


% also find the triangles of which each vertex is a boundary
vertex_tri_index = repmat((1:size(tri,1))',3,1);

% sort the vertices and the associated triangle indices
[vertices ndx]   = sortrows(vertices,[1 2]);
vertex_tri_index = int32(vertex_tri_index(ndx));
[dummy,ndx1]     = unique(vertices,'rows','first');
[vertices,ndx2]  = unique(vertices,'rows','last');
vertex_tri_index = [vertex_tri_index(ndx1) vertex_tri_index(ndx2)];

% find the vertices which are on an edge of two triangles
edgeVertices = vertex_tri_index(:,1)==vertex_tri_index(:,2);
edgeTriIndex = vertex_tri_index(edgeVertices,1);
edgeIndices = vertices(edgeVertices,:);

edgeIndices(:,[3 4 5 6]) = 0; % The index of the next line will be stored here
previousEdgeIndex = 0;
ii = 1;
jj = 10; % identifier for connecting edges ring
while any(edgeIndices(:,4)==0)
    % first try to find connectingLine from the first row of coordinates
    connectingLines = find(edgeIndices(ii,2)==edgeIndices(:,1)|...
        edgeIndices(ii,2)==edgeIndices(:,2));
    connectingLines(connectingLines==ii)=[];
    if numel(connectingLines)==0
        figure
        trisurf(tri,x,y,z,1)
        hold on
        connectingLines = find(edgeIndices(ii,2)==edgeIndices(:,1)|...
            edgeIndices(ii,2)==edgeIndices(:,2));
        trisurf(tri(edgeTriIndex(connectingLines),:),x,y,z+1,10)
        view(2)
        xlim(mean(mean(x(tri(edgeTriIndex(connectingLines),:))))+[-200 200])
        ylim(mean(mean(y(tri(edgeTriIndex(connectingLines),:))))+[-200 200])
        error('i give up... the mesh is to complicated, holes and edges may not connect, or maybe triangles overlap')
    end
    if numel(connectingLines)~=1
        % find the connecting line which is on the same triangle.
        possibleConnectingLines = connectingLines(edgeTriIndex(connectingLines)==edgeTriIndex(ii));
        if numel(possibleConnectingLines)~=1
            % this is a very exceptional situation (I hope).
            connectedTriangles = unique(vertex_tri_index(any(vertex_tri_index==edgeTriIndex(ii),2),:));
            possibleConnectingLines = connectingLines(ismember(edgeTriIndex(connectingLines),connectedTriangles));
            if numel(possibleConnectingLines)~=1
                connectedTriangles = unique(vertex_tri_index(any(ismember(vertex_tri_index,connectedTriangles),2),:));
                possibleConnectingLines = connectingLines(ismember(edgeTriIndex(connectingLines),connectedTriangles));
                if numel(possibleConnectingLines)~=1
                    connectedTriangles = unique(vertex_tri_index(any(ismember(vertex_tri_index,connectedTriangles),2),:));
                    possibleConnectingLines = connectingLines(ismember(edgeTriIndex(connectingLines),connectedTriangles));
                    if numel(possibleConnectingLines)~=1
                        connectedTriangles = unique(vertex_tri_index(any(ismember(vertex_tri_index,connectedTriangles),2),:));
                        possibleConnectingLines = connectingLines(ismember(edgeTriIndex(connectingLines),connectedTriangles));
                        if numel(possibleConnectingLines)~=1
                            
                            xm = mean(mean(x(tri(edgeTriIndex(connectingLines),:))));
                            ym = mean(mean(y(tri(edgeTriIndex(connectingLines),:))));
                            figure
                            trisurf(tri,x-xm,y-ym,z,1)
                            hold on
                            trisurf(tri(edgeTriIndex(connectingLines),:),x-xm,y-ym,z+1,10)
                            view(2)
                            xlim([-200 200])
                            ylim([-200 200])
                           plot(x(edgeIndices(connectingLines,[1 2]))-xm,...
                               y(edgeIndices(connectingLines,[1 2]))-ym,'.')
                            error('i give up... the mesh is to complicated, holes and edges may not connect, or maybe triangles overlap')
                        end
                    end
                end
            end
        end
        connectingLines = possibleConnectingLines;
    end
    % reverse coordinates if found from the second row
    if edgeIndices(ii,2)==edgeIndices(connectingLines,2)
        edgeIndices(connectingLines,[1 2]) = edgeIndices(connectingLines,[2 1]);
    end
    
    if edgeIndices(ii,4)==0
        edgeIndices(ii,3) = previousEdgeIndex;
        edgeIndices(ii,4) = connectingLines;
        edgeIndices(ii,5) = jj;
        previousEdgeIndex = ii;
        ii = connectingLines;
    else % start a new loop
        edgeIndices(ii,4) = connectingLines;
        edgeIndices(ii,5) = jj;
        % find the triangle with which the old loop has ended and store it
        % to later then determine if the center of that triangle is
        % contained within that ring
        edgeIndices(ii,6) = edgeTriIndex(ii);
        % find a new value for ii
        ii = find(edgeIndices(:,4)==0,1);
        previousEdgeIndex = 0;
        jj = jj+1;
    end
end
edgeIndices(ii,6) = edgeTriIndex(ii);

while any(edgeIndices(:,3)==0)
    ii = find(edgeIndices(:,3)==0,1);
    edgeIndices(ii,3) = find(edgeIndices(:,4)==ii,1);
end

[dummy,dummy,edgeIndices(:,5)] = unique(edgeIndices(:,5));

E = [x(edgeIndices(:,1)),...
     y(edgeIndices(:,1)),...
     z(edgeIndices(:,1)),...
     double(edgeIndices(:,5)),...
     double(edgeIndices(:,4)),...
     double(edgeIndices(:,6))];
 
 %% sort trisurf edges
 
E2 = nan(size(E,1)+max(E(:,4)),5);
kk = 0;
for ii = 1:max(E(:,4))
    nextIndex = find(E(:,4)==ii,1,'first');
    for jj = 1:sum(E(:,4)==ii)+1
        kk = kk+1;
        E2(kk,:) = E(nextIndex,[1 2 3 4 6]);
        nextIndex = E(nextIndex,5);
    end
end
E=E2;

%% determine if the loop is empty or filled or not
for ii=1:E(end,4)
    jj = find(E(:,4)==ii);
    E(jj,5) = inpolygon(...
        mean(x(tri(E(jj(1),5),:))),...
        mean(y(tri(E(jj(1),5),:))),...
        E(jj,1),E(jj,2));
end

if nargout==1
    varargout = {E};
else
    varargout = {E(:,1),E(:,2),E(:,3),E(:,4),E(:,5)};
end
 



