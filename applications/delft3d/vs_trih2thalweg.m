function varargout = vs_trih2thalweg(vsfile,varargin)
%vs_trih2thalweg x-sigma plane (cross-section, thalweg) from delft3 history file
%
%  vs_trih2thalweg(vsfile,<keyword,value>) converts trih file to netCDF
%  using only obs points indicated with keyword 'ind'. Then loads
%  netCDF ans makes movie of thalweg plots.
%
% Example:
%
% vs_trih2thalweg('d:\project\run007\trih-2009_1.def','ind',[30:40 52:59],'epsg',28992)
%
%See also: pcolorcorcen_sigma, vs_use, vs_trih2nc

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_trih2thalweg.m 8362 2013-03-20 16:29:15Z boer_g $
%  $Date: 2013-03-21 00:29:15 +0800 (Thu, 21 Mar 2013) $
%  $Author: boer_g $
%  $Revision: 8362 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trih2thalweg.m $
%  $Keywords: $

OPT.ncfile    = '';
OPT.epsg      = 28992; % epsg projection to do interpolation in and plot distances in
OPT.ind       = 28:766; % indices (from *.obs) to interpolate from
OPT.wscale    = 100;   % exageration of vertical velocities in plot
OPT.pause     = 0;
OPT.kml       = 'Thalweg.kml'; % endvertices of thalweg drawn in google earth
OPT.nkml      = 20; % number of subdivisions between kml endvertices
OPT.txtleft   = 'Den Helder';
OPT.txtright  = 'Texel';
OPT.txtebb    = 'EBB to North Sea';
OPT.txtflood  = 'FLOOD to Wadden Sea';
OPT.ulegendx  = 500;
OPT.ulegendz  = -25;
OPT.pngsubdir = 'teso'; % subdir of dir of vsfile
OPT.shading   = 'hybrid'; % {'interp','stretched','hybrid','flat'};
OPT.plot      = 0;

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

%% get data

   h = vs_use(vsfile,'quiet');

