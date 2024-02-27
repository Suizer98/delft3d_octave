function vs_trim2netcdf2kml
%vs_trim2nc2kml   exmaple script how visualize delft3d results in google earth
%
% This is an example script, rework it untill it fits your needs.
%
% Plots: scalers as patches + vectors + lay-out items.
%
% use VS_TRIM2NC first, as we should use the delft3d NEFIS file any more (trim*).
%
% The result of this script can be found here:
%  http://kml.deltares.nl/kml/deltares/q4408-mkm/stationair2/
%
%See also: DELFT3D, GOOGLEPLOT, DELFT3D_3D2KML_VISUALISATION_EXAMPLE, DELFT3D_3D_VISUALISATION_EXAMPLE

   base_name = 'D:\PROJECTS\q4408-mkm\flow\stationair2\';

   OPT.ldb.basis_ks005    = {};
   OPT.legends.basis_ks005 = 'Current situation';
   OPT.legends.basis_ks005 = {'EE wind 10m/s' ,...
                              'NE wind 10m/s',...
                              'NN wind 10m/s',...
                              'SE wind 10m/s',...
                              'SS wind 10m/s',...
                              'SW wind 10m/s',...
                              'WW wind 10m/s',...
                              'NW wind 10m/s',...
                             };
   OPT.RUNIDs.basis_ks005 = {'b10' ,...
                             'b20',...
                             'b30',...
                             'b80',...
                             'b70',...
                             'b60',...
                             'b50',...
                             'b40',...
                             };

   OPT.alternatives       = {'basis_ks005'}; % subfield of OPT.RUNIDs
   
   OPT.subdirectories      = {'ee10_0' ,...
                              'ne10_0' ,...
                              'nn10_0' ,...
                              'se10_0' ,...
                              'ss10_0' ,...
                              'sw10_0' ,...
                              'ww10_0' ,...
                              'nw10_0' ,...
                              };   

%% Loop ialternatives

for ialternative = 1:length(OPT.alternatives)

   disp(['alternative: ',num2str(ialternative),' / ',num2str(length(OPT.alternatives))])

   OPT.alternative = OPT.alternatives{ialternative};

%% Load alternative specific landboundary

   if ~isempty(OPT.ldb.(mkvar(OPT.alternative)))

      OPT.files.ldb  = [OPT.ldb.(mkvar(OPT.alternative))];
      for ipol=1:length(OPT.ldb.(mkvar(OPT.alternative)))
     [ALT(ipol).x  ,ALT(ipol).y  ]=landboundary('read',[base_name,OPT.files.ldb{ipol}]);
     [ALT(ipol).lon,ALT(ipol).lat]=convertcoordinates(ALT(ipol).x,ALT(ipol).y,'CS1.code',28992,'CS2.code',4326);
      end
      
   else
      
      ALT = [];

   end

   %% Loop meteo cases

   for iRUNID = 1:length(OPT.RUNIDs.(mkvar(OPT.alternative)))
   
      disp(['   RUNID: ',num2str(iRUNID),' / ',num2str(length(OPT.RUNIDs.(mkvar(OPT.alternative))))])

      OPT.subdirectory = OPT.subdirectories{iRUNID};
      OPT.RUNID        = OPT.RUNIDs.(mkvar(OPT.alternative)){iRUNID};
      OPT.legend       = OPT.legends.(mkvar(OPT.alternative)){iRUNID};

      if     strcmp(OPT.subdirectory(3:4),'10')
         OPT.beaufort = '[Beaufort 5]';
      elseif strcmp(OPT.subdirectory(3:4),'25')
         OPT.beaufort = '[Beaufort 10]';
      end

   %% Load data
   
      cd([base_name, filesep 'kml']);
   
      ge_name =                   [OPT.alternative,'_',OPT.subdirectory];
      nc_name = fullfile(base_name,OPT.alternative,    OPT.subdirectory,['trim-',OPT.RUNID,'.nc' ]);
      vs_name = fullfile(base_name,OPT.alternative,    OPT.subdirectory,['trim-',OPT.RUNID,'.dat']);
      md_name = fullfile(base_name,OPT.alternative,    OPT.subdirectory,[        OPT.RUNID,'.mdf']);
      
      if ~exist(nc_name)
        vs_trim2nc(vs_name,nc_name,'epsg',28992,'time',5)
      end
   
      ncname.eta = nc_varfind(nc_name,'attributename','standard_name','attributevalue','sea_surface_elevation');
      ncname.u   = nc_varfind(nc_name,'attributename','standard_name','attributevalue','sea_water_x_velocity');
      ncname.v   = nc_varfind(nc_name,'attributename','standard_name','attributevalue','sea_water_y_velocity');
      D.eta  = nc_varget(nc_name,ncname.eta);
      D.u    = nc_varget(nc_name,ncname.u);
      D.v    = nc_varget(nc_name,ncname.v);
      D.x    = nc_varget(nc_name,'x');
      D.y    = nc_varget(nc_name,'y');
      D.lon  = nc_varget(nc_name,'longitude');
      D.lat  = nc_varget(nc_name,'latitude');
      D.lonc = nc_varget(nc_name,'longitude_cor');
      D.latc = nc_varget(nc_name,'latitude_cor');
      
      %% Load wind

      MDF     = delft3d_io_mdf('read',md_name);
      WND     = delft3d_io_wnd('read',[fileparts(md_name),filesep,MDF.keywords.filwnd],MDF.keywords);
     [WND.data.u,...
      WND.data.v] = pol2cart(deg2rad(degn2deguc(WND.data.direction(end))),...
                                                WND.data.speed(end));
                                                
   %% plot      
   
      OPT.clim     = [-0.25 -0.15]; % average is -0.2
      OPT.colormap = colormapbluewhitered(50);
      OPT.varname  = 'eta';
      OPT.Uscale   = 1e4;
      OPT.wndscale = 1e3;
      
     %FIG = figure('Visible','Off');
      h   = pcolorcorcen(D.lonc,D.latc,D.eta);
      set(h,'edgecolor','none')
     %material  ([.90 0.08 .07]);
      material  ([.88 0.11 .08]);
      lighting   phong
      axis       off;
      axis       tight;
      view      (0,90);
      lightangle(0,90)
      clim      (OPT.clim);
      colormap  (OPT.colormap);
      
   %% kml of scalar
   
      clear sourcefiles
      sourcefiles{1} =  [ge_name,'_eta.kml'];
      KMLfig2pngNew(h,D.latc,D.lonc,D.(OPT.varname),...
                      'kmlName','waterlevel',...
                      'visible',iRUNID==1,...                     
                 'highestLevel',1,...
                  'lowestLevel',12,...
           'mergeExistingTiles',false,...
                      'bgcolor',[255 0 255],...
              'CBcolorbartitle','water level (NAP) [m] (arrows: black=surface, gray = bottom)',...
                     'fileName',sourcefiles{1});
      
      try;close(FIG);end
   
   %% wind (above velocity legend text as 1st one visible when zoomed out)
      
      sourcefiles{end+1} = [ge_name,'_windlegendt.kml'];
      KMLtext  (52.37,5.45,{OPT.legend},...
                      'kmlName','wind condition text',...
                      'visible',iRUNID==1,...                     
                     'fileName',sourcefiles{end});
   
      sourcefiles{end+1} = [ge_name,'_windlegendq.kml'];
      KMLquiver(52.37,5.45,OPT.wndscale.*WND.data.v,OPT.wndscale.*WND.data.u,... % note v and u
                    'kmlName'  ,'wind condition arrow (green)',...
                    'fileName' ,sourcefiles{end},...
                    'lineWidth',.5,'lineColor',[0 1 0],...
                      'visible',iRUNID==1,...                     
                    'fillColor',[0 1 0]);
   %% kml of u top
   
