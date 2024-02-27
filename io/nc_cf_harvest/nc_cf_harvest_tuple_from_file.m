function varargout = nc_cf_harvest_tuple_from_file(varargin)
%nc_cf_harvest_tuple_from_file  extract CF + THREDDS meta-data from 1 netCDF/OPeNDAP url
%
%  struct = nc_cf_harvest_tuple_from_file(ncfile)
%
% harvests (extracts) <a href="http://cf-pcmdi.llnl.gov/">CF meta-data</a> + <a href="http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/index.html">THREDDS catalog</a>
% meta-data from one ncfile (netCDF file/OPeNDAP url)
% into a multi-layered struct that contains
% * what : http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#variables
% * where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage
% * when : http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage
%
% Use NC_CF_HARVEST to harvest a list of ncfiles (netCDF file/OPeNDAP url).
%
% struct = nc_cf_harvest_tuple_from_file([],...) returns an empty example data structure
%
%See also: OPENDAP_CATALOG, NC_CF_HARVEST, nc_cf_harvest2xml, nc_cf_harvest2nc, nc_cf_harvest2xls
%          thredds_dump, thredds_info,NC_INFO, nc_dump, NC_ACTUAL_RANGE, 
%          ncgentools_generate_catalog

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011-2013 Deltares for Nationaal Modellen en Data centrum (NMDC),
%                           Building with Nature and internal Eureka competition.
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_cf_harvest_tuple_from_file.m 8319 2013-03-13 10:20:26Z boer_g $
% $Date: 2013-03-13 18:20:26 +0800 (Wed, 13 Mar 2013) $
% $Author: boer_g $
% $Revision: 8319 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_tuple_from_file.m $
% $Keywords$

% warning('netcdf-java DataDiscoveryAttConvention not yet used, only CF attributes ued.')

   OPT.disp           = ''; %'multiWaitbar';
   OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
   OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
   OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'
%    OPT.catalog_entry  = {'title',...
%                          'institution',...
%                          'source',...
%                          'history',...
%                          'references',...
%                          'email',...
%                          'comment',...
%                          'version',...
%                          'Conventions',...
%                          'terms_for_use',...
%                          'disclaimer'};
   OPT.catalog_entry  = {'Conventions'};

   if nargin==0
      varargout = {OPT};
      return
   end
                         
%% Instances initialize (to be able to return for introspection)
%  global and timeseries catalog_entries added later, after setproperty.
   
   OPT = setproperty(OPT,{varargin{2:end}});                      
   ATT = nc_cf_harvest_tuple_initialize('featuretype',OPT.featuretype,'platform_id',OPT.platform_id,'platform_name',OPT.platform_name);

%% File

   if isempty(varargin{1})
      varargout = {ATT};
      return
   elseif isstruct(varargin{1})
      fileinfo = varargin{1};
      ncfile   = fileinfo.Filename;
   elseif ~isstruct(varargin{1})
      ncfile   = varargin{1};
      fileinfo = nc_info(ncfile);
   end
   
%% get relevant global attributes
%  using above read fileinfo

%warning('replace with THREDDS catalog elements')
   
    for iatt  = 1:length(OPT.catalog_entry)
      catalog_entry = OPT.catalog_entry{iatt};
      fldname = mkvar(catalog_entry);
        for iglob = 1:length(fileinfo.Attribute)
         if strcmpi(catalog_entry,fileinfo.Attribute(iglob).Name)
            ATT.(fldname) = fileinfo.Attribute(iglob).Value;
         end
      end
    end
   
