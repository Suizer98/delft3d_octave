function varargout = plotMap(varargin)
%plotMap Plot a D-Flow FM unstructured map.
%
%   NB For faster scalar map plots, please use dflowfm.readFlowGeom2tri.
%
%     G  = dflowfm.readNet(ncfile) 
%     D  = dflowfm.readMap(ncfile,<it>) 
%    <h> = dflowfm.plotMap(G,D,<keyword,value>) 
%    <h> = dflowfm.plotMap(G,center_matrix,<keyword,value>) 
%          % or 
%    <h> = dflowfm.plotMap(ncfile,<it>,<keyword,value>);
%
%   plots a D-Flow FM unstructured map, optionally the handles h are returned.
%   For plotting multiple timesteps it is most efficient
%   to read the unstructured grid G once, and update D and plotMap.
%   Note that you need to read the grid G from the map file (*_map.nc),
%   not from the grid input file (*_net.nc) beause that lacks the
%   node connectivity information. The network itself is not plotted, 
%   since plotMap chops all cells into triangles before plotting.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] for while grid.
%            for axis to be be a polygon, supply a struct axis.x, axis.y.
%    * parameter: field in D.cen to plot (default 1st field 'zwl')
%    * idmn: plot grid with the specified domain number only (if available)
%   For user-defined paramter: simply add them to D before calling plotMapkml.
%   Cells with plot() properties, e.g. {'EdgeColor','k'}
%    * patch
%   Defaults values can be requested with OPT = dflowfm.plotNet().
%
%   Example: plot maximum velocity
%
%     ncfile    = 'WORKDIR\RUNID_map.nc';
%     G         = dflowfm.readNet(ncfile);
%     T.datenum = nc_cf_time(ncfile);
%
%     %% movie of waterlevels
%     for it=1:length(T.datenum)
%       D  = dflowfm.readMap(G,it);
%       dflowfm.plotMap(G,D);
%       caxis([-1 1])
%       colorbarwithvtext('\eta [m]')
%       title(datestr(T.datenum(it)))
%       axis equal
%       axis([100 220 540 620].*1e3)
%       tickmap('xy')
%       grid on
%       pausedisp([num2str(it)])
%     end
%
%     %% statistics of velocities
%     umax = zeros(size(G.cen.x));
%     for it=1:length(T.datenum)
%        ucx = ncread(ncfile,'ucx',[1 it],[Inf 1])';%ucx = nc_varget(ncfile,'ucx',[(it-1) 0],[1 Inf])';
%        ucy = ncread(ncfile,'ucy',[1 it],[Inf 1])';%ucy = nc_varget(ncfile,'ucy',[(it-1) 0],[1 Inf])';
%       [uth,ur] = cart2pol(ucx,ucy);
%        umax = max(umax, ur);
%     end   
%     delft3d_io_xyz('write', [filename(ncfile),'_umax.xyz'],G.cen.x,G.cen.y,umax);
%      
%     %% lay-out
%     dflowfm.plotMap(G,umax)
%     clim([0 2])
%     colorbarwithvtext('max(u) [m/s]')
%     axis equal
%     axis([100 220 540 620].*1e3)
%     tickmap('xy')
%     grid on
%     title(['Maximum velocity for in period ',datestr(T.datenum(1)),' - ',datestr(T.datenum(end))])
%
%   See also dflowfm, delft3d, readFlowGeom2tri, http://oss.deltares.nl/web/delft3d/general/-/message_boards/view_message/220151

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

% $Id: plotMap.m 14093 2018-01-12 15:32:13Z smits_bb $
% $Date: 2018-01-12 23:32:13 +0800 (Fri, 12 Jan 2018) $
% $Author: smits_bb $
% $Revision: 14093 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/plotMap.m $
% $Keywords: $

