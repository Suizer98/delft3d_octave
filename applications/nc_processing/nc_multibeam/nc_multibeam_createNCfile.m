function nc_multibeam_createNCfile(OPT,EPSG,ncfile,X,Y)
%nc_multibeam_createNCfile
%
%    nc_multibeam_createNCfile(OPT,EPSG,ncfile,X,Y)
%
%See also: nc_multibeam, snctools
   OPT0                = nc_multibeam_from_asc;
   OPT0.num_bytes      = 20000; % pad header
   OPT0.netcdfversion  = 3;
   OPT0.SetTime = 0;
   if nargin==0
       varargout = {OPT};
       return
   end
   OPT = setproperty(OPT0, {OPT},'onExtraField','silentAppend');

%% create empty outputfile
%  indicate NetCDF outputfile name and create empty structure

   if ~exist(OPT.netcdf_path,'dir') & ~isempty(OPT.netcdf_path)
       mkdir(OPT.netcdf_path)
   end

% avoid use of netCDF as it is incompatible with R and arcGIS, onyl use netCDF4 when you really need it,
% e.g. when you have lots of nodatavalues, fort which netCDF4 provides effective per-variable zipping

   mode = netcdf.getConstant('NOCLOBBER');
   switch  OPT.netcdfversion
       case 3
           deflatenc = false;
       case 4
           deflatenc = true;
           mode      = bitor(mode,netcdf.getConstant('NETCDF4'));
   end

   NCid     = netcdf.create(ncfile,mode);
   globalID = netcdf.getConstant('NC_GLOBAL');
   dimSizeX = (OPT.mapsizex/OPT.gridsizex);
   dimSizeY = (OPT.mapsizey/OPT.gridsizey);


%% add attributes global to the dataset

   netcdf.putAtt(NCid,globalID, 'Conventions',     OPT.Conventions);
   netcdf.putAtt(NCid,globalID, 'CF:featureType',  OPT.CF_featureType); % http://www.unidata.ucar.edu/software/netcdf-java/v4.1/javadoc/ucar/nc2/constants/CF.FeatureType.html
   netcdf.putAtt(NCid,globalID, 'title',           OPT.title);
   netcdf.putAtt(NCid,globalID, 'institution',     OPT.institution);
   netcdf.putAtt(NCid,globalID, 'source',          OPT.source);
   netcdf.putAtt(NCid,globalID, 'history',         OPT.history);
   netcdf.putAtt(NCid,globalID, 'references',      OPT.references);
   netcdf.putAtt(NCid,globalID, 'comment',         OPT.comment);
   netcdf.putAtt(NCid,globalID, 'email',           OPT.email);
   netcdf.putAtt(NCid,globalID, 'version',         OPT.version);
   netcdf.putAtt(NCid,globalID, 'terms_for_use',   OPT.terms_for_use);
   netcdf.putAtt(NCid,globalID, 'disclaimer',      OPT.disclaimer);
   if OPT.SetTime==1
        netcdf.putAtt(NCid,globalID, 'note','No information about the survey date is available, the time is set to be the date of the creation of the NetCDF file');
   end

%% specify dimensions (time dimension is set to unlimited)
   netcdf.defDim(NCid,          'time',        netcdf.getConstant('NC_UNLIMITED'));

   netcdf.defDim(NCid,          'y',           dimSizeY);
   netcdf.defDim(NCid,          'x',           dimSizeX);

%% define coordinate variables
%  add variable: coordinate system reference (this variable contains all projection information, e.g. for use in ArcGIS)
  
   x  = unique(X);
   dx = abs(unique(diff(x)));
   if length(dx) == 1
       actual_range.x = [min(x)-.5*dx max(x)+.5*dx]; % outer coordinates of corners, x/y are at centers
   else
       actual_range.x = [];
   end
   
   y  = unique(Y);
   dy = abs(unique(diff(y)));
   if length(dy) == 1
       actual_range.y = [min(y)-.5*dy max(y)+.5*dy]; % outer coordinates of corners, x/y are at centers
   else
       actual_range.y = [];
   end

   if ~isempty(OPT.EPSGcode)
   S = nc_cf_grid_mapping(OPT.EPSGcode);
   nc.Name         = 'EPSG';
   nc.Nctype       = nc_int;
   nc.Dimension    = {};
   nc.Attribute    = S;
   netcdf_addvar(NCid, nc);
   end
   
   S = nc_cf_grid_mapping(4326);
   nc.Name         = 'WGS84';
   nc.Nctype       = nc_int;
   nc.Dimension    = {};
   nc.Attribute    = S;
   netcdf_addvar(NCid, nc);

   nc_oe_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'time'}, 'oe_standard_name', {'time'},                    'dimension', {'time'}        ,'timezone', '+01:00');
   nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'lon'},  'cf_standard_name', {'longitude'},               'dimension', {'x','y'}       ,'deflate',deflatenc,'additionalAtts',{'grid_mapping'                             ;'WGS84'});
   nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'lat'},  'cf_standard_name', {'latitude'},                'dimension', {'x','y'}       ,'deflate',deflatenc,'additionalAtts',{'grid_mapping'                             ;'WGS84'});
   nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'x'},    'cf_standard_name', {'projection_x_coordinate'}, 'dimension', {'x'}                               ,'additionalAtts',{'grid_mapping','coordinates','actual_range';'EPSG','lon lat',actual_range.x});
   nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'y'},    'cf_standard_name', {'projection_y_coordinate'}, 'dimension', {'y'}                               ,'additionalAtts',{'grid_mapping','coordinates','actual_range';'EPSG','lon lat',actual_range.y});
   nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'z'},    'cf_standard_name', {'altitude'},                'dimension', {'x','y','time'},'deflate',deflatenc,'additionalAtts',{'grid_mapping','coordinates','actual_range';'EPSG','lon lat',[nan nan]});

%% Expand NC file

   netcdf.endDef(NCid,OPT.num_bytes,4,0,4); 

%% add coordinate data

   [lon,lat] = convertCoordinates(X,Y,EPSG,'CS1.code',OPT.EPSGcode,'CS2.code',4326);

   varid = netcdf.inqVarID(NCid,'y'  );netcdf.putVar(NCid,varid,Y(:,1));
   varid = netcdf.inqVarID(NCid,'x'  );netcdf.putVar(NCid,varid,X(1,:));
   varid = netcdf.inqVarID(NCid,'lat');netcdf.putVar(NCid,varid,lat');
   varid = netcdf.inqVarID(NCid,'lon');netcdf.putVar(NCid,varid,lon');

%% close NC file

   netcdf.close(NCid)

end