%% Cycle datasets
%  get actual_range attribute instead if present for lat, lon, time

   idat = 1;

   if isurl(ncfile);
      ATT.urlPath = ncfile;
   else
      ATT.urlPath = filenameext(ncfile);
      tmp = dir(ncfile);
      ATT.dataSize = tmp.bytes;
      ATT.date     = tmp.datenum;
   end
   
   ndat = length(fileinfo.Dataset);
   for idat=1:ndat
   
      if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar([mfilename,'1'],idat/ndat,'label','Cycling datasets ...')
      end
   
      % cycle all attributes
      natt = length(fileinfo.Dataset(idat).Attribute);

      %% extract variable meta-data for 
      %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#variablesType  
      %  always initialize, so position in *_name and units vector correspondents
      ATT.variable_name{idat} = fileinfo.Dataset(idat).Name;
      ATT.standard_name{idat} = '';
      ATT.long_name    {idat} = '';
      ATT.units        {idat} = '';
      
      for iatt=1:natt
      
          if strcmpi(OPT.disp,'multiWaitbar')
          multiWaitbar([mfilename,'2'],iatt/natt,'label','Cycling attributes ...')
          end
      
          Name  = fileinfo.Dataset(idat).Attribute(iatt).Name;
          
       %% extract variable meta-data for 
       %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#variablesType  
       %  always initialize, so position in *_name and units vector correspondents
       %  and always make char
       
          if strcmpi(Name,'standard_name')   ;ATT.standard_name{idat} = fileinfo.Dataset(idat).Attribute(iatt).Value;end
          if strcmpi(Name,'long_name')       ;ATT.long_name    {idat} = fileinfo.Dataset(idat).Attribute(iatt).Value;end
          if strcmpi(Name,'units')           ;ATT.units        {idat} = fileinfo.Dataset(idat).Attribute(iatt).Value;end
          if ~ischar(ATT.standard_name{idat});ATT.units{idat} = num2str(ATT.standard_name{idat});end
          if ~ischar(ATT.long_name    {idat});ATT.units{idat} = num2str(ATT.long_name{idat}    );end
          if ~ischar(ATT.units        {idat});ATT.units{idat} = num2str(ATT.units{idat}        );end

       %% interpret for extraction all spatio-temporal meta-data
          
          % get standard_name only ...
          if strcmpi(Name,'standard_name')
      
              standard_name_Value = fileinfo.Dataset(idat).Attribute(iatt).Value;
              
           % get spatial extent
           
              if strcmpi(standard_name_Value,'latitude')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'degrees_north');
                  latitude  = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.northsouth.start = min(ATT.geospatialCoverage.northsouth.start,latitude(1));
                  ATT.geospatialCoverage.northsouth.end   = max(ATT.geospatialCoverage.northsouth.end  ,latitude(2));
              end
              
              if strcmpi(standard_name_Value,'longitude')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'degrees_north');
                  longitude = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.eastwest.start  = min(ATT.geospatialCoverage.eastwest.start,longitude(1));
                  ATT.geospatialCoverage.eastwest.end    = max(ATT.geospatialCoverage.eastwest.end  ,longitude(2));
              end
              
              if strcmpi(standard_name_Value,'altitude') % | strcmpi(standard_name_Value,'height_above_*')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'m');
                  z         = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.updown.start    = min(ATT.geospatialCoverage.updown.start,z(1));
                  ATT.geospatialCoverage.updown.end      = max(ATT.geospatialCoverage.updown.end  ,z(2));
              end
              
              if strcmpi(standard_name_Value,'projection_x_coordinate')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'m');
                  x         = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.x.start = min(ATT.geospatialCoverage.x.start,min(x(1)));
                  ATT.geospatialCoverage.x.end   = max(ATT.geospatialCoverage.x.end  ,max(x(2)));
                  
                  if nc_isatt(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping')
                      grid_mappings = strtokens2cell(nc_attget(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping'));
%                      for ii=1:length(grid_mappings)
%                      if nc_isvar(ncfile,grid_mappings{ii})
%                          ATT.projectionEPSGcode = unique([ATT.projectionEPSGcode double(nc_varget(ncfile,grid_mappings{ii},0,1))]);
%                      end
%                      end
                  else
                      fprintf(2,'%s\n',['projection_x_coordinate without grid_mapping attribute found: ',ncfile])
                  end
              end
              
              if strcmpi(standard_name_Value,'projection_y_coordinate')
                  units     = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  fac       = convert_units(units,'m');
                  y         = fac.*nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  ATT.geospatialCoverage.y.start = min(ATT.geospatialCoverage.y.start,min(y(1)));
                  ATT.geospatialCoverage.y.end   = max(ATT.geospatialCoverage.y.end  ,max(y(2)));
                  
                  if nc_isatt(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping')
                      grid_mappings = strtokens2cell(nc_attget(ncfile, fileinfo.Dataset(idat).Name,'grid_mapping'));
%                      for ii=1:length(grid_mappings)
%                      if nc_isvar(ncfile,grid_mappings{ii})
%                          projectionEPSGcode = unique([ATT.projectionEPSGcode double(nc_varget(ncfile,grid_mappings{ii},0,1))]);
%                      end
%                      end
                      
%                      if ~all(sort(projectionEPSGcode)==sort(ATT.projectionEPSGcode))
%                      error('projectionEPSGcode x and y different')
%                      end
                  else
                      fprintf(2,'%s\n',['projection_y_coordinate without grid_mapping attribute found: ',ncfile])
                  end
              end
              
           % get temporal extent
           
              if strcmpi(standard_name_Value,'time')
                  time      = nc_actual_range(ncfile, fileinfo.Dataset(idat).Name);
                  timeunits = nc_attget      (ncfile, fileinfo.Dataset(idat).Name,'units');
                  time      = udunits2datenum(time,timeunits);
                  ATT.timeCoverage.start   = min(ATT.timeCoverage.start,time(1));
                  ATT.timeCoverage.end     = max(ATT.timeCoverage.end  ,time(2));
      
                  if strcmpi(OPT.featuretype,'timeseries')
                     ATT.number_of_observations = fileinfo.Dataset(idat).Size;
                  end
      
              end
      
           % get timeseries specifics
           
              if strcmpi(OPT.featuretype,'timeseries')
              
                  if strcmpi(standard_name_Value,'platform_id') | ... % CF-1.6
                     strcmpi(standard_name_Value,'station_id')      % < CF-1.6
                      ATT.platform_id  = nc_varget(ncfile, fileinfo.Dataset(idat).Name);
                      if isnumeric(ATT.platform_id)
                      ATT.platform_id = num2str(ATT.platform_id);
                      end
                      ATT.platform_id = ATT.platform_id(:)';
                  end
           
                  if strcmpi(standard_name_Value,'platform_name') | ... % CF-1.6
                     strcmpi(standard_name_Value,'station_name')      % < CF-1.6
                      ATT.platform_name = nc_varget(ncfile, fileinfo.Dataset(idat).Name);
                      ATT.platform_name = ATT.platform_name(:)';
                  end
           
              end
      
          end % loop standard_name
          
      end % iatt
      
   end % idat

%% Instances initialize

   ATT.geospatialCoverage.northsouth = geospatialCoverage_complete(ATT.geospatialCoverage.northsouth);
   ATT.geospatialCoverage.eastwest   = geospatialCoverage_complete(ATT.geospatialCoverage.eastwest  );
   ATT.geospatialCoverage.updown     = geospatialCoverage_complete(ATT.geospatialCoverage.updown    );
   ATT.timeCoverage                  =       timeCoverage_complete(ATT.timeCoverage                 );
   ATT.geospatialCoverage.x          = geospatialCoverage_complete(ATT.geospatialCoverage.x         );
   ATT.geospatialCoverage.y          = geospatialCoverage_complete(ATT.geospatialCoverage.y         );

varargout = {ATT};

