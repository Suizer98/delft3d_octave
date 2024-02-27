function simona_getdata_netcdf2CF(ncfile0)
%simona_getdata_netcdf2CF  make legacy netCDF file from SIMONA getdata.exe CF compliant
%
%  simona_getdata_netcdf2CF(ncfile) modified ncfile produces by getdata.exe
%
% This extra functionality is being implemented in getdata, this matlab fucntion
% is used to explore what exactly to implement (ensure complaince with THREDDS and ADAGUC)
% and for future fixes of netCDF files from previous (and current) getdata releases.
%
%See also: netcdf, vs_trim2nc, waqua, matroos 
%  http://www.helpdeskwater.nl/onderwerpen/applicaties-modellen/water_en_ruimte/simona/simona/simona-stekkers/
%  http://apps.helpdeskwater.nl/downloads/extra/simona/release/doc/usedoc/getdata/getdata.pdf

% TODO
% http://wiki.esipfed.org/index.php/Attribute_Convention_for_Data_Discovery_%28ACDD%29

OPT.xy     = 1; % 0 removed coord attribute but does not remove XZETA/YZETA arrays itself
OPT.xybnds = 1; % ADAGUC can work with [x,y] coordinates only by mapping on-the-fly, THREDDS cannot map on-the-fly
OPT.ll     = 1; % required by THREDDS and Panoply
OPT.llbnds = 1; % THREDDS needs [lat,lon] matrices to be included
OPT.epsg   = 28992;

if OPT.xy & OPT.ll
   % Panoply only works when xy=0, xybnds=0, ll=1, llbnds=1
   warning('Panoply cannot handle coords = "lon lat XZETA YZETA"')
end

ncfile  = [filepathstrname(ncfile0),'_xy_',num2str(OPT.xy),num2str(OPT.xybnds),'_ll_',num2str(OPT.ll),num2str(OPT.llbnds),'.nc'];
coordinate_system = nc_attget(ncfile0,nc_global,'coordinate_system');

coords  = ['YZETA XZETA']; % contains lat,lon if coordinate_system='WGS84'
if OPT.ll & ~strcmpi(coordinate_system,'WGS84')
   coords  = [coords ' lon lat']; % we'll have to add lon lat
end


copyfile(ncfile0,ncfile);

nc_dump(ncfile);

 nc_attput(ncfile,nc_global,'Conventions','CF-1.6');
 nc_attput(ncfile,nc_global,'cdm_data_type','Grid');

% make time small caps
if nc_isvar(ncfile,'TIME') % check for spherical
 nc_attput(ncfile,'TIME'  ,'standard_name','time');
