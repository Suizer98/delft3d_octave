function E = edges_structured_grid(x,y,z)
%EDGES_STRUCTURED_GRID   One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   E = edges_structured_grid(x,y,x)
%
%   Input:
%
%
%
%
%   Example
%   edges_structured_grid
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
% Created: 19 Apr 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: edges_structured_grid.m 10039 2014-01-20 09:25:44Z boer_g $
% $Date: 2014-01-20 17:25:44 +0800 (Mon, 20 Jan 2014) $
% $Author: boer_g $
% $Revision: 10039 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/edges_structured_grid.m $
% $Keywords: $

%%

z1                  = nan(size(z)+2);
z1(2:end-1,2:end-1) = z;
z1                  = ~isnan(z1);
edgeIndices         = nan(numel(z1),2);

kk = 0;
nn = size(z,1);
mm = size(z,2);
for ii = 2:nn+1
    for jj = 2:mm
        if ~((z1(ii-1,jj)&&z1(ii-1,jj+1))&&(z1(ii+1,jj)&&z1(ii+1,jj+1)))
            if z1(ii,jj)&&z1(ii,jj+1)
                if ((z1(ii-1,jj)&&z1(ii-1,jj+1))||(z1(ii+1,jj)&&z1(ii+1,jj+1)))
                    kk = kk+1;
                    edgeIndices(kk,:) = [nn*(jj-2)+ii-1,nn*(jj-1)+ii-1];
                end
            end
        end
    end
end
for ii = 2:nn
    for jj = 2:mm+1
        if ~((z1(ii,jj-1)&&z1(ii+1,jj-1))&&(z1(ii,jj+1)&&z1(ii+1,jj+1)))
            if ((z1(ii,jj-1)&&z1(ii+1,jj-1))||(z1(ii,jj+1)&&z1(ii+1,jj+1)))
                if z1(ii,jj)&&z1(ii+1,jj)
                    kk = kk+1;
                    edgeIndices(kk,:) = [nn*(jj-2)+ii-1,nn*(jj-2)+ii];
                end
            end
        end
    end
end

edgeIndices(isnan(edgeIndices(:,1)),:) = [];



edgeIndices(:,[3 4 5]) = 0; % The index of the next line will be stored here
previousEdgeIndex = 0;
kk = 1;
ll = 10; % identifier for connecting edges ring
while any(edgeIndices(:,4)==0)
    % first try to find connectingLine form the first row of coordinates
    connectingLines = find(edgeIndices(kk,2)==edgeIndices(:,1)|...
        edgeIndices(kk,2)==edgeIndices(:,2));
    connectingLines(connectingLines==kk)=[];
    if numel(connectingLines)~=1
        % find the connecting line which is on the same triangle.
        error('the mesh is to complicated for this routine for the moment. will try to fix it sometime /Thijs')
    end
    % reverse coordinates if found from the second row
    if edgeIndices(kk,2)==edgeIndices(connectingLines,2)
        edgeIndices(connectingLines,[1 2]) = edgeIndices(connectingLines,[2 1]);
    end
    
    if edgeIndices(kk,4)==0
        edgeIndices(kk,3) = previousEdgeIndex;
        edgeIndices(kk,4) = connectingLines;
        edgeIndices(kk,5) = ll;
        previousEdgeIndex = kk;
        kk = connectingLines;
    else % start a new loop 
        edgeIndices(kk,4) = connectingLines;
        edgeIndices(kk,5) = ll;
        % find a new value for kk
        kk = find(edgeIndices(:,4)==0,1);
        previousEdgeIndex = 0;
        ll = ll+1;
    end
end

while any(edgeIndices(:,3)==0)
    ii = find(edgeIndices(:,3)==0,1);
    edgeIndices(ii,3) = find(edgeIndices(:,4)==ii);
end

[dummy,dummy,edgeIndices(:,5)] = unique(edgeIndices(:,5));

E = [x(edgeIndices(:,1)),...
     y(edgeIndices(:,1)),...
     z(edgeIndices(:,1)),...
     double(edgeIndices(:,5)),...
     double(edgeIndices(:,4))];
 
 %% sort edges
 
E2 = nan(size(E,1)+max(E(:,4)),4);
kk = 0;
for ii = 1:max(E(:,4))
    nextIndex = find(E(:,4)==ii,1,'first');
    for jj = 1:sum(E(:,4)==ii)+1
        kk = kk+1;
        E2(kk,:) = E(nextIndex,[1 2 3 4]);
        nextIndex = E(nextIndex,5);
    end
end
E=E2;

%% make the loop clockwise, and determine if the loop is empty or filled or not
for kk=1:E(end,4)
    ll = find(E(:,4)==kk);
    if ~poly_isclockwise(E(ll,1),E(ll,2));
        E(ll,:) = E(flipud(ll),:);
    end
    
    [ii   ,jj   ] = ind2sub([nn,mm],find(x == E(ll(1),1) & y == E(ll(1),2)));
    [ii(2),jj(2)] = ind2sub([nn,mm],find(x == E(ll(2),1) & y == E(ll(2),2)));
   
    if jj(1)==jj(2)
        if ii(2)>ii(1)
            jj([3 4]) = jj([1 2])+1;
        else
            jj([3 4]) = jj([1 2])-1;
        end
        ii([3 4]) = ii([1 2]);
    else
        if jj(2)<jj(1)
            ii([3 4]) = ii([1 2])+1;
        else
            ii([3 4]) = ii([1 2])-1;
        end
        jj([3 4]) = jj([1 2]);
    end

    E(ll,5) = ~any(any(isnan(x(ii,jj)+y(ii,jj)+z(ii,jj))));
    

    
        
%         surf(x,y,z,ones(size(z)))
%     view([0,90])
%     
%     hold on
%     plot3(E(ll(1),1),E(ll(1),2),E(ll(1),3),'ro')
%     plot3(E(ll(2),1),E(ll(2),2),E(ll(2),3),'bo')
%     
%     plot3([x(ii(1),jj(1)) x(ii(2),jj(2)) x(ii(3),jj(3)) x(ii(4),jj(4))],...
%         [y(ii(1),jj(1)) y(ii(2),jj(2)) y(ii(3),jj(3)) y(ii(4),jj(4))],...
%         [z(ii(1),jj(1)) z(ii(2),jj(2)) z(ii(3),jj(3)) z(ii(4),jj(4))],'k*')
%     hold off      
end

