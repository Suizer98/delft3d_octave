function varargout = plotNet(varargin)
%plotNetkml  Plot a D-Flow FM unstructured net in Google Earth
%
%     G  = dflowfm.readNet(ncfile) 
%          dflowfm.plotNetkml(G     ,<keyword,value>) % or 
%          dflowfm.plotNetkml(ncfile,<keyword,value>) 
%
%   plots a D-Flow FM unstructured net (centers, corners, contours),
%   as kml file. Note that only when G is a *_map.nc file it will contain
%   the node links, otherwise (*_net.nc) only the nodes (corner dots).
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] (default) for while grid.
%      For axis to be be a polygon, supply a struct axis.x, axis.y.
%   Struct with KML properties, if [] they are not plotted.
%    * cor:  a struct with KMLmarker properties for corners.
%    * cen:  a struct with KMLmarker properties for centers (bug still: cor overrules cen in Google Earth)
%            Set to [] if you do not want corner or center dots.
%    * peri: a struct with KMLline properties for connection line.
%            Only possible when G comes from a *_map.nc. Plotting will
%            take some time as it connects the faces in to long line segments
%            for fast viewing in Google Earth. All flow cell boundaries are
%            plotted as chained NaN-separated line: fast to plot, slow to create.
%            These data are saved to *_peri.nc for reuse with KMLline.
%
%   Defaults values can be requested with OPT = dflowfm.plotNet().
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

% $Id: plotNetkml.m 7740 2012-11-28 14:26:12Z boer_g $
% $Date: 2012-11-28 22:26:12 +0800 (Wed, 28 Nov 2012) $
% $Author: boer_g $
% $Revision: 7740 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/plotNetkml.m $
% $Keywords: $

% TO DO: to do: plot center connectors (NetElemNode)
% TO DO: to do: plot 1D cells too

%% input

%  arguments to plot(x,y,OPT.keyword{:})
   OPT.cen = struct(... % KMLmarker()
         'iconnormalState','http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png',...
        'colornormalState',[0 0 1],... % blue
        'scalenormalState',0.2,... % less is not shown in GE
                 'kmlName','flow cells (centres)',...
     'scalehighlightState',0.2); % no mouse-over
   OPT.cor  = struct(... % KMLmarker()
         'iconnormalState','http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png',...
        'colornormalState',[1 1 0],... % yellow
        'scalenormalState',0.2,... % less is not shown in GE
                 'kmlName','nodes (corners)',...
     'scalehighlightState',0.2); % no mouse-over
   OPT.axis           = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   OPT.fileName       = [];
   OPT.peri           = KMLline;
   OPT.peri.kmlName   = 'faces';
   OPT.peri.zScaleFun = @(z)(z+20).*5; % same as KMLsurf
   OPT.epsg           = 28992; % Dutch
   
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
      OPT = setproperty(OPT,varargin{2:end});
   end
   
   if isempty(OPT.fileName)
      OPT.fileName = [filepathstrname(ncfile),'.kml'];
   end
   
   if isnumeric(OPT.axis) & ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end
   
   sourceFiles = {};
   
   [tmppath,tmpname]     = fileparts(ncfile);
   
   if ~isempty(tmppath)
   tmpname = [tmppath filesep tmpname];
   end
   
%% plot corners (= nodes)

   if isfield(G,'cor') & ~isempty(OPT.cor)
   
     % TO DO check whether x and y are not already spherical 
    [cor.lon,cor.lat] = convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   
     if isempty(OPT.axis)
        cor.mask = 1:G.cor.n;
     else
        cor.mask = inpolygon(G.cor.x,G.cor.y,OPT.axis.x,OPT.axis.y);
     end
     
     sourceFiles{end+1} = [tmpname,'_cor.kml'];
     OPT.cor.fileName = sourceFiles{end};
     KMLmarker(cor.lat(cor.mask),cor.lon(cor.mask),OPT.cor);

   end

%% plot centres (= flow cells = circumcenters)

   if (isfield(G,'cen')  & ~isempty(OPT.cen) ) | ...
      (isfield(G,'peri') & ~isempty(OPT.peri))
   
     % TO DO check whether x and y are not already spherical 
    [cen.lon,cen.lat] = convertCoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     if isempty(OPT.axis)
        cen.mask = 1:G.cen.n;
     else
        cen.mask = inpolygon(G.cen.x,G.cen.y,OPT.axis.x,OPT.axis.y);
     end
     
    %cen.mask = cen.mask(1:1e4);
     
   end
   
   if isfield(G,'cen') & ~isempty(OPT.cen)
       
     sourceFiles{end+1} = [tmpname,'_cen.kml'];
     OPT.cen.fileName = sourceFiles{end};
     KMLmarker(cen.lat(cen.mask),cen.lon(cen.mask),OPT.cen);
   
   end

%% plot perimeters (= contours = flow cell faces)
%  plot contour of all circumcenters inside axis 
%  Always plot entire perimeter, so perimeter is partly 
%  outside axis for boundary flow cells. 
%  We turn all contours into a nan-separated polygon. 
%  After plotting this is faster than patches (only one figure child handle).

   if isfield(G,'peri') & ~isempty(OPT.peri)
       
     %% OLD method, SLOW in GE, but fast to generate
     %  peri.mask1 = find(cen.mask(G.cen.LinkType(cen.mask)==1));
     %  peri.mask  = find(cen.mask(G.cen.LinkType(cen.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
     %  
     %  if ~iscell(G.peri.x) % can also be done in readNet
     %    [x,y] = dflowfm.peri2cell(G.peri.x(:,peri.mask),G.peri.y(:,peri.mask));
     %     x    = poly_join(x);
     %     y    = poly_join(y);
     %  else
     %     x    = poly_join({G.peri.x{peri.mask}});
     %     y    = poly_join({G.peri.y{peri.mask}});
     %  end
     
     %% NEW method, FAST in GE, but slower to generate
     sourceFiles{end+1} = [tmpname,'_peri.kml'];
     OPT.peri.fileName = sourceFiles{end};
     
     if isfield(G.cor,'z')
    [peri.x peri.y peri.z]=tri2poly(G.cor.Link',G.cor.x,G.cor.y,G.cor.z,'log',2);
     else
    [peri.x peri.y       ]=tri2poly(G.cor.Link',G.cor.x,G.cor.y        ,'log',2);
     end
     
    % TO DO check whether x and y are not already spherical 
    [peri.lon,peri.lat] = convertCoordinates(peri.x,peri.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     
     struct2nc([tmpname,'_peri.nc'],peri);
     
     disp('plotting KMLline segments, please wait ...')
     if isfield(G.cor,'z')
     h = KMLline(peri.lat,peri.lon,peri.z,OPT.peri);
     else
     h = KMLline(peri.lat,peri.lon       ,OPT.peri);
     end
   
   elseif ~isempty(OPT.peri)
      disp('Cell boundaries (peri) not present in file, not plotted.')
   end
   
   KMLmerge_files('fileName',OPT.fileName,'sourceFiles',sourceFiles,'deleteSourceFiles',0,'distinctDocuments',1)

   varargout = {0};