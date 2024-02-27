function OPT = delft3d_grd2kml(grdfile,varargin)
%DELFT3D_GRD2KML   Save grid (and depth) file as kml feed for Google Earth
%
%   delft3d_grd2kml(grdfile,<keyword,value>)
%
%   Input:
%      grdfile    = filename of the grd file
%   varargin:
%       epsg      = epsg code of the grid
%       dep       = filename of the dep file
%       mdf       = name of mdf file toretrieve dpsopt
%       dpsopt    = only when mdf not specified: dpsopt in mdf file 
%                   to specify location of depth values in *.dep filee.g. 'max','mean', 'dp'
%       linecolor = color of the grid lines
%
%   Output:
%   filemask = filemask of the grd files to be processed
%
% Note: that the grid file need to be of Spherical type
%       or you must specify epsg code.
% Note: for surf you must change reversePoly if the grid cells are too 
%       dark during the day, and light during the night.
%
% Example 1:
%   delft3d_grd2kml('i:\R1501_Grootschalige_modellen\roosters\A2275_western_mediterranean_r02.grd');
%
% Example 2:
%   delft3d_grd2kml('g04.grd','epsg',28992,'dep','g04.dep','dpsopt','mean',...
%                    'zScaleFun',@(z) (z+10)*100,'cLim',[-50 25])
%
%See also: googlePlot, delft3d, delft3d_mdf2kml

% updated by Bart Grasmeijer, Alkyon Hydraulic Consultancy & Research 19 November 2009

   OPT2             = KMLpcolor;
   OPT2.reversePoly = true;
   OPT2.colorSteps  = 62;
   OPT2.lineColor   = [.5 .5 .5];
   OPT2.kmlName     = 'depth [m]';
   OPT2.lineWidth   = 0; % to prevent rastering of the pixels (WHY?)
   OPT2.polyOutline = true;
   OPT2.polyFill    = true;

   % defaults for Dutch vaklodingen
   OPT2.cLim        = [-50 25]; % limits of color scale
   OPT2.colorMap    = @(m) colormap_cpt('bathymetry_vaklodingen',m);
   OPT2.colorSteps  = 500;
   
   OPT = OPT2;
   OPT.epsg        = [];  % 28992; % 7415; % 28992; ['Amersfoort / RD New']
   OPT.debug       = 0;

   OPT.dep         = [];  %'dep_at_cor_triangulated_filled_corners.dep';
   OPT.mdf         = [];  % or dpsopt
   OPT.dpsopt      = [];  % or mdf
   
   if nargin==0
      return
   end

   OPT  = setproperty(OPT ,varargin);
   OPT2 = setproperty(OPT2,varargin,'onExtraField','silentIgnore');
   
   G = delft3d_io_grd('read',grdfile);
   
   if     ~strcmpi(G.CoordinateSystem,'spherical') & isempty(OPT.epsg)
      error('no latitide and longitudes given')
   elseif    strcmpi(G.CoordinateSystem,'spherical')  
       G.cor.lon = G.cor.x;
       G.cor.lat = G.cor.y;
   elseif ~strcmpi(G.CoordinateSystem,'spherical')  
      [G.cor.lon,G.cor.lat,CS]=convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   end

   if ~isempty(OPT.mdf)
      MDF        = delft3d_io_mdf('read',OPT.mdf);
      OPT.dpsopt = MDF.keywords.dpsopt;
   end
   
   %% check for spherical !!
   
   if ~isempty(OPT.dep)
      G = delft3d_io_dep('read',OPT.dep,G,'dpsopt',OPT.dpsopt);
   else
      G.cen.dep     = 0.*G.cen.x;
      G.cor.dep     = 0.*G.cor.x;
      OPT.fillAlpha = 1;
   end
   
   disp(['min z & cLim(1): ',num2str(min(-G.cor.dep(:))),' & ',num2str(OPT2.cLim(1))]);
   disp(['max z & cLim(2): ',num2str(max(-G.cor.dep(:))),' & ',num2str(OPT2.cLim(2))]);
   
   if OPT.debug
       TMP = figure;
       pcolorcorcen(G.cor.lon,G.cor.lat,-G.cor.dep);
       caxis([OPT.clim]);
       colorbarwithtitle('depth [m]');
       pausedisp
       try
           close(TMP);
       end
   end
   stride      = 1;  
   OPT2.fileName = [filename(grdfile),'_3D.kml'];
   OPT2.kmlName = [OPT2.kmlName, ' 3D'];
   KMLsurf  (G.cor.lat(1:stride:end,1:stride:end),...
             G.cor.lon(1:stride:end,1:stride:end),...
            -G.cor.dep(1:stride:end,1:stride:end),OPT2);
         
   OPT2.fileName  = [filename(grdfile),'_2D.kml'];
   OPT2.kmlName = regexprep(OPT2.kmlName, '3D$', '2D');
   OPT2.zScaleFun =  @(z)'clampToGround';
   KMLpcolor(G.cor.lat,G.cor.lon,-G.cen.dep,OPT2);

   OPT2.fileName  = [filename(grdfile),'_mesh.kml'];
   KMLmesh  (G.cor.lat,G.cor.lon,'fileName',OPT2.fileName);

%%EOF