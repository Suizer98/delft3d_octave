function varargout = patch2tri(corx,cory,map,varargin)
%PATCH2TRI  chop up collection of 3-4-5-6-agon patches into triangles
%
%   [tri,map3,ntyp] = patch2tri(x,y,map)
%
% where map is a 6xn map array defining n 3-4-5-6-agons 
% by pointering to vectors (x,y). These are chopped
% up in triangles such that the 3xn array tri pointers
% to vectors (x,y). ntyp is a list of how many
% 3-4-5-6-agons are defined by map. map3 contains a 
% pointer vector to explode the n centervalues
% to the triangle center values.
%
%    trisurf(tri,xcor,ycor,zcor)       plots vertex (corner) data zcor and
%    trisurf(tri,xcor,ycor,zcen(map3)) plots patch (center) data zcen
%
%  +                                   +                               
%  | \                                 | \                             
%  |   \                               |   \                           
%  | 3   \                             |     \                         
%  +-------+--------+                  +-------+--------+              
%  |       |        |                  |    /  |  \     |              
%  |  4    |   5    |                  |  /    |    \   |              
%  +-------+        +---------+        +-------+--------+---------+    
%           \      /           \                \      /|\        |\   
%             \  /               \                \  /  |  \      |  \ 
%               +        6        +                 +   |    \    |   +
%                 \              /                    \ |      \  |  / 
%                  \           /                       \|        \|/   
%                   +---------+                         +---------+    
%
% See also: TRISURFCORCEN, QUAT2NET, QUAT, TRIQUAT, DELAUNAY

%   --------------------------------------------------------------------
%   Copyright (C) 2011-12 Deltares
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl
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

% $Id: patch2tri.m 12494 2016-02-05 10:17:42Z nabi $
% $Date: 2016-02-05 18:17:42 +0800 (Fri, 05 Feb 2016) $
% $Author: nabi $
% $Revision: 12494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/patch2tri.m $
% $Keywords: $

%% input

   OPT.debug = 0;
   OPT.quiet = 0;
   
   if nargin==0
      varargout = {OPT};
      return
   else
      OPT = setproperty(OPT,varargin);
   end

%% determine # of triangles

   nface      = sum(map > 0,2);

   ntyp(3)    = sum(nface==3);
   ntyp(4)    = sum(nface==4); % quadrangle become 2 triangles each (4-2)
   ntyp(5)    = sum(nface==5); % pentagon   become 3 triangles each (5-2)
   ntyp(6)    = sum(nface==6); % hexahon    become 4 triangles each (6-2)
   
   ntri       = sum(ntyp.*[0 0 1 2 3 4]);
   tri        = repmat(int32(0),[ntri 3]); % pre-allocate for speed
   map3       = repmat(int32(0),[ntri 1]); % pre-allocate for speed
   
%% 3: re-use existing triangles

   ind = find(nface==3);
   tri (1:length(ind),:)   = map(ind,1:3);
   map3(1:length(ind))     = ind;

%% plot existing triangles

   if OPT.debug > 1
      ind = find(nface==3);
      tri     = map(ind,1:3);
      trisurf(tri,corx,cory,corx.*0)
      view(0,90)
      hold on
   end
   
   %plot(tri(:,1));hold on;plot(map3,'r');xlim([0 ntri]);pausedisp;clf

