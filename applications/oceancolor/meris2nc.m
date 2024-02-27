function meris2nc(outputfile,D,varargin);
%MERIS2NC   save ONE MERIS object as netCDF file
%
%   meris2nc(outputfile,D)
%
% where D is a MERIS object (struct) as returned by either
% MERIS_WATERINSIGHT_LOAD or MERIS_IVMMOS2_LOAD.
%
% See L2BIN2NC for storing a time series of binned
% MERIS images.
%
%See also: OCEANCOLOR, SEAWIFS_CREATE, NLW2SPM, L2BIN2NC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 July Deltares
%       G.J.de Boer
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: meris2nc.m 7364 2012-10-02 06:24:08Z boer_g $
% $Date: 2012-10-02 14:24:08 +0800 (Tue, 02 Oct 2012) $
% $Author: boer_g $
% $Revision: 7364 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris2nc.m $
% $Keywords: $

%% 1a Create file

   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.fillvalue      = nan; % NaNs do work in netcdf API
   
   OPT = setproperty(OPT,varargin{:});

%% 1a Create file
   
      nc_create_empty (outputfile)
   
%% CF attributes

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc_attput(outputfile, nc_global, 'title'           , 'MERIS Reduced Resolution data');
      nc_attput(outputfile, nc_global, 'institution'     , D.institution);
      nc_attput(outputfile, nc_global, 'source'          , 'surface observation');
      nc_attput(outputfile, nc_global, 'history'         ,['Version:' ,D.version,... 
                                                           ', tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris2nc.m $']);
      nc_attput(outputfile, nc_global, 'references'      , D.references);
      nc_attput(outputfile, nc_global, 'email'           , D.email);
   
      nc_attput(outputfile, nc_global, 'comment'         , '');
      nc_attput(outputfile, nc_global, 'version'         , D.version);
   						   
      nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.4');
      nc_attput(outputfile, nc_global, 'CF:featureType'  , ''); % grid
   
      nc_attput(outputfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: WaterInsight.');
      nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
      
%% MERIS specific attributes
      
      nc_attput(outputfile, nc_global, 'sensor'               ,D.sensor); % 'Meris'
      nc_attput(outputfile, nc_global, 'product'              ,D.product);
      nc_attput(outputfile, nc_global, 'product_level'        ,D.product_level); % 'L2'
      nc_attput(outputfile, nc_global, 'parent_child'         ,D.parent_child);
      nc_attput(outputfile, nc_global, 'processing_stage_flag',D.processing_stage_flag);
      nc_attput(outputfile, nc_global, 'center'               ,D.center);
      nc_attput(outputfile, nc_global, 'timezone'             ,D.timezone);
      nc_attput(outputfile, nc_global, 'start_day'            ,D.start_day);
      nc_attput(outputfile, nc_global, 'start_time'           ,D.start_time);
      nc_attput(outputfile, nc_global, 'duration_in_seconds'  ,D.duration_in_seconds);
      nc_attput(outputfile, nc_global, 'datenum'              ,D.datenum); % array !
      nc_attput(outputfile, nc_global, 'mission_phase'        ,D.mission_phase);
      nc_attput(outputfile, nc_global, 'cycle_number'         ,D.cycle_number);
      nc_attput(outputfile, nc_global, 'relative_orbit_number',D.relative_orbit_number);
      nc_attput(outputfile, nc_global, 'absolute_orbit_number',D.absolute_orbit_number);
      nc_attput(outputfile, nc_global, 'counter'              ,D.counter);
      nc_attput(outputfile, nc_global, 'coordinate_system'    ,D.coordinate_system);
      nc_attput(outputfile, nc_global, 'coordinate_units'     ,D.coordinate_units);
      nc_attput(outputfile, nc_global, 'geoid'                ,D.geoid);
   
%% 2 Create dimensions
   
      nc_add_dimension(outputfile, 'time'         ,           1);  % use time as last dimension so for one time the matrices are simply 2D 
      nc_add_dimension(outputfile, 'dim1'         ,      size(D.l2_flags,1)); 
      nc_add_dimension(outputfile, 'dim2'         ,      size(D.l2_flags,2)); 
      nc_add_dimension(outputfile, 'band'         ,      length(D.bands.wavelength));  
      nc_add_dimension(outputfile, 'L2_flags_bits',    length(D.flags.bit));
      nc_add_dimension(outputfile, 'strlen1'      , size(char(D.flags.name),2));

%% 3 Create variables
   
      clear nc
      ifld = 0;
      
   %% Meta data
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'meta';
      nc(ifld).Nctype       = 'char';
      nc(ifld).Dimension    = {}; % no dimension, dummy variable
      nc(ifld).Attribute(1) = struct('Name', 'T'          ,'Value', num2str(D.metaData.T));  % HMM, ATRRIBUTES CANNOT BE ARRAYS
      nc(ifld).Attribute(2) = struct('Name', 'Ci'         ,'Value', num2str(D.metaData.Ci)); % HMM, ATRRIBUTES CANNOT BE ARRAYS
      nc(ifld).Attribute(3) = struct('Name', 'b'          ,'Value', num2str(D.metaData.b));  % HMM, ATRRIBUTES CANNOT BE ARRAYS
      nc(ifld).Attribute(4) = struct('Name', 'Fdiff'      ,'Value',         D.metaData.Fdiff);
      nc(ifld).Attribute(5) = struct('Name', 'method'     ,'Value',         D.metaData.method);
      nc(ifld).Attribute(6) = struct('Name', 'errormodel' ,'Value',         D.metaData.errormodel);
      nc(ifld).Attribute(7) = struct('Name', 'maxIter'    ,'Value',         D.metaData.maxIter);
      nc(ifld).Attribute(8) = struct('Name', 'SIOP'       ,'Value',         D.metaData.SIOP);
      nc(ifld).Attribute(9) = struct('Name', 'fname'      ,'Value',         D.metaData.fName);

   %% Time
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   %  time is a dimension, so there are two options:
   %  * the variable name needs the same as the dimension
   %    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   %  * there needs to be an indirect mapping through the coordinates attribute
   %    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'time';
      nc(ifld).Nctype       = 'double';                        % !!!! % float not sufficient as datenums are big: double
      nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
      nc(ifld).Attribute(1) = struct('Name', 'long_name'          ,'Value', 'time');
      nc(ifld).Attribute(2) = struct('Name', 'units'              ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',D.timezone]);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'      ,'Value', 'time');
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'         ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'axis'               ,'Value', 'time');

   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'crs';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {}; % no dimension, dummy variable
      nc(ifld).Attribute    = nc_cf_grid_mapping(D.epsg); % will also add KNMI ADAGUC proj4_params

      if isfield(D,'lon') & isfield(D,'lat')
   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'longitude';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'pixel centers longitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'axis'           ,'Value', 'X');

   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'latitude';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'          ,'Value', 'pixel centers latitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'              ,'Value', 'degrees_north');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'      ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'axis'               ,'Value', 'Y');
      end

      if isfield(D,'x') & isfield(D,'y')
   %% X
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'x';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'axis'           ,'Value', 'X');

   %% Y
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'y';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'          ,'Value', 'y');
      nc(ifld).Attribute(2) = struct('Name', 'units'              ,'Value', 'm');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'      ,'Value', 'projection_y_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'axis'               ,'Value', 'Y');
      end

   %% Parameters with standard names
   %  * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
   %% Define dimensions in this order:
   %  time,z,y,x

      if isfield(D,'spectral_bands')
        ifld = ifld + 1;
      nc(ifld).Name         = 'spectral_bands';
      nc(ifld).Nctype       = 'double';
      nc(ifld).Dimension    = {'band'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'wavelength');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'nm');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'radiation_wavelength'); % standard name
      end
      
      if isfield(D,'Chla')
        ifld = ifld + 1;
      nc(ifld).Name         = 'Chla';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'chlorophyll-a');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'mg m-3'); % ASSUMED, NOT IN MAT FILES
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'concentration_of_chlorophyll_in_sea_water'); % standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units asssumed');
  
        ifld = ifld + 1;
      nc(ifld).Name         = 'Chla_std_err';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'chlorophyll-a standard error');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'mg m-3'); % ASSUMED, NOT IN MAT FILES
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'standard_error_of_concentration_of_chlorophyll_in_sea_water'); % quasi standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units asssumed');
     %nc(ifld).Attribute(7) = struct('Name', 'cell_methods'   ,'Value', 'area: standard_deviation'); % STD in space, time, or none? NOT IN MAT FILES
      end
      
      if isfield(D,'TSM')
        ifld = ifld + 1;
      nc(ifld).Name         = 'TSM';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'suspended particulate matter');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'g m-3'); 
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'concentration_of_suspended_matter_in_sea_water'); % standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units empirically confirmed');

        ifld = ifld + 1;
      nc(ifld).Name         = 'TSM_std_err';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'suspended particulate matter standard error');% check: ASSUMED, NOT IN MAT FILES: standard error? 
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'g m-3'); 
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'standard_error_of_concentration_of_suspended_matter_in_sea_water'); % quasi standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units empirically confirmed');
     %nc(ifld).Attribute(7) = struct('Name', 'cell_methods'   ,'Value', 'area: standard_deviation'); % STD in space, time, or none? NOT IN MAT FILES
      end
 
      if isfield(D,'CDOM')
              ifld = ifld + 1;
      nc(ifld).Name         = 'CDOM';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'colored dissolved organic matter');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm-1'); % ASSUMED, NOT IN MAT FILES
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'attenuation_of_radiative_flux_due_to_dissolved_organic_matter_in_sea_water'); % quasi standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units by Steef Peters');

        ifld = ifld + 1;
      nc(ifld).Name         = 'CDOM_std_err';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'colored dissolved organic matter standard error');% check: ASSUMED, NOT IN MAT FILES: standard error? 
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm-1'); % ASSUMED, NOT IN MAT FILES
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'standard_error_of_attenuation_of_radiative_flux_due_to_dissolved_organic_matter_in_sea_water'); % quasi standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units by Steef Peters');
     %nc(ifld).Attribute(7) = struct('Name', 'cell_methods'   ,'Value', 'area: standard_deviation'); % STD in space, time, or none? NOT IN MAT FILES
      end
  
      if isfield(D,'Kd')
        ifld = ifld + 1;
      nc(ifld).Name         = 'Kd';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'band','time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'spectral extinction coefficient');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm-1'); % units empirically confirmed
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'volume_attenuation_coefficient_of_downwelling_radiative_flux_in_sea_water_per_radiation_wavelength'); % standard name
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      end
      
      if isfield(D,'L2_flags')
        ifld = ifld + 1;
      nc(ifld).Name         = 'L2_flags';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'MERIS Level 2 flags');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '24 bit bytestring'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      nc(ifld).Attribute(4) = struct('Name', 'comment1'       ,'Value', 'Refer to ESA flag codings'); 
      nc(ifld).Attribute(5) = struct('Name', 'comment2'       ,'Value', 'example bit numbers (=string index-1)'); 
      nc(ifld).Attribute(6) = struct('Name', 'comment3'       ,'Value', 'refer to: '); 
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'L2_flags_name';
      nc(ifld).Nctype       = 'char';                       % !!!!
      nc(ifld).Dimension    = {'L2_flags_bits','strlen1'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'MERIS Level 2 flags names');
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'L2_flags_bits';
      nc(ifld).Nctype       = 'int';                       % !!!!
      nc(ifld).Dimension    = {'L2_flags_bits'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'MERIS Level 2 flags bits');      
      end
      
      if isfield(D,'chisq')
        ifld = ifld + 1;
      nc(ifld).Name         = 'chisq';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'Hydropt Chi^2, sum((observed - predicted differential reflectance spectrum)^2/instrument_error^2)');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'none'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      end
      
      if isfield(D,'P')
        ifld = ifld + 1;
        ifld = ifld + 1;
      nc(ifld).Name         = 'P';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', '-10log(cumulative probability of Chi^2)');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'none'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      end

      if isfield(D,'SD')
        ifld = ifld + 1;
      nc(ifld).Name         = 'SD';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time','dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'Secchi Depth from Kd');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time x y');
      end
