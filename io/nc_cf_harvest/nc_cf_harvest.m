function D = nc_cf_harvest(ncfiles,varargin)
%NC_CF_HARVEST  extract CF + THREDDS meta-data from list of netCDF/OPeNDAP urls
%
%    struct = nc_cf_harvest(ncfiles)
%
% harvests (extracts) <a href="http://cf-pcmdi.llnl.gov/">CF meta-data</a> + <a href="http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/index.html">THREDDS catalog</a>
% meta-data from cell list of ncfiles (netCDF file/OPeNDAP url)
% into an array of multi-layered structs.
%
% nc_cf_harvest can return the harvesting results as
% flat arrays which is memory efficient for a large
% ncfiles list, or as a nested structure, use keyword 'flat'.
%
% Rename url from a lcal rwesource with intended web 
% web location for publication with urlPathFcn.
%
% NC_CF_HARVEST is a simple loop around NC_CF_HARVEST1 
% that extracts only one ncfile (netCDF file/OPeNDAP url).
%
% Use OPENDAP_CATALOG to obtain a list of netCDF 
% files to which you can apply NC_CF_HARVEST or call.
% You can do this before calling to seperate crawling
% and harvesting, or let nc_cf_harvest do the crawling too
% by sypplying a url instead of a list of ncfiles:
%
%  struct = nc_cf_harvest(opendap_url)
%
% You can save the harvesting results to a THREDDS catalog.xml
% a netCDF file or excel file, with with NC_CF_HARVEST2XML,
% NC_CF_HARVEST2NC or NC_CF_HARVEST2XLS. You can also let
% NC_CF_HARVEST do it with struc keyword 'catalog'.
%
%  +--------------------------------------+
%  |for each dataset node:                |
%  |NC_CF_HARVEST                         |
%  |   +----------------------------------+
%  |   |crawler:                          |
%  |   |OPENDAP_CATALOG                   |
%  |   +----------------------------------+
%  |   |for each dataset node:            |
%  |   |                                  |
%  |   |   +------------------------------+
%  |   |   |harvester:                    |
%  |   |   |NC_CF_HARVEST_tuple2matrix    |
%  |   +---+------------------------------+
%  |   |Store meta-data in cache:         |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST_matrix2xml       |
%  |   |   THREDDS standard xsd           |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST_matrix2nc        |
%  |   |    using STRUCT2NC               |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST_matrix2xls       |
%  |   |    using STRUCT2XLS              |
%  |   +----------------------------------+
%  |   |   NC_CF_HARVEST_matrix2kml       |
%  |   |    for time series               |
%  +---+----------------------------------+
%
% Example: where crawling, harvesting and caching to xml are separated
%
%  url = 'd:\opendap.deltares.nl\thredds\dodsC\opendap\knmi\etmgeg\'
%  L   = opendap_catalog(url)
%  C   = nc_cf_harvest(L)
%  nc_cf_harvest2xml('etmgeg.xml',C)
%
% Example: everything carried out by NC_CF_HARVEST
%
%  url = 'd:\opendap.deltares.nl\thredds\dodsC\opendap\knmi\etmgeg\'
%  C   = nc_cf_harvest(url,'cataliog.xml','etmgeg.xml')
%
%See also: OPENDAP_CATALOG, NC_CF_HARVEST1, nc_cf_harvest2xml, nc_cf_harvest2nc, nc_cf_harvest2xls
%          thredds_dump, thredds_info,NC_INFO, nc_dump, NC_ACTUAL_RANGE, 
%          ncgentools_generate_catalog
%          python module "openearthtools.io.opendap.dapcrawler"

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
% $Id: nc_cf_harvest.m 8393 2013-03-29 17:20:33Z boer_g $
% $Date: 2013-03-30 01:20:33 +0800 (Sat, 30 Mar 2013) $
% $Author: boer_g $
% $Revision: 8393 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest.m $
% $Keywords$

   OPT.debug         = Inf; % number of ncfiles to process
   OPT.disp          = ''; %'multiWaitbar';
   OPT.flat          = 1;  % flat is struct with matrices, else multi-layered struct with tuples
   OPT.urlPathFcn    = @(s)(s); % function to run on urlPath, as e.g. strrep
   OPT.catalog.xml   = '';
   OPT.catalog.xls   = '';
   OPT.catalog.nc    = '';
   OPT.catalog.mat   = '';
  %OPT.catalog.pgn   = ''; % TO DO
   OPT.log           = 2; % log progress, 0 = quiet, 1 = command line (2 = red), nr>1 = fid passed to fprintf (default 0)

   OPT.save2temp     = 50; % interval at which to save temp file
   OPT.resume.ind    = 1;  % where to resume from cached temp file after crash
   OPT.resume.file   = ''; % where to resume from cached temp file after crash
   
   OPT.ID            = 'institution/dataset/';
   OPT.name          = 'institution_dataset';

   OPT.documentation.summary   = '';
   OPT.documentation.title     = '';
   OPT.documentation.url       = '';
   
   OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
   OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
   OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'
   
   OPT = setproperty(OPT,varargin);
   
   if nargin==0
      D = OPT;return
   end
   
   %if any(structfun(@(x) ~isempty(x), OPT.catalog)) & ~(OPT.flat)
   %   warning('exporting catalog is more efficient with flat data storage')
   %end
   
   if ~iscell(ncfiles)
      url     = ncfiles;
      ncfiles = opendap_catalog(url);
   end

   if ~isempty(OPT.debug) && ~isinf(OPT.debug) && ~(OPT.debug==0)
      ncfiles = {ncfiles{1:min(OPT.debug,length(ncfiles))}};
   end
   n       = length(ncfiles);

