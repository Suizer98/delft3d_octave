function ctd_timeSeriesProfile2nc(ncfile,P,M)
%ctd_timeSeriesProfile2nc write timeSeriesProfile to netCDF
%
% ctd_timeSeriesProfile2nc(ncfile,P,M)
%
% where P = ctd_timeSeriesProfile(S,ind) and [S,M]=ctd_struct(D,M)
%
%See also: ncwrite_profile, trajectory2nc
%          CF: http://cf-pcmdi.llnl.gov/
%          oceansites: http://www.oceansites.org/documents/index.html
%          SDN: http://www.seadatanet.org/Standards-Software/Data-Transport-Formats

%% Required spatio-temporal fields

   OPT2.datenum1       = P.profile_datenum;
   
   % 0D nominal/target location which will not be exactly matched by realization.
   OPT2.lon0           = mean(P.profile_lon);
   OPT2.lat0           = mean(P.profile_lat);
   
   % 1D we allow for some discrepancy between target location and realized lcoation
   OPT2.lon1           = P.profile_lon;
   OPT2.lat1           = P.profile_lat;
   
   % 1D: centres of fixed 4 m binned data (processed, L2) data
   OPT2.z2             = P.z;
   OPT2.var            = P.data;
   
%% Required data fields: CF
  [~,~,OPT2.Name]          = donar.resolve_wns(M.data.WNS);
   OPT2.standard_name      = M.data.standard_name;
   OPT2.long_name          = M.data.long_name;
   OPT2.units              = M.data.units;

%% Required data fields: SDN
   OPT2.Attributes         = {'sdn_parameter_urn'  ,M.data.sdn_parameter_urn ,...
                              'sdn_parameter_name' ,M.data.sdn_parameter_name,...
                              'sdn_uom_urn'        ,M.data.sdn_uom_urn       ,...
                              'sdn_uom_name'       ,M.data.sdn_uom_name      ,...
                              'aquo_grootheid_code',donar.resolve_wns(M.data.WNS,'request','parcod')};
  
%% Required data fields: discovery
   OPT2.global         = {'Conventions'                 ,'CF-1.6, OceanSITES 1.1, SeaDataNet_1.0',...
                          'geospatial_lat_units'        ,M.lat.units,...
                          'geospatial_lon_units'        ,M.lon.units,...
                          'geospatial_vertical_units'   ,M.z.units,...
                          'geospatial_vertical_positive',M.z.positive,...
                          'title'                       ,'CTD profiles from vessel Zirfaea at one North Sea location',...
                          'references'                  ,'http://www.researchvessels.org/ship_info_display.asp?shipID=543,http://www.marinetraffic.com/nl/ais/details/ships/246096000,http://www.rijkswaterstaat.nl/images/Zirfaea_tcm174-263725.pdf',...
                          'email'                       ,'http://www.helpdeskwater.nl',...
                          'source'                      ,'http://www.helpdeskwater.nl',...
                          'institution'                 ,'Rijkswaterstaat',...
                          'SDN_EDMO_CODE'               ,'raw data: 1526,1527,1603 netCDF:1528',... % http://seadatanet.maris2.nl/v_edmo/print.asp?n_code=1526
                          'history'                     ,'Created with the OpenEarthTools Matlab +donar package $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/ctd_timeSeriesProfile2nc.m $ $Id: ctd_timeSeriesProfile2nc.m 10168 2014-02-07 07:22:17Z boer_g $'};
                      
% http://publicwiki.deltares.nl/display/NETCDF/UM+Aquo+Standard+names
%//!! UMAquo 201x should prescribe the names of the required and optional 
%//!! attributes that contain contents from the tables. Here are preliminary names
%//!! after a discussion with Hinne Reitsma (IHW) and Gerben de Boer (Deltares)
%//!! Any netCDF client can count on these keywords to be present when UMAquo 
%//!! 201x is part of the global attribiute 'Conventions', see below.
%//!!
%//!! required: code form tables, same status as mandatory CF standard_name and units
%//!!
%//!!		sea_water_salinity:aquo_grootheid_code = "SALNTT" 
%//!!		sea_water_salinity:aquo_grootheid_typering_code = "?" 
%//!!		sea_water_salinity:aquo_eenheid_code = "?" 
%//!!		sea_water_salinity:aquo_hoedanigheid_code = "?" 
%//!!		sea_water_salinity:aquo_compartiment_code = "?" 
%//!!
%//!! optional: human readable text (resolved RDF), same status as optional CF long_name
%//!!
%//!!		sea_water_salinity:aquo_grootheid_omschrijving = "?" 
%//!!		sea_water_salinity:aquo_grootheid_typering_omschrijving = "?" 
%//!!		sea_water_salinity:aquo_eenheid_omschrijving = "?" 
%//!!		sea_water_salinity:aquo_hoedanigheid_omschrijving = "?" 
%//!!		sea_water_salinity:aquo_compartiment_omschrijving = "?" 
%//!!		
%//!!		sea_water_salinity:donar_wnsnum = 559 
%//!!		sea_water_salinity:sdn_standard_name = "P011/185/ODSDM021" 

% SDN_CRUISE       – this is an array (which can have a dimension of 1 for single object storage) containing text strings identifying a grouping label for the data object to which the array element belongs. This will obviously be the cruise name for data types such as CTD and bottle data, but could be something like a mooring name for current meter data. Note that NetCDF only supports fixed length string variables, set at 80 bytes in the SeaDataNet profiles.
% SDN_STATION      – this is an array of text strings identifying the data object to which the array element belongs. This will be the station name for some types of data, but could also be an instrument deployment identifier. Again fixed-length size is set to 80 bytes.
% SDN_LOCAL_CDI_ID - this is an array of text strings containing the local identifier of the Common Data Index record associated with the data object to which the array element belongs. The maximum size allowed for this parameter is 80 bytes.
% SDN_EDMO_CODE    – this is an integer array containing keys identifying the organisation responsible for assigning the label used in SDN_LOCAL_CDI_ID given in the European Directory of Marine Organisations (EDMO). This provides the namespace for the label.
% SDN_BOT_DEPTH    – this is a floating point array holding bathymetric water depth in metres where the sample was collected or measurement was made. Set to the fill value (-999) if unknown or inapplicable.                      

%% write

   ncwrite_profile(ncfile,OPT2)