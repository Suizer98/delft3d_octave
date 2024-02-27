function delft3d_3d2kml_visualisation_example(varargin)
%DELFT3D_3D2KML_VISUALISATION_EXAMPLE   Example to make 3D graphics from delft3d trim file
%
%See also: VS_MESHGRID3DCORCEN, VS_TIME, VS_LET_SCALAR, VS_LET_VECTOR_CEN, googleplot

%% settings

   OPT.fname     = 'E:\Work\001_Rags\run_7\trim-rags_run7.dat';
   OPT.uvscale   = 1e4; % 1 m/s becomes x m
   OPT.clim      = [-1 1];
   OPT.epsg      = 28992;
   OPT.zscalefun = @(z)(z).*1e4+2e4; 
   OPT.dm          = 3; % cross shore stride % do not plot all points as matlab is too slow for that (and the human mind too limited)
   OPT.dn          = 3; % along shore stride
   OPT.hslice      = 0;
   OPT.u           = 1;
   OPT.isoname     = 'zwl';
 
%% initialize

   H = vs_use (OPT.fname);
   T = vs_time(H);
   G = vs_meshgrid2dcorcen(H);

   sourcefiles.hslice = {};
   sourcefiles.u      = {};
   OPT.dir            = fileparts(OPT.fname);
   OPT.it             = [1:3:39];
   
for it=1:length(OPT.it)-1; %1:T.nt_storage-1 % add one extra time to specify toem window in Google Earth
   
   %% load 3D data, incl time-varying grid

      % grid, incl waterlevel which determines z grid spacing
      G                = vs_meshgrid3dcorcen     (H, OPT.it(it), G);
   
      % horizontal velocities
     [D.cen.u,D.cen.v] = vs_let_vector_cen       (H,'map-series',{OPT.it(it)},{'U1','V1'}, {0,0,0});
      D.cen.u          = permute(D.cen.u,[2 3 4 1]);
      D.cen.v          = permute(D.cen.v,[2 3 4 1]);
     [~,D.cen.U]       = cart2pol(D.cen.u,D.cen.v);
      D.cen.zwl        = G.cen.zwl; % copy data needed for surface plot
     
   %% Google Earth need lat,lon

      [G.cen.cent.lon,G.cen.cent.lat] = convertCoordinates(G.cen.cent.x,G.cen.cent.y,'CS1.code',OPT.epsg,'CS2.code',4326);
      [G.cor.cent.lon,G.cor.cent.lat] = convertCoordinates(G.cor.cent.x,G.cor.cent.y,'CS1.code',OPT.epsg,'CS2.code',4326);
      
      G.cen.cent.lon = reshape(G.cen.cent.lon,size(G.cen.cent.x));
      G.cen.cent.lat = reshape(G.cen.cent.lat,size(G.cen.cent.x));
      G.cor.cent.lon = reshape(G.cor.cent.lon,size(G.cor.cent.x));
      G.cor.cent.lat = reshape(G.cor.cent.lat,size(G.cor.cent.x));
     
   %% horizontal scalar slices
   
      OPT.isoval = 1;
      dn         = 1; % chose overall stride: note: corner center issue with cor/cen if not 1
      dm         = 1;

      if OPT.hslice
   
      for k= [1];

      sourcefiles.hslice{end+1} = [OPT.dir,filesep,'KMLsurf_',num2str(OPT.isoval,'%3.1f'),'iso_',num2str(k,'%0.3d'),'_',num2str(OPT.it(it),'%0.3d'),'.kml'];
      
      KMLsurf(permute(G.cor.cent.lat     (1:dn:end,1:dm:end,k),[1 2 3])',...
              permute(G.cor.cent.lon     (1:dn:end,1:dm:end,k),[1 2 3])',...
              permute(G.cor.cent.z       (1:dn:end,1:dm:end,k),[1 2 3])',...
              permute(D.cen.(OPT.isoname)(1:dn:end,1:dm:end,k),[1 2 3])',...
               'fileName',sourcefiles.hslice{end},...
              'fillAlpha',1,...
              'zScaleFun',OPT.zscalefun,...
               'colorbar',0,...
                   'cLim',OPT.clim,...
                 'timeIn',T.datenum(OPT.it(it  )),...
                'timeOut',T.datenum(OPT.it(it+1)));
      end

      end
   
   %% 3D velocity field
   
      if OPT.u
      
      dn         = OPT.dn; % choose overall stride
      dm         = OPT.dm;
        
      for k = [1];
      sourcefiles.u{end+1}      = [OPT.dir,filesep,'KMLquiver3_',num2str(k,'%0.3d'),'_',num2str(OPT.it(it),'%0.3d'),'.kml'];
      KMLquiver3(G.cen.cent.lat(1:dn:end,1:dm:end,k),...
                 G.cen.cent.lon(1:dn:end,1:dm:end,k),...
                 G.cen.cent.z  (1:dn:end,1:dm:end,k),...
                 D.cen.v       (1:dn:end,1:dm:end,k).*OPT.uvscale,...
                 D.cen.u       (1:dn:end,1:dm:end,k).*OPT.uvscale,...
               'fileName',sourcefiles.u{end},...
                'kmlName',['t=',num2str(OPT.it(it),'%0.3d'),' k=',num2str(k)],...
             'arrowStyle','line',...
              'lineColor',[1 1 1].*k/G.kmax,... % make color differ per layer
              'zScaleFun',OPT.zscalefun,...
                 'timeIn',T.datenum(OPT.it(it  )),...
                'timeOut',T.datenum(OPT.it(it+1)));
      end

      end 	
   
end % it

%% merge layers and timesteps

   if ~isempty(sourcefiles.u)
   KMLmerge_files('sourceFiles',sourcefiles.u,...
                  'description','black  = surface, gray = middepth, white = bottom',...
                      'kmlName','velocities',...
                     'fileName',[OPT.dir,filesep,filename(OPT.fname),'_quiver.kml'],...
            'deleteSourceFiles',1);
   end         
            
   if ~isempty(sourcefiles.hslice)
   KMLmerge_files('sourceFiles',sourcefiles.hslice,...
                  'description','',...
                      'kmlName','salinity',...
                     'fileName',[OPT.dir,filesep,filename(OPT.fname),'_hslice_',num2str(OPT.isoval),'iso.kml'],...
            'deleteSourceFiles',0);
   end         

%% EOF