%% 4: quadrilaterals: 2 triangles each
%     delaunay used to fails for perfect square (R2009a and lower), so we gotta do it ourselves

   ind = find(nface==4);
   n   = ntyp(3);
   
   ismaindiag = [];
   % Split quad into two triangles directly: cut 'along' shortest diagonal.
   numquads = length(ind);
   if length(ind) > 0
       ismaindiag = (   (corx(map(ind,1)) - corx(map(ind,3))).^2 ...
                      + (cory(map(ind,1)) - cory(map(ind,3))).^2 ...
                    ) > (corx(map(ind,2)) - corx(map(ind,4))).^2 ...
                      + (cory(map(ind,2)) - cory(map(ind,4))).^2;

       ntri1 = sum( ismaindiag);
       ntri2 = sum(~ismaindiag);
       i1    = ind( ismaindiag);
       i2    = ind(~ismaindiag);

       % Quads where 2--4 is shortest diagonal: tri's are 1-2-4 and 2-3-4
       tri (n+1      :n+  ntri1,    1:3) = map(i1,[1 2 4]);
       tri (n+1+ntri1:n+2*ntri1,    1:3) = map(i1,[2 3 4]);
       map3(n+1      :n+  ntri1)         = i1;
       map3(n+1+ntri1:n+2*ntri1)         = i1;
       n =            n+2*ntri1;

       %plot(tri(:,1));hold on;plot(map3,'r');xlim([0 ntri]);pausedisp;clf

       % Quads where 1--3 is shortest diagonal: tri's are 1-2-3 and 1-3-4
       tri (n+1      :n+  ntri2,    1:3) = map(i2,[1 2 3]);
       tri (n+1+ntri2:n+2*ntri2,    1:3) = map(i2,[1 3 4]);
       map3(n+1      :n+  ntri2)         = i2;
       map3(n+1+ntri2:n+2*ntri2)         = i2;
       n =            n+2*ntri2;
   end

   %[D.tri,n] = nface2tri(map,corx,cory,tri,4,n,ind,OPT.debug,'quadrilateral');
   
   %plot(tri(:,1));hold on;plot(map3,'r');xlim([0 ntri]);pausedisp;clf
   
%% 5: pentagons: 3 triangles each

   ind = find(nface==5);
   if ~(n== sum(ntyp.*[0 0 1 2 0 0]));error('error after tri + quad');end
   [tri,n,map3] = nface2tri(map,corx,cory,tri,5,n,ind,OPT.debug,'pentagon',map3,OPT.quiet);

   %plot(tri(:,1));hold on;plot(map3,'r');xlim([0 ntri]);pausedisp;clf

%% 6

   ind = find(nface==6);
   if ~(n== sum(ntyp.*[0 0 1 2 3 0]));error('error after tri + quad + pent');end
   [tri,n,map3] = nface2tri(map,corx,cory,tri,6,n,ind,OPT.debug,'hexagon',map3,OPT.quiet);

   %plot(tri(:,1));hold on;plot(map3,'r');xlim([0 ntri]);pausedisp;clf

%% out

   varargout = {tri,map3,ntyp};
   
%% genericish subsidiary for quad-, pent- and hexagons

function [tri,n,map3] = nface2tri(Map,X,Y,tri,type,n,ind,debug,txt,map3,quiet)

   order = type-2;

   for i=1:length(ind)
   
       pointers = Map(ind(i),1:type);
       x        = X(pointers);
       y        = Y(pointers);
       trilocal = delaunay(x,y); % sometimes fails, and does not always yield 3 triangles
       
       if size(trilocal,1) > order
          if ~quiet
              warning([txt,' is not divided onto ',num2str(order),' triangles but ',num2str(size(trilocal,1)),': triangle(s) ingnored']);
          end
          trilocal = trilocal(1:order,:);
          if debug
             plot(x,y,'c-o','linewidth',10)
             pausedisp
          end
       elseif size(trilocal,1) < order
          if ~quiet
              warning([txt,' is not divided onto ',num2str(order),' triangles but ',num2str(size(trilocal,1)),': triangle(s) duplicated']);
          end
          
          trilocal = repmat(trilocal,[order 1]);
          
          if debug
             plot(x,y,'c-o','linewidth',10);
             pausedisp
          end
       end
       
       tri (n+1:n+order,:) = pointers(trilocal);
       map3(n+1:n+order,:) = ind(i);
       n                   = n + order;
       
   end       