%% initialize and fill file names

   if ~(OPT.flat) % best for nested storage formats: xml

      D  = nc_cf_harvest_tuple_initialize(n,'featuretype',OPT.featuretype);
      for i=1:n
      D(i).urlPath = ncfiles{i};
      end
      
   else % best for flat storage formats: netCDF and Excel

        D = nc_cf_harvest_matrix_initialize(n);
        D.urlPath = ncfiles;
        
   end
   
%% now get rest of meta-data

   % initialize harvest waitbar
   if strcmpi(OPT.disp,'multiWaitbar')
   multiWaitbar(mfilename,0,'label','Generating catalog.nc','color',[0.3 0.6 0.3])
   end
   
   tempname = [tempdir,filesep,mfilename];
   
   % resume from cached tempname
   if ~isempty(OPT.resume.file)
      D = load(OPT.resume.file);
   end

   for i=OPT.resume.ind:n

      if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar([mfilename],i/n,'label',['Harvesting ...',filename(ncfiles{i})]);
      else
      disp([num2str(i) ' ' num2str(n) ' ' ncfiles{i}])
      end
      
      try
         d    = nc_cf_harvest_tuple_from_file(ncfiles{i},'featuretype',OPT.featuretype);
      catch
         d    = nc_cf_harvest_tuple_initialize;
         dprintf(OPT.log,[' skipped erronous ',ncfiles{i},'\n'])
      end      

      if ~(OPT.flat)
         D(i) = d;
      else % better performance (memory management)
         D    = nc_cf_harvest_tuple2matrix(d,D,i);
      end % flat
      
      if mod(i,OPT.save2temp)==0
         save(tempname,'-struct','D');
         disp([' cached results to ',tempname]) 
      end

   end % i
   
%% Replace local file names with remote OPeNDAP urls (after extracting variables above)

      if ~(OPT.flat)   
         for i=1:n
             D(i).urlPath = OPT.urlPathFcn(D(i).urlPath);
         end
      else
      D.urlPath       = OPT.urlPathFcn(D.urlPath);
      end

%% Export to caches   

   save(tempname,'-struct','D'); % in case of failure below keep something
   disp(['cached results to ',tempname])

   if ~isempty(OPT.catalog.mat)
      save(OPT.catalog.mat,'-struct','D');
   end
   
   if ~isempty(OPT.catalog.xml)
      nc_cf_harvest_matrix2xml(OPT.catalog.xml,D,'ID',OPT.ID,'name',OPT.name,'documentation',OPT.documentation);
   end

   if ~isempty(OPT.catalog.xls)
      nc_cf_harvest_matrix2xls(OPT.catalog.xls,D);
   end
   
   if ~isempty(OPT.catalog.nc)
      nc_cf_harvest_matrix2nc(OPT.catalog.nc,D);
   end
   
   %if ~isempty(OPT.catalog.pgn) % to do PostgreSQL geonetwork RDBMS datamodel
   %   nc_cf_harvest_matrix2nc(OPT.catalog.pgn,D);
   %end
