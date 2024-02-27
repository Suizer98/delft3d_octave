function varargout = tri2poly(connectivity,x,y,varargin)
%TRI2POLY   rewrite bi/tri connectivity into long NaN-separated polygons (for fast plotting)
%
%  [X Y]   = tri2poly(tri,x,y)
%  [X Y Z] = tri2poly(tri,x,y,z)
%
% Example:
% 
%  [x,y,z]=peaks(20);
%  tri = delaunay(x,y);
%  h=trisurf(tri,x,y,z)
%  set(h','edgecolor','none')
%  view(0,90)
%  hold on
%  [X,Y,Z]=tri2poly(tri,x,y,z);plot3(X,Y,Z,'k'); %
%  trimesh(tri,x,y,z,'edgecolor','k')
%
%See also: poly_fun, trimesh

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for www.NMDC.eu
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

% $Id: tri2poly.m 7554 2012-10-23 06:56:18Z boer_g $
% $Date: 2012-10-23 14:56:18 +0800 (Tue, 23 Oct 2012) $
% $Author: boer_g $
% $Revision: 7554 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/tri2poly.m $
% $Keywords: $

%% input

   OPT.debug = 0;
   OPT.log   = 0; % 1=command line, 2=multiwaitbar
   
   if odd(nargin)
      nextarg = 1;
   else
      nextarg = 2;
      z = varargin{1};    
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});

%% assemble sides of triangle into heap of line segments

if     size(connectivity,2)==2

   duo.ends = connectivity;

elseif size(connectivity,2)==3

   duo.ends = reshape([connectivity(:,[1 2 2 3 3 1])]',[2 size(connectivity,1)*3])';
   
%% remove double segments and sort segments on nearness

   duo.ends = poly_bi_unique(duo.ends);
   
elseif size(connectivity,2)>3

   error('only bi and tri connectivity implemented')

end

duo.done = duo.ends.*0;

%% start with 1st full line segment
   
   ipol           = 1;             % ipol is index into assambles polygons 
   j              = 1;             % j    is index into duo segment 
   i              = duo.ends(j,2); % i    is index into x,y,z (tri pointer)
   pol{ipol}      = repmat(0,[1 sum(~duo.done(:,1))]);
   ipt            = 1;
   pol{ipol}(1:2) = duo.ends(j,:);
   duo.done(j,:)  = 1;
   
   while ~all(duo.done)
   
% find new segment for current polygon [most timeconsuming line]
       
     mask = (duo.ends'==i & duo.done'==0); % sorted transposed so it is already sorted on js
      
% if none found start new polygon
    
      if ~any(mask)
        [js,sides] = find(duo.done==0);
         if ~any(js)
            break
         else
            if OPT.log>0
            end
            lab=[num2str(ipol),' polygons found with ',num2str(sum(duo.done(:,1))),' points (still ',num2str(sum(~duo.done(:,1))),' points to do)'];
            if OPT.log==1
            disp(lab)
            elseif OPT.log==2
            multiWaitbar( 'merge', sum(duo.done(:,1))./size(duo.done,1) ,'label',lab);
            end
   
            pol{ipol}(pol{ipol}==0)=[];
            ipol           = ipol+1;
            js             = js(end); % end gives longer polygons
            sides          = sides(end);
            i              = duo.ends(js,sides);
            pol{ipol}      = repmat(0,[1 sum(~duo.done(:,1))]);
            ipt            = 1;
            pol{ipol}(ipt) = i;
         end
      else
     [sides,js]= find(mask);
      end
   
% attach other end of segment to current polygon
       
      j = js(1);
      otherside        = -(sides(1)-1.5)+1.5; % 1 => 2, 2 => 1: if one segment was match, we need to add the other
      i                = duo.ends(j,otherside);
      duo.done(j,:)    = 1;
      ipt              = ipt + 1;
      pol{ipol}(ipt) = i;
      
   end

%% assemble coordinates
   
   n = length(pol);

   P.x = poly_join(cellfun(@(p) x(p),pol,'UniformOutput',0));
   P.y = poly_join(cellfun(@(p) y(p),pol,'UniformOutput',0));
   if ~odd(nargin)
   P.z = poly_join(cellfun(@(p) z(p),pol,'UniformOutput',0));
   end
   
   %size(connectivity,1)*3+length(pol) % all segments + end points for each polygon
   %sum(cellfun(@(x) length(x),pol))
   
   %size(connectivity,1)*3+length(pol)*2  % all segments + end points for each polygon + na for each polygon
   %length(P.x)
   
%% plotting for debugging

if OPT.debug & size(connectivity,2)==3

   close all   
    figure(1)
      trisurf(connectivity,x,y,z)
      hold on
      %KMLtrisurf(connectivity,x,y,z,'fileName','peaks.kml',...
      %                    'zScaleFun',@(z) 3e4 + 1e4.*z)
      map = jet(length(pol)).*0;
      for p=1:length(pol)
      plot3(x(pol{p})   ,y(pol{p})   ,z(pol{p})       ,'color',map(p,:),'linewidth',p)
      
      plot3(x(pol{p}(1)),y(pol{p}(1)),z(pol{p}(1)),'o','color',map(p,:))
      end
   
    figure(2)
      h=trisurf(connectivity,x,y,z.*0,'EdgeColor','r');
      hold on
      view(0,90)
      map = jet(length(pol)).*0;
      for p=1:length(pol)
      plot(x(pol{p})   ,y(pol{p})   ,'color',map(p,:),'linewidth',.5+p)
      pause(0.1)
      plot(x(pol{p}(1)),y(pol{p}(1)),'o','color',map(p,:))
      end
      plot(P.x,P.y,'b')
   
end

%% output
if odd(nargin)
    if nargout==2
    varargout = {P.x,P.y};
    elseif nargout==3
    varargout = {P.x,P.y,n};
    end
else
    if nargout==3
    varargout = {P.x,P.y,P.z};
    elseif nargout==4
    varargout = {P.x,P.y,P.z,n};
    end
end

if OPT.log==2
multiWaitbar( 'merge', 'close');
end
