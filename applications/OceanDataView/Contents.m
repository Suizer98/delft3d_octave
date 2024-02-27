% OceanDataView: <a href="http://www.OpenEarth.eu">OpenEarth</a> toolbox to work with <a href="http://odv.awi.de">OceanDataView</a> ASCII files.  
% The ODV format has been chosen as one of the <a href="http://www.seadatanet.org/">SeaDataNet</a> (SDN) transport
% file formats, next to <a href="http://www.unidata.ucar.edu/software/netcdf/">netCDF</a> with <a href="http://cf-pcmdi.llnl.gov/">CF</a> + <a href="http://www.whoi.edu/virtual/oceansites/documents/index.html">oceansites</a> conventions. Parameters 
% in SDN are encoded according to the P011,P061 <a href="BODC vocabularies">BODC vocabularies</a>. 
%
% File io:
%   odv_metadata   - get contents of a directory of odv files (from csv
%                    metadata file if present, only for recent data requests)
%   odvread        - read ascii file in ODV format into ODV struct
%   odvdisp        - display contents of ODV struct
%   odv_merge      - merge ODV struct from multiple ODV files into one 
%                    single struct to be able work with a whole dataset
% Plotting:
%   odvplot_overview     - plot map view (lon,lat) of ODV struct
%   odvplot_overview_kml - plot colored dot of ODV struct in Google Earth
%   odvplot_cast         - plot profile view (value,z) of ODV struct
%
% Parameter vocabularies:
%   sdn_parameter_mapping_parse    - parse a SeaDataNet ODV parameter (SDN:list:version:element)
%   sdn_parameter_mapping_resolve  - resolves a SeaDatNet vocabulary term from 
%                                    http://vocab.ndg.nerc.ac.uk webservice using:
%   P01,P06                        - read/search BODC P011 parameter,units vocabulary
%                                    a vobabulary cache is used to enable fast offline searches
%
% Example
%
%  L = odv_metadata('F:\My downloads\userxx00x00-data_centre630-yyyy-mm-dd_result\');
%  D = odvread(L.fullfile{1},'CDI_record_id',L.CDI_record_id{1});
%  odvdisp(D)
%  odvplot_cast(D)
%
%See also: snctools

