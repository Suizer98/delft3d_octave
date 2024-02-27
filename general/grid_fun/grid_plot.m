function varargout = grid_plot(x,y,varargin);
%GRID_PLOT   plot lines of curvi-linear grid
%
% gridplot(x,y) plots lines of curvilinear grid
%
% Same syntax as plot(...)
% gridplot(x,y,linespec)
% gridplot(x,y,<option,argument>)
%
% Remember to call axis equal.
%
%See also: MESH

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/ 
%   --------------------------------------------------------------------

% 
% if nargin==3
%    color = varargin{1};
%    set(handle,'edgecolor',color)
%    set(handle,'facecolor','none')
% end

% handle = mesh(x,y,zeros(size(x)));

if odd(nargin)
   linespec  = varargin;
elseif nargin >2
   linespec  = varargin;
else
   linespec  = 'b';
end

handle_type = 2;

if handle_type==2

   %% all m line are plotted as one nan-seperated line
   %% all n line are plotted as one nan-seperated line
   %% so there 2 separate handles.
   
   xx = addrowcol(x,1,1,nan); xhor = xx;xver = xx'; xx = [xhor(:) xver(:)];
   yy = addrowcol(y,1,1,nan); yhor = yy;yver = yy'; yy = [yhor(:) yver(:)];
   
   if iscell(linespec)
   p = plot(xx,yy,linespec{:});
   else
   p = plot(xx,yy,linespec);
   end


elseif isinf(handle_type)

   %% with the method below each grid line gets a separate
   %% handle
   
   if iscell(linespec)
   ph = plot(x,y,linespec{:});
   hold on
   pv = plot(x',y',linespec{:});
   p  = [ph(:)' pv(:)']';
   else
   ph = plot(x,y,linespec);
   hold on
   pv = plot(x',y',linespec);
   p  = [ph(:)' pv(:)']';
   end
end

%if nargin>2
%   set(p,varargin{optsstart:end});
%end

if nargout==1
   varargout = {p};
end

%% EOF