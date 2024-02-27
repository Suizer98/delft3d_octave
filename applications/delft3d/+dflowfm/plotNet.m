function varargout = plotNet(varargin)
%plotNet  Plot a D-Flow FM unstructured grid.
%
%     G  = dflowfm.readNet(ncfile) 
%    <h> = dflowfm.plotNet(G     ,<keyword,value>) 
%          % or 
%    <h> = dflowfm.plotNet(ncfile,<keyword,value>) 
%
%   plots a D-Flow FM unstructured net (centers, corners, contours),
%   optionally the handles h are returned.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside a bounding polygon is plotted.
%            Use [] for whole grid. For axis to be be a polygon, supply a
%            struct('x',[xmin, xmax],'y',[ymin, ymax]).
%    * idmn: plot grid with the specified domain number only (if available)
%
%   Formatting of the grid is controlled by the following options:
%    * node: corner point style, e.g. {'r.','markersize',10}
%    * edge: edge style, e.g., {'k-'}
%    * face: (circum)center point style, e.g. {'b+','markersize',10}
%   Defaults values can be requested with OPT = dflowfm.plotNet().
%
%   Note: all flow cells are plotted as one NaN-separated line: fast.
%
%   See also dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arthur van Dam & Gerben de Boer
%
%       <Arthur.vanDam@deltares.nl>; <g.j.deboer@deltares.nl>
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

% $Id: plotNet.m 17463 2021-08-25 07:33:52Z ottevan $
% $Date: 2021-08-25 15:33:52 +0800 (Wed, 25 Aug 2021) $
% $Author: ottevan $
% $Revision: 17463 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/plotNet.m $
% $Keywords: $

% TO DO: to do: plot center connectors (NetElemNode)
% TO DO: to do: plot 1D cells too

%% input

   OPT.axis = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   % arguments to plot(x,y,OPT.keyword{:})
   OPT.node  = {'r.','markersize',10};
   OPT.edge  = {'k-'};
   OPT.face  = {'b+','markersize',10};
   OPT.idmn  = -1;   % domain to plot
   
   if nargin==0
      varargout = {OPT};
      return
   else
      if ischar(varargin{1})
      ncfile   = varargin{1};
      
      conv = ncreadatt(ncfile,'/','Conventions');
       if strcmp(conv,'UGRID-0.9')% mapformat 1
           G      = dflowfm.readNetOld(ncfile);% edited by BS
       elseif strcmp(conv,'CF-1.6 UGRID-1.0/Deltares-0.8')% mapformat 4
           G      = dflowfm.readNet(ncfile);% edited by BS
       else 
           sprintf('Current version of this script does not recognize mapformat %d',conv)% use default (mapformat 1)
           G      = dflowfm.readNetOld(ncfile);% edited by BS
       end

      else
      G        = varargin{1};
      end
      OPT = setproperty(OPT,varargin{2:end});
   end
   
   if isnumeric(OPT.axis) && ~isempty(OPT.axis) % axis vector 2 polygon
       tmp        = OPT.axis;
       OPT.axis.x = tmp([1 2 2 1]);
       OPT.axis.y = tmp([3 3 4 4]);
       clear tmp
   end

%% plot nodes ([= corners)

   if isfield(G,'node') && ~isempty(OPT.node)
   
     if isempty(OPT.axis)
        node.mask = true(1,G.node.n);
     else
        node.mask = inpolygon(G.node.x,G.node.y,OPT.axis.x,OPT.axis.y);
     end

%        plot nodes with node mask         
     h.node  = plot(G.node.x(node.mask),G.node.y(node.mask),OPT.node{:});
     hold on

   end
   
%% plot centres (= flow cells = circumcenters)
   if isfield(G,'face')
     if isfield(G.face,'FlowElemSize') && ~isempty(OPT.face)
       if isempty(OPT.axis)
          face.mask = true(1,G.face.FlowElemSize);
       else
          face.mask = inpolygon(G.face.FlowElem_x,G.face.FlowElem_y,OPT.axis.x,OPT.axis.y);
       end
       
       if ( OPT.idmn>-1 && isfield(G.face,'FlowElemDomain'))
           if ( length(G.face.FlowElemDomain)==G.face.FlowElemSize )
              face.mask = (face.mask & G.face.FlowElemDomain==OPT.idmn);
           end
       end
        
       h.face = plot(G.face.FlowElem_x(:,face.mask),G.face.FlowElem_y(:,face.mask),OPT.face{:});
       hold on   
     end
   end
%% plot connections (network edges)

   if isfield(G,'edge') && ~isempty(OPT.edge)
    
    x = G.node.x(G.edge.NetLink);
    y = G.node.y(G.edge.NetLink);    
    
    x(3,:)=NaN;
    y(3,:)=NaN;
       
    if isempty(OPT.axis)
        h.edge = plot(x(:),y(:),OPT.edge{:});  
    else
        edge.mask = repmat(inpolygon(x(1,:),y(1,:),OPT.axis.x,OPT.axis.y) | ...
                           inpolygon(x(2,:),y(2,:),OPT.axis.x,OPT.axis.y), 3,1);
        h.edge = plot(x(edge.mask),y(edge.mask),OPT.edge{:});
    end        
    hold on   
   end
   
%% lay out

	hold off
    if ~isempty(OPT.axis)
        axis([OPT.axis.x(:)' OPT.axis.y(:)'])
    else
        axis equal
    end
%    grid on
   
%% return handles

   if nargout==1
      varargout = {h};
   end