end
 
 nc_attput(ncfile,'SEP'   ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 nc_attput(ncfile,'SEP'   ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix

 nc_attput(ncfile,'H'     ,'standard_name','sea_floor_depth_below_sea_level'); % change
 nc_attput(ncfile,'H'     ,'coordinates'  ,'YDEP XDEP'); % connect CORNER (x,y) to CORNER matrix (is H at corners???)
 nc_attput(ncfile,'H'     ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 
%% staggered m-n velocities

if nc_isvar(ncfile,'UP') % check for spherical
%nc_attput(ncfile,'UP'    ,'standard_name','eastward_sea_water_velocity');
 nc_attput(ncfile,'UP'    ,'standard_name','sea_water_x_velocity'); % change: legal standard_name, different when grid is in spherical coordinates
 nc_attput(ncfile,'UP'    ,'long_name'    ,'velocity, x-component'); % change: QuickPlot requires this in order to show vectors
 nc_attput(ncfile,'UP'    ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'UP'    ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
end

if nc_isvar(ncfile,'VP') % check for spherical
%nc_attput(ncfile,'VP'    ,'standard_name','northward_sea_water_velocity');
 nc_attput(ncfile,'VP'    ,'standard_name','sea_water_y_velocity'); % change: legal standard_name, different when grid is in spherical coordinates
 nc_attput(ncfile,'VP'    ,'long_name'    ,'velocity, y-component'); % change: QuickPlot requires this in order to show vectors
 nc_attput(ncfile,'VP'    ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'VP'    ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
end
 
%% unstaggared x-y velocities 

if nc_isvar(ncfile,'UVEL') % check for spherical
%nc_attput(ncfile,'UVEL'    ,'standard_name','eastward_sea_water_velocity');
 nc_attput(ncfile,'UVEL'    ,'standard_name','sea_water_x_velocity'); % change: legal standard_name, different when grid is in spherical coordinates
 nc_attput(ncfile,'UVEL'    ,'long_name'    ,'velocity, x-component'); % change: QuickPlot requires this in order to show vectors
 nc_attput(ncfile,'UVEL'    ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'UVEL'    ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
end

if nc_isvar(ncfile,'VVEL') % check for spherical
%nc_attput(ncfile,'VVEL'    ,'standard_name','northward_sea_water_velocity');
 nc_attput(ncfile,'VVEL'    ,'standard_name','sea_water_y_velocity'); % change: legal standard_name, different when grid is in spherical coordinates
 nc_attput(ncfile,'VVEL'    ,'long_name'    ,'velocity, y-component'); % change: QuickPlot requires this in order to show vectors
 nc_attput(ncfile,'VVEL'    ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'VVEL'    ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
end

%% coordinates

 nc_attput(ncfile,'XZETA' ,'long_name'    ,'x coordinate Arakawa-C centers'); % change: make different than XDEP
 nc_attput(ncfile,'XZETA' ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'XZETA' ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 if OPT.xybnds
 nc_attput(ncfile,'XZETA' ,'bounds'       ,'grid_x'); % bounds:XDEP add bounds attribute once XDEP is 3D [4 x n x m]'); % add bounds attribute once XDEP is 3D [4 x n x m]
 end

 nc_attput(ncfile,'YZETA' ,'long_name'    ,'y coordinate Arakawa-C centers'); % change: make different than YDEP
 nc_attput(ncfile,'YZETA' ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'YZETA' ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 if OPT.xybnds
 nc_attput(ncfile,'YZETA' ,'bounds'       ,'grid_y'); % bounds:YDEP add bounds attribute once YDEP is 3D [4 x n x m]'); % add bounds attribute once YDEP is 3D [4 x n x m]
 end
 
 nc_attput(ncfile,'XDEP'  ,'long_name'    ,'x coordinate Arakawa-C corners'); % change: make different than XZETA
 nc_attput(ncfile,'XDEP'  ,'standard_name','projection_x_coordinate');        % change: make identical as XZETA
 nc_attput(ncfile,'XDEP'  ,'coordinates'  ,'YDEP XDEP'); % connect CORNER (x,y) to CORNER matrix
 nc_attput(ncfile,'XDEP'  ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 nc_attput(ncfile,'XDEP'  ,'comment'      ,'XDEP and XZETA can''t be same size: document or remove dummy rows/columns');

 nc_attput(ncfile,'YDEP'  ,'long_name'    ,'y coordinate Arakawa-C corners'); % change: make different than YZETA
 nc_attput(ncfile,'YDEP'  ,'standard_name','projection_y_coordinate');        % change: make identical as XZETA
 nc_attput(ncfile,'YDEP'  ,'coordinates'  ,'YDEP XDEP'); % connect CORNER (x,y) to CORNER matrix
 nc_attput(ncfile,'YDEP'  ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 nc_attput(ncfile,'YDEP'  ,'comment'      ,'XDEP and XZETA can''t be same size: document or remove dummy rows/columns');
 
if ~nc_isvar(ncfile,'CRS')
 attr = nc_cf_grid_mapping(OPT.epsg);
 attr(end).Value = 'these values differ per coordinate system, for SIMONA this is mostly one of 3 flavours: Amersfoort/RD or UTM31/ED50 or LATLON/WGS84/ETRS89';
 nc  = struct('Name','CRS', ...
                     'Datatype'   , 'int32', ...
                     'Dimension' , [], ...
                     'Attribute' , attr,...
                     'FillValue'  , []); % this doesn't do anything
 nc_addvar(ncfile,nc); clear attr;% ADD
end
 
%% lat, lon

 if OPT.ll & ~strcmpi(coordinate_system,'WGS84');
 
  % get center coordinates, incl dummy rows and columns
  % put dummy rows and columns to NaN, to avoid strang uninitialized fill values

  G.XZETA = nc_varget(ncfile,'XZETA');
  G.YZETA = nc_varget(ncfile,'YZETA');
 
  G.XZETA([1 end],:)=NaN;G.XZETA(:,[1 end])=NaN;
  G.XZETA([1 end],:)=NaN;G.YZETA(:,[1 end])=NaN;
 [G.LONZETA,G.LATZETA] = convertCoordinates(G.XZETA,G.YZETA,'CS1.code',OPT.epsg,'CS2.code',4326);
 
     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','latitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_north');
     attr(5) = struct('Name','long_name'    ,'Value','latitude');
     attr(6) = struct('Name','coordinates'  ,'Value',coords); % connect CENTER (x,y) to CENTER matrix
     if (OPT.ll & OPT.llbnds)
     attr(7) = struct('Name','bounds'       ,'Value','lat_bnds');
     end
     nc  = struct('Name','lat', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lat',G.LATZETA); % ADD 

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','longitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_east');
     attr(5) = struct('Name','long_name'    ,'Value','longitude');
     attr(6) = struct('Name','coordinates'  ,'Value',coords); % connect CENTER (x,y) to CENTER matrix     
     if (OPT.ll & OPT.llbnds)
     attr(7) = struct('Name','bounds'       ,'Value','lon_bnds');
     end
     nc  = struct('Name','lon', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lon',G.LONZETA); % ADD 
 end
 
%% get coordinates to determine bounds
%  note: only 1 dummy row/col, whereas centers have two

 if (OPT.xy & OPT.xybnds) | (OPT.ll & OPT.llbnds)

   G.XDEP  = nc_varget(ncfile,'XDEP');
   G.YDEP  = nc_varget(ncfile,'YDEP');
   
   if OPT.llbnds
  [G.LONDEP ,G.LATDEP ] = convertCoordinates(G.XDEP ,G.YDEP ,'CS1.code',OPT.epsg,'CS2.code',4326);
   end
   if ~nc_isdim(ncfile,'bounds')
     nc_adddim(ncfile,'bounds',4)
   end
 end

%% (lat,lon) bounds

 if (OPT.ll & OPT.llbnds) & ~strcmpi(coordinate_system,'WGS84');
     G.lon_bnds = nc_cf_cor2bounds(addrowcol(G.LONDEP,-1,-1,nan));
     G.lat_bnds = nc_cf_cor2bounds(addrowcol(G.LATDEP,-1,-1,nan));

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','latitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_north');
     attr(5) = struct('Name','long_name'    ,'Value','latitude corners');
     nc  = struct('Name','lon_bnds', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lon_bnds',G.lon_bnds); % ADD 

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','longitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_east');
     attr(5) = struct('Name','long_name'    ,'Value','longitude corners');
     nc  = struct('Name','lat_bnds', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lat_bnds',G.lat_bnds); % ADD 
 end
 
%% (x,y) bounds

 if (OPT.xy & OPT.xybnds)
     G.grid_x = nc_cf_cor2bounds(addrowcol(G.XDEP,-1,-1,nan)); % add extra XDEP dummy row to get bounds for XZETA dummy row
     G.grid_y = nc_cf_cor2bounds(addrowcol(G.YDEP,-1,-1,nan));

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','projection_x_coordinate');
     attr(4) = struct('Name','units'        ,'Value','m');
     attr(5) = struct('Name','long_name'    ,'Value','x corners');     
     nc  = struct('Name','grid_x', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     if ~nc_isvar(ncfile,'grid_x')
     nc_addvar(ncfile,nc); clear attr;% ADD 
     end
     nc_varput(ncfile,'grid_x',G.grid_x); % ADD or correct

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','projection_y_coordinate');
     attr(4) = struct('Name','units'        ,'Value','m');
     attr(5) = struct('Name','long_name'    ,'Value','y corners'); 
     nc  = struct('Name','grid_y', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     if ~nc_isvar(ncfile,'grid_y')
     nc_addvar(ncfile,nc); clear attr;% ADD 
     end
     nc_varput(ncfile,'grid_y',G.grid_y); % ADD or correct
 end
 
%% make ascii dumps for easy comparison

 nc_dump(ncfile0,[],[filepathstrname(ncfile0),'.cdl']);
 nc_dump(ncfile ,[],[filepathstrname(ncfile) ,'.cdl']);
 
 fclose all