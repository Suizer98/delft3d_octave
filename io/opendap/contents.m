% Tools for handling meta-data and data from an <a href="http://www.opendap.org/">OPeNDAP</a> server
%
% Three implemenations for OPeNDAP servers exist: 
% * <a href="http://www.unidata.ucar.edu/projects/THREDDS/">TDS: THREDDS Data Server</a> 
% * <a href="http://www.opendap.org/download/hyrax.html">HYRAX</a> 
% * <a href="http://www.pydap.org/server.html">pydap</a>
% * <a href="http://www.iges.org/grads/gds/">GDS: GrADS Data Server</a>.
% This toolbox is most frequencly being used with THREDDS.
%
% A non-exhaustive list of operational OPeNDAP servers for marine, coastal and climate data is:
% * NL: Delft: <a href="http://opendap.deltares.nl/">http://opendap.deltares.nl/</a> (THREDDS + HYRAX)
% * NL: 3TU: <a href="http://opendap.tudelft.nl/thredds/catalog.html">http://opendap.tudelft.nl/thredds/catalog.html</a>
% * NL: Delft: <a href="http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/">http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/</a> (THREDDS + pydap test)
% * NL: Rijkswaterstaat: <a href="http://matroos.deltares.nl:8080/thredds/">http://matroos.deltares.nl:8080/thredds/</a> (THREDDS + password)
% * NL: Rijkswaterstaat: <a href="http://matroos.deltares.nl/direct/opendap.html">http://matroos.deltares.nl/direct/opendap.html</a> (HYRAX + password)
% * NL: KNMI (test): <a href="http://geoservices.knmi.nl/thredds/catalog.html">http://geoservices.knmi.nl/thredds/catalog.html</a> (THREDDS)
% * NL: NMDC (test): <a href="http://geoservices.knmi.nl/thredds/catalog.html">http://opendap.nmdc.nl/knmi/thredds/catalog.html</a> (THREDDS)
% * FR: IFREMER: <a href="http://www.ifremer.fr/thredds/catalog.html">http://www.ifremer.fr/thredds/catalog.html</a> (THREDDS)
% * US: NOAA NCEP <a href="http://nomads.ncep.noaa.gov:9090/dods">http://nomads.ncep.noaa.gov:9090/dods</a> (GrADS)
% * US: NASA GSFC: <a href="http://agdisc.gsfc.nasa.gov/dods">agdisc</a>, <a href="http://nsipp.gsfc.nasa.gov:9090/dods">nsipp</a>, <a href="http://voda.gsfc.nasa.gov:9090/dods">voda</a>, <a href="http://goldsmr1.sci.gsfc.nasa.gov/dods">goldsmr1</a>, ~<a href="http://goldsmr2.sci.gsfc.nasa.gov/dods">2</a>, ~<a href="http://goldsmr3.sci.gsfc.nasa.gov/dods">3</a> (GrADS)
% * US: USGS: <a href="http://coast-enviro.er.usgs.gov/thredds/">http://coast-enviro.er.usgs.gov/thredds/</a> (THREDDS)
% * US: NOAA NODC: <a href="http://data.nodc.noaa.gov/opendap">http://data.nodc.noaa.gov/opendap</a> (HYRAX)  
%                  <a href="http://data.nodc.noaa.gov/thredds/catalog.html">http://data.nodc.noaa.gov/thredds/catalog.html</a> (THREDDS)
% * US: NOAA NDBC: <a href="http://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.html">http://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.html</a> (THREDDS)
% * US: NOAA NCDC: <a href="http://nomads.ncdc.noaa.gov/dods/">http://nomads.ncdc.noaa.gov/dods/</a> (GrADS) <a href="http://nomads.ncdc.noaa.gov/thredds/catalog.html">http://nomads.ncdc.noaa.gov/thredds/catalog.html</a> (THREDDS)
% * US: NOAA :     <a href="http://dm1.caricoos.org/thredds/catalog/">CARICOOS</a> (THREDDS)
% * US: NOAA :     <a href="http://www.weather.gov/ndfd/technical.htm">NDFD</a> (no direct opendap, but loads of data)
% * US: NOAA :     <a href="http://dapper.pmel.noaa.gov/dchart/">PMEL DAPPER</a> (no direct opendap, but loads of data)
% * US: Great Lakes: <a href="http://michigan.glin.net/thredds/catalog.html">http://michigan.glin.net/thredds/catalog.html</a> (THREDDS)
% * US: UCAR: <a href="http://motherlode.ucar.edu/thredds/catalog.html">http://motherlode.ucar.edu/thredds/catalog.html</a> (THREDDS)
% * EU: EUMETSAT: <a href="http://gsics.eumetsat.int/thredds/catalog.html">http://gsics.eumetsat.int/thredds/catalog.html</a> (THREDDS)
% * EU: Norway met office: <a href="http://thredds.met.no/thredds/catalog.html">http://thredds.met.no/thredds/catalog.html</a> (THREDDS)
% * Godae <a href="http://www.usgodae.org/dods/GDS">http://www.usgodae.org/dods/GDS</a> (GrADS)
%
%   opendap_catalog       - crawler for THREDDS OPeNDAP catalogues: returns set of urls
%                           NB: these Dataset urls from an OPeNDAP server can be 
%                           accessed directly with the snctools (only THREDDS + HYRAX, not GrADS).
%   opendap_get_cache     - get a local cache of an opendap folder (catalogRef)
%   nc_cf_opendap2catalog - harvester for netCDF-CF in THREDDS OPeNDAP catalogues: returns meta-data
%                           runs on top of the OPENDAP_CATALOG crawler
%
%See also: snctools, nctools
