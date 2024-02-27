function varargout = plotMapKML(varargin)
%plotMapkml Plot a D-Flow FM unstructured map.
%
%     G  = dflowfm.readNet   (ncfile) 
%     D  = dflowfm.readMap   (ncfile,<it>) 
%    <h> = dflowfm.plotMapkml(G,D,<keyword,value>) 
%          % or 
%    <h> = dflowfm.plotMapkml(ncfile,<it>,<keyword,value>);
%
%   plots a D-Flow FM unstructured map, optionally the handles h are returned.
%   For plotting multiple timesteps it is most efficient
%   to read the unstructured grid G once, and update D and plotMapkml.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] for whole grid.
%            for axis to be be a polygon, supply a struct axis.x, axis.y.
%    * parameter: field in D.cen to plot (default 1st field 'zwl')
%   For user-defined parameter: simply add them to D before calling plotMapkml.
%   Defaults values can be requested with OPT = dflowfm.plotMapKML().
%
%   Note: every flow cell is plotted individually as a patch: slow.
%
%   See also dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

% $Id: plotMapkml.m 8139 2013-02-20 07:49:58Z scheel $
% $Date: 2013-02-20 15:49:58 +0800 (Wed, 20 Feb 2013) $
% $Author: scheel $
% $Revision: 8139 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/plotMapkml.m $
% $Keywords: $

%% input

   OPT.axis         = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   % arguments to plot(x,y,OPT.keyword{:})
   OPT.patch        = {'EdgeColor','none','LineStyle','-'};
   OPT.parameter    = [];
   OPT.quiver       = 1;
   OPT.fileName     = '';
   % good value for plotting z (depth)
   OPT.colorMap     = @(m)colormap_cpt('bathymetry_vaklodingen',m);
   OPT.colorSteps   = 500;
   OPT.CBcolorTitle = 'depth [m]';
   OPT.cLim         = [-50 25];
   OPT.epsg         = 28992;

   if nargin==0
      varargout = {OPT};
      return
   else
      if ischar(varargin{1})
      ncfile   = varargin{1};
      G        = dflowfm.readNet(ncfile);
      else
      G        = varargin{1};
      ncfile   = G.file.name;
      end
      
      nextarg = 3;
      if ~odd(nargin)
        if isnumeric(varargin{2}) & ischar(varargin{1}) % only output file, not input file
          it      = varargin{2};
          D       = dflowfm.readMap(ncfile,it);
        elseif isstruct(varargin{2})
          D       = varargin{2};
        else
          error('when timestep is supplied the first argument should be ''ncfile''.')
        end
      else
        D       = dflowfm.readMap(ncfile); % readMap gets last it
        nextarg = 2;
      end
      
      OPT = setproperty(OPT,varargin{nextarg:end});
      
   end
   
   if isempty(OPT.parameter)
      flds = fieldnames(D.cen);
      if length(flds)==0
         error('D.cen has no fields')
      else
        OPT.parameter = flds{1};
      end
   end
   
   if isnumeric(OPT.axis) & ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end

%% plot centres (= flow cells = circumcenters)

if isfield(G,'peri')

   if isempty(OPT.axis)
      cen.mask = 1:G.cen.n;
   else
      cen.mask = inpolygon(G.cen.x,G.cen.y,OPT.axis.x,OPT.axis.y);
   end
   
   peri.mask1 = find(cen.mask(G.cen.LinkType(cen.mask)==1));
   peri.mask  = find(cen.mask(G.cen.LinkType(cen.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
   
  % TO DO check whether x and y are not already spherical 
  [G.peri.lon,G.peri.lat] = convertCoordinates(G.peri.x,G.peri.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   
   if ~iscell(G.peri.x) % can also be done in readNet
     [lon,lat] = dflowfm.peri2cell(G.peri.lon(:,peri.mask),G.peri.lat(:,peri.mask));
   else
      lon = G.peri.lon;
      lat = G.peri.lat;
   end

%% plot

   nn=length(lon);
   
   c = D.cen.(OPT.parameter)(peri.mask);
   
   clf
   plot(c)
   
   % TO DO adapt KMLpatch3 to accept constant z (value of 'clamptoground')
   
   KMLpatch3({lat{1:nn}},{lon{1:nn}},{lon{1:nn}},c(1:nn),...
      'fileName',OPT.fileName,...
      'colorMap',OPT.colorMap,...
    'colorSteps',OPT.colorSteps,...
  'CBcolorTitle',OPT.CBcolorTitle,...
     'fillAlpha',1,...
          'cLim',OPT.cLim,...
       'extrude',0);
end
   
%% return handles

if nargout==1
   varargout = {[]};
end