%% input

   OPT.axis      = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   % arguments to plot(x,y,OPT.keyword{:})
   OPT.patch     = {'EdgeColor','none','LineStyle','-'};
   OPT.parameter = ['zwl'];
   OPT.quiver    = 1;
   OPT.layout    = 0; % for patches
   OPT.idmn      = -1;

   if nargin==0
      varargout = {OPT};
      return
   else
      if ischar(varargin{1})
         ncfile   = varargin{1};
         
         conv = ncreadatt(ncfile,'/','Conventions');
       if strcmp(conv,'UGRID-0.9')% mapformat 1
           G      = dflowfm.readNetOld(ncfile);% edited by BS
           prefix = '';
       elseif strcmp(conv,'CF-1.6 UGRID-1.0/Deltares-0.8')% mapformat 4
           G      = dflowfm.readNet(ncfile);% edited by BS
           prefix = 'mesh2d_';
       else 
           sprintf('Current version of this script does not recognize mapformat %d',conv)% use default (mapformat 1)
           G      = dflowfm.readNetOld(ncfile);% edited by BS
           prefix = '';
       end
       
      else
         G        = varargin{1};
      end
      
      nextarg = 3;
      if ~odd(nargin)
        if isnumeric(varargin{2}) && isscalar(varargin{2}) && ischar(varargin{1}) % only output file, not input file
          it      = varargin{2};
          D       = dflowfm.readMap(ncfile,it);
        elseif isnumeric(varargin{2}) && isscalar(varargin{2}) && ~ischar(varargin{1})
          error('when timestep/data is supplied the first argument should be ''ncfile''.')
        elseif isnumeric(varargin{2}) && ~isscalar(varargin{2})
          it      = varargin{2};
          OPT.parameter     = 'auto';
	  D.cen.(OPT.parameter) = varargin{2};
          D.face.(OPT.parameter) = varargin{2};
        elseif isstruct(varargin{2})
          D       = varargin{2};
        else
          error('??')
        end
      else
        D       = dflowfm.readMap(ncfile); % readMap gets last it
        nextarg = 2;
      end
      
      OPT = setproperty(OPT,varargin{nextarg:end});
      
   end
   
   if isempty(OPT.parameter)
      flds = fieldnames(D.face);
      if isempty(flds)
         error('D.face has no fields')
      else
        OPT.parameter = flds{1};
        disp('taking first')
      end
   end
   
   if isnumeric(OPT.axis) && ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end

%% plot centres (= flow cells = circumcenters)

if ~(isfield(G,'face') && isfield(G,'edge'))

   error('unable to plot map: read BOTH the grid and map from *_map.nc (*_net.nc does not contain node connectivity!)')

else

   if isempty(OPT.axis) %&& exist('G.face.FlowElemSize','var')
%       cen.mask = 1:G.cen.n; % TO DO: check whether all surrounding corners are outside, instead of centers
      face.mask = true(1,G.face.FlowElemSize);
   else
      face.mask = inpolygon(G.face.FlowElem_x,G.face.FlowElem_y,OPT.axis.x,OPT.axis.y);
   end
   
   if ( OPT.idmn>-1 && isfield(G.face,'FlowElemDomain') )
       if ( length(G.face.FlowElemDomain)==G.face.FlowElemSize )
          face.mask = (face.mask & G.face.FlowElemDomain==OPT.idmn);
       end
   end

   % the PATCH method is slow and is superseded in favour of TRISURFCORCEN after PATCH2TRI 
   if ~(isfield(G,'tri') && isfield(G,'map3'))
   
      face.mask1 = find(face.mask(G.edge.FlowLinkType(face.mask)==1));
      face.mask  = find(face.mask(G.edge.FlowLinkType(face.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
      
%       peri.mask1 = cen.mask(peri.mask1);
%       peri.mask  = cen.mask(peri.mask);
      
      if ~iscell(G.face.FlowElemCont_x) % can also be done in readNet
        [x,y] = dflowfm.peri2cell(G.face.FlowElemCont_x(:,face.mask),G.face.FlowElemCont_y(:,face.mask));
      else
         x = G.face.FlowElemCont_x(:,face.mask);
         y = G.face.FlowElemCont_y(:,face.mask);
      end
      
   end

%% plot

   % the PATCH method is slow and is superseded in favour of TRISURFCORCEN after PATCH2TRI 
   % http://oss.deltares.nl/web/delft3d/general/-/message_boards/view_message/220151
   
   if (isfield(G,'tri') && isfield(G,'map3'))
      tri.mask = face.mask(G.map3);
   
      h = trisurfcorcen(G.tri(tri.mask,:),G.node.x,G.node.y,D.face.(OPT.parameter)(G.map3(tri.mask)));
      fprintf('We are plotting: %s \n', OPT.parameter)
      set(h,'edgeColor','none'); % we do not want to see the triangle edges as they do not exist on D-Flow FM network
      % If you want to see edges, overlay the them with plotNet.
      %shading flat; % automaticcally done by trisurfcorcen, as it is the only correct option for center values
      view(0,90);
      c=colorbar;
      c.Label.String=OPT.parameter;
      c.Label.FontSize = 12;
      %title(D.datestr) 
      
   else

      % lay out !!!! before plotting patches: much faster for patches
      if OPT.layout
         hold on
         axis equal
         grid on
         c=colorbar;
         c.Label.String=OPT.parameter;
         c.Label.FontSize = 12;
         title(D.datestr)
      end
      
      h = repmat(0,[1 length(x)]);
      for icen=1:length(x)
      % use partly trisurf
         h(icen) = patch(x{icen},y{icen},D.face.(OPT.parameter)(face.mask(icen)));
      end
      %shading flat; % not needed an slow
      set(h,OPT.patch{:});
      
   end
   
end
   
%% return handles

if nargout==1
   varargout = {h};
end