%% 4 Create variables with attributes
%    When variable definitons are created before actually writing the
%    data in the next cell, netCDF can nicely fit all data into the
%    file without the need to relocate any info. So there is no 
%    need to use NC_PADHEADER. nc_addvar takes most of the time, 
%    subsequent nc_varput calls are fast.
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill variables
   
      nc_varput(outputfile, 'crs'            , D.epsg);

   % double
   
      nc_varput(outputfile, 'longitude'      , double(D.lon));
      nc_varput(outputfile, 'latitude'       , double(D.lat));
      nc_varput(outputfile, 'x'              , double(D.x));
      nc_varput(outputfile, 'y'              , double(D.y));
      nc_varput(outputfile, 'L2_flags'       ,       (D.l2_flags));
      nc_varput(outputfile, 'L2_flags_name'  ,   char(D.flags.name));
      nc_varput(outputfile, 'L2_flags_bits'  ,        D.flags.bit);

   % single
   
      nc_varput(outputfile, 'spectral_bands' ,  D.bands.wavelength);
      nc_varput(outputfile, 'time'           ,  D.datenum(1) - OPT.refdatenum);
      if isfield(D,'Chla')
      nc_varput(outputfile, 'Chla'           ,  D.Chla);
      nc_varput(outputfile, 'Chla_std_err'   ,  D.Chla_std_err);
      end
      nc_varput(outputfile, 'TSM'            ,  D.TSM);
      nc_varput(outputfile, 'TSM_std_err'    ,  D.TSM_std_err);
      if isfield(D,'CDOM')
      nc_varput(outputfile, 'CDOM'           ,  D.CDOM);
      nc_varput(outputfile, 'CDOM_std_err'   ,  D.CDOM_std_err);
      end
      nc_varput(outputfile, 'Kd'             ,  D.Kd);
      nc_varput(outputfile, 'chisq'          ,  D.chisq);
      nc_varput(outputfile, 'P'              ,  D.P);
      if isfield(D,'SD')
      nc_varput(outputfile, 'SD'             , D.SD);
      end