OPT.period = 1200   
        dn = 1; % full velocity field
      
      sourcefiles{end+1} = [ge_name,'_utop.kml'];
      KMLcurvedArrows(D.x(1:dn:end,1:dn:end),...
                      D.y(1:dn:end,1:dn:end),...
         permute(D.u(  1,1:dn:end,1:dn:end),[2 3 1]),... % u first
         permute(D.v(  1,1:dn:end,1:dn:end),[2 3 1]),... % v second
                         'time',[],'interp_steps',0,...
                      'kmlName','velocity surface (black)',...
                     'n_arrows',250,'fileName',sourcefiles{end},...
                      'visible',iRUNID==1,...                     
                           'dt',OPT.period,'colorMap',@(m) [0 0 0],'colorSteps',1);
                
   %% kml of u bot
      
      sourcefiles{end+1} = [ge_name,'_ubot.kml'];
      KMLcurvedArrows(D.x(1:dn:end,1:dn:end),...
                      D.y(1:dn:end,1:dn:end),...
         permute(D.u(end,1:dn:end,1:dn:end),[2 3 1]),... % u first
         permute(D.v(end,1:dn:end,1:dn:end),[2 3 1]),... % v second
                         'time',[],'interp_steps',0,...
                      'kmlName','velocity bottom (gray)',...
                     'n_arrows',250,'fileName',sourcefiles{end},...
                      'visible',iRUNID==1,...                     
                           'dt',OPT.period,'colorMap',@(m) [.5 .5 .5],'colorSteps',1);
   
   %% kml of lay out
      
      for ii=1:length(ALT)
      sourcefiles{end+1} = [ge_name,'_scenario_',num2str(ii),'.kml'];
      KMLline(ALT(ii).lat,ALT(ii).lon,...
                     'fileName',sourcefiles{end},...
                      'kmlName',['lay out scenario ',num2str(ii)],...
                    'lineColor',[.7 .7 .7],...
                      'visible',iRUNID==1,...                     
                    'lineWidth',3)
      end
      
   %% kml merge
     
      sourcefilesmerged{iRUNID} = [ge_name,'.kml'];
      KMLmerge_files(   'fileName',sourcefilesmerged{iRUNID},...
                         'kmlName',OPT.legend,...
                     'sourceFiles',sourcefiles,...
                         'visible',iRUNID==1,...                     
                            'open',0);     
      for i=1:length(sourcefiles)
         delete(sourcefiles{i})
      end
   
   end
end
%%
KMLmerge_files(   'fileName','Markermeer.kml',...
               'description',['Stationary simulations with 10 m/s winds for a range of wind directions. Please tick them one by one. These simulations are purely indicative to get a first insight into the response of the waterlevels and currents under wind forcing. The numerical model grid was designed to be representative only in The Markermeer, whereas the Gooimeer and Eemmeer were only included in crude resolution to behave sufficiently accurate (in terms of water storage) for a proper response of the Markermeer. The Markermeer is studied in more detail in various research programs, e.g.: Building with Nature (http://public.deltares.nl/display/BWN/MIJ+Markermeer-IJsselmeer) and Rijkswaterstaat ANT (http://www.rijkswaterstaat.nl/images/Programma%20Natuurijk%28er%29%20Markermeer-IJmeer%202009%20-%202015_tcm174-263003.pdf). Legend: black = surface velocities, gray = bottom velocities.'],... % The arrow length corresponds to a particle tracking period of ',num2str(OPT.period),' s. '
               'sourceFiles',sourcefilesmerged,...
                   'visible',iRUNID==1,...                     
                      'open',1);