%% get coordinate data for spatial interpolation
   
   coordinates = permute(vs_let(h,'his-const','COORDINATES'      ,'quiet'),[2 3 1]);
   if any(strfind(lower(coordinates),'cart'))
   D.x    = permute(vs_let(h,'his-const' ,'XYSTAT',{1 OPT.ind},'quiet'),[3 2 1]);
   D.y    = permute(vs_let(h,'his-const' ,'XYSTAT',{2 OPT.ind},'quiet'),[3 2 1]);
   [D.lon,D.lat] = convertCoordinates(D.x,D.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   else
   D.lon  = permute(vs_let(h,'his-const' ,'XYSTAT',{1 OPT.ind},'quiet'),[3 2 1]);
   D.lat  = permute(vs_let(h,'his-const' ,'XYSTAT',{2 OPT.ind},'quiet'),[3 2 1]);
   [D.x,D.y] = convertCoordinates(D.lon,D.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
   end
   
   if isempty(OPT.ncfile)
      OPT.ncfile = [filepathstrname(vsfile),'_thalweg.nc'];
   end

   if ~exist(OPT.ncfile)
      vs_trih2nc(vsfile,OPT.ncfile,'ind',OPT.ind,'trajectory',1,'epsg',OPT.epsg);
   else
      disp(['For plotting used existing netCDF file: ',OPT.ncfile])
   end
   
   D = nc2struct(OPT.ncfile);

%% interpolate to ship track, drawn as kml in google earth
%  (idea: use arbcross after connecting dots into small matrix?)

   %L = nc2struct('d:\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc','include',{'lon','lat'})
   [T.lat,T.lon] = KML2Coordinates(OPT.kml);   
   %T.lat = linspace(T.lat(1),T.lat(2),38);
   %T.lon = linspace(T.lon(1),T.lon(2),38);
   
   [T.x,T.y] = convertCoordinates(T.lon,T.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
   [D.PI,D.RI,D.WI] = griddata_near1(D.x,D.y,        T.x,T.y,2);
   T.waterlevel     = griddata_near2(D.x,D.y,permute(D.waterlevel,[2 1]),T.x,T.y,D.PI,D.WI);
   T.depth          = griddata_near2(D.x,D.y,D.depth                    ,T.x,T.y,D.PI,D.WI);
   
   fields = {'u_x','u_y','u_z','salinity','temperature'};
   
   T.kmax = size(D.u_x,3);
   T.nt   = size(D.u_x,1);
   for ifld=1:length(fields)
       fld = fields{ifld};
       T.(fld) = repmat(T.waterlevel.*nan,[T.kmax 1 1 1]);
       for k=1:T.kmax
       T.(fld)(k,:,:) = griddata_near2(D.longitude,D.latitude,permute(D.(fld)(:,:,k),[2 1]),T.lon,T.lat,D.PI,D.WI);
       end
   end
   T.datenum     = D.datenum;
   T.track       = distance(T.x,T.y);
   T.track_b     = center2corner1(T.track,'nearest'); % bounds for shading flat
   T.depth_b     = center2corner1(T.depth,'nearest'); % bounds for shading flat
   T.Layer       = D.Layer;
   T.LayerInterf = D.LayerInterf;
   
   T.sigma2plot      = T.Layer;
   T.sigma2plot(1)   = 0;
   T.sigma2plot(end) = -1;

%% rotate to cross/along polygon

   fprintf(2,'ERROR: VELOCITIES NEED TO BE ROTATED TO PLAN OF TRACK\n')

%% thalweg plot

if OPT.plot

   close
   AX = subplot_meshgrid(2,1,.05,[.01 .04],[nan .05],nan);axes(AX(1))
   hold on
   colormap(clrmap([1 0 0;.95 .95 .95;0 0 1],18))
   clim([-1.5 1.5])
   xlim([0 T.track(end)])
   ylim([-27 2])
   colorbarwithvtext([OPT.txtebb,' - along channel velocity -',OPT.txtflood],'position',get(AX(2),'position'))
   delete(AX(2))
   tickmap('x','format','%0.1f')
   hlegu = arrow2(OPT.ulegendx,OPT.ulegendz,1,OPT.wscale*0,2);
   hlegv = arrow2(OPT.ulegendx,OPT.ulegendz,0,OPT.wscale*0.01,2);
   text       (OPT.ulegendx,OPT.ulegendz,{'1 m/s'} ,'vert','top','horizontalalignment','cen');
   text       (OPT.ulegendx,OPT.ulegendz,{'1 cm/s',''},'vert','top','horizontalalignment','left','verticalalignment','bot','rotation',90);
   
   plot([1e3 1250],[-24 -24],'--k','linewidth',3);plot([1250 1500],[-24 -24],'-k','linewidth',3)
   plot([1e3 1250],[-25 -25],'--k','linewidth',2);plot([1250 1500],[-25 -25],'-k','linewidth',2)
   plot([1e3 1250],[-26 -26],'--k','linewidth',1);plot([1250 1500],[-26 -26],'-k','linewidth',1)
   plot(1400,-23,'ko','markersize',10,'MarkerFaceColor','b')
   plot(1400,-23,'ko','markersize',4 ,'MarkerFaceColor','k')
   plot(1100,-23,'ko','markersize',10,'MarkerFaceColor','r')
   plot(1100,-23,'kx','markersize',10)
   text(1500,-25,{' 0.5 m/s',' 0.2 m/s',' 0.1 m/s'})
   text(xlim1(1),ylim1(1),[' \uparrow '  ,OPT.txtleft] ,'rotation',90,'verticalalignment','top')
   text(xlim1(2),ylim1(1),[' \downarrow ',OPT.txtright],'rotation',90,'verticalalignment','bottom')
   grid on
   
   for it=100:T.nt
       
      disp([num2str(it),'/',num2str(T.nt)])

      if strcmpi(OPT.shading,'hybrid') || strcmpi(OPT.shading,'flat')
      T.waterlevel_b = center2corner1(T.waterlevel(1,:,it),'nearest'); % bounds for shading flat
      end
      if strcmpi(OPT.shading,'flat')
      h0 = plot(T.track_b,-T.depth_b,'linewidth',3,'color',[.6 .3 0]);
      else
      h0 = plot(T.track  ,-T.depth  ,'linewidth',3,'color',[.6 .3 0]);
      end

      % shading interp with 2 layer of shading flat for bands near free surface and bed
      if strcmpi(OPT.shading,'hybrid')
      hs = pcolorcorcen_sigma(T.track_b,T.LayerInterf(    1:2  ),T.waterlevel_b,T.depth_b, T.u_x(  1,:,it));
      %some mismatch for nottom spikes
      hb = pcolorcorcen_sigma(T.track_b,T.LayerInterf(end-1:end),T.waterlevel_b,T.depth_b, T.u_x(end,:,it));
      set(hs,'EdgeColor','none')
      set(hb,'EdgeColor','none')
      end
      
      % shading interp: white bands near free surface and bed
      if strcmpi(OPT.shading,'hybrid') | strcmpi(OPT.shading,'interp')
      h1 = pcolorcorcen_sigma(T.track,T.Layer,T.waterlevel(1,:,it),T.depth, T.u_x(:,:,it));
      T.S = get(h1,'XData');
      T.Z = get(h1,'YData');
      
      % shading interp strechted to fill white bands near free surface and bed
      elseif strcmpi(OPT.shading,'stretched')
      h1 = pcolorcorcen_sigma(T.track,T.sigma2plot,T.waterlevel(1,:,it),T.depth, T.u_x(:,:,it));
      T.S = get(h1,'XData');
      T.Z = get(h1,'YData');
      
      % shading flat
      elseif strcmpi(OPT.shading,'flat')
      h1 = pcolorcorcen_sigma(T.track_b,T.LayerInterf,T.waterlevel_b,T.depth_b, T.u_x(:,:,it));
      T.S = get(h1,'XData');T.S = T.S(1:end-1,1:end-1);
      T.Z = get(h1,'YData');T.Z = T.Z(1:end-1,1:end-1);
      end
      
      [~,h2a] = contour(T.S,T.Z,T.u_y(:,:,it),[-.5 -.5],'--k','linewidth',3);
      [~,h2b] = contour(T.S,T.Z,T.u_y(:,:,it),[-.2 -.2],'--k','linewidth',2);
      [~,h2c] = contour(T.S,T.Z,T.u_y(:,:,it),[-.1 -.1],'--k','linewidth',1);
      [~,h2d] = contour(T.S,T.Z,T.u_y(:,:,it),[  0   0],':k' ,'linewidth',1);
      [~,h2e] = contour(T.S,T.Z,T.u_y(:,:,it),[ .1  .1], '-k','linewidth',1);
      [~,h2f] = contour(T.S,T.Z,T.u_y(:,:,it),[ .2  .2], '-k','linewidth',2);
      [~,h2g] = contour(T.S,T.Z,T.u_y(:,:,it),[ .5  .5], '-k','linewidth',3);
      h3 = plot(T.track,T.waterlevel(:,:,it),'k');
      h4 = arrow2(T.S,T.Z,T.u_y(:,:,it),OPT.wscale*T.u_z(:,:,it),2);
      ht = text(0,1,datestr(T.datenum(it),' yyyy-mmm-dd HH:MM'),'units','normalized','verticalalignment','top');
      
      [csal,hsal]=contour(T.S,T.Z,T.salinity(:,:,it),[10:.5:35],'-w','linewidth',1);clabel(csal,hsal)

      print2screensizeoverwrite([fileparts(vsfile),filesep,OPT.pngsubdir,filesep,filename(OPT.ncfile),'_',datestr(T.datenum(it),'yyyy-mmm-dd_HHMM')])

      if OPT.pause
      pausedisp
      end
      delete(h0,h1,h3,h4.head,h4.shaft,ht)
      try;delete(h2a );end
      try;delete(h2b );end
      try;delete(h2c );end
      try;delete(h2d );end
      try;delete(h2e );end
      try;delete(h2f );end
      try;delete(h2g );end
      try;delete(hs  );end
      try;delete(hb  );end
      try;delete(hsal);end

   end % t

end % plot