function varargout = opendap_catalog_dataset(D,OPT)
%OPENDAP_CATALOG_DATASET   get urls of all datasets in an OPeNDAP catalog.xml read by xml_read
%
%   urlPath = opendap_catalog_dataset(D,OPT)
%
% returns all urls.
%
% subsidiary of OPENDAP_CATALOG.
%
%See also: OPENDAP_CATALOG, XML_READ, XMLREAD, SNCTOOLS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
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
% $Id: opendap_catalog_dataset.m 8367 2013-03-22 08:20:26Z boer_g $
% $Date: 2013-03-22 16:20:26 +0800 (Fri, 22 Mar 2013) $
% $Author: boer_g $
% $Revision: 8367 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/opendap/opendap_catalog_dataset.m $
% $Keywords: $

%% SERVICE
%  Note: there can be multiple services,e.g.
%  http://coast-enviro.er.usgs.gov/thredds/roms_catalog.html

   if isfield(D,'service')
   
      % Loop toplevel services
      % Examples are:
      % * 'http://coast-enviro.er.usgs.gov/thredds/roms_catalog.xml';
      % * 'http://opendap.deltares.nl/thredds/enhancedCatalog.xml'; % compound service: error

      for i=1:length(D.service)
      
         if OPT.debug
            dprintf(OPT.log,['opendap_catalog: xml.service(',num2str(i),').\n'])
            dprintf(OPT.log,['fieldnames: ',str2line(fieldnames(D.service(i)),          's',','),'\n'])
           %dprintf(OPT.log,[str2line(fieldnames(D.service(i)).ATTRIBUTE,'s',','),'\n'])
         end      
         
         %% check overall service ...
         
         serviceType = D.service(i).ATTRIBUTE.serviceType;
         
         if strcmpi(serviceType,OPT.serviceType)
             OPT.serviceBase = D.service(i).ATTRIBUTE.base;
             OPT.serviceName = D.service(i).ATTRIBUTE.name;
         else
         
         %% ... else all individual services
         
            for ii=1:length(D.service(i).service)
            serviceType   = D.service(i).service(ii).ATTRIBUTE.serviceType;
            if strcmpi(serviceType,OPT.serviceType)
                OPT.serviceBase = D.service(i).service(ii).ATTRIBUTE.base;
                OPT.serviceName = D.service(i).service(ii).ATTRIBUTE.name;
                break
            end
            end
         end
         
      end % for i=1:length(D.service)
      
   end % isfield(D,'service')
   
%% get absolute web- or absolute/relative local- baseURL from catalog file name

   if strcmpi(OPT.url(1:7),'http://') | ...
      strcmpi(OPT.url(1:8),'https://')
      ind                = strfind(OPT.url,'/');
      OPT.serviceBaseURL = [OPT.url(1:ind(3)-1) OPT.serviceBase];
   else
      OPT.serviceBaseURL = fileparts(OPT.url);
   end
   urlFolder   = OPT.serviceBaseURL;
   
%% pre-allocate

   urlPath     = {}; % for current level we cannot pre-allocate as some datasets may be a container with lots of urlPaths inside it
   urlPath2add = {}; % for just one dataset in current level

% TO DO get TDS metadata    = {};

%% DATASET
%  * Can be container of 
%  * local data consisting of:
%    - dataset
%    - catalogRef
      
   if isfield(D,'dataset')
   
   if strcmpi(OPT.disp,'multiWaitbar')
   multiWaitbar([mfilename,'_catalogref'],0,'label','processing dataset ','color',[0.3 0.6 0.3])
   end
   
   %% loop datasets

      for i=1:length(D.dataset) % thredds_COLON_dataset
          
      if strcmpi(OPT.disp,'multiWaitbar')
         multiWaitbar([mfilename,'_catalogref'],i/length(D.dataset),'label',['processing dataset ',num2str(i),'/',num2str(length(D.dataset))]);
      elseif ~isempty(OPT.disp) | OPT.disp==0
         disp([repmat('    ',[1 OPT.level]),num2str(i),'/',num2str(),' processing level ',num2str(OPT.level),' dataset']);
      end
         
      %% get service type for inheritance
     
         if isfield(D.dataset(i),'metadata')
         if isfield(D.dataset(i).metadata,'ATTRIBUTE')
         if isfield(D.dataset(i).metadata.ATTRIBUTE,'inherited')
         if strcmpi(D.dataset(i).metadata.ATTRIBUTE.inherited,'true')
         if isfield(D.dataset(i).metadata,'serviceName')
         
% TO DO :loop over D.service(ii)
% make cellstr of inherited serviceNames that contain requested OPT.serviceName

if length(D.service) > 1
    disp(['ERROR: nested services not yet implemented in :',OPT.url])
end
         if strcmpi(D.dataset(i).metadata.serviceName,D.service.ATTRIBUTE.name) | ...
            strcmpi(D.dataset(i).metadata.serviceName,OPT.serviceName)
            OPT.serviceName_inherited = OPT.serviceName;
         end % serviceName
         end % true
         end % inherited
         end % ATTRIBUTE
         end % inherited
         end % metadata   

      %% 

      if isfield(D.dataset(i),'ATTRIBUTE')

         if OPT.debug
            dprintf(OPT.log,['opendap_catalog: xml.dataset.(...).dataset(',num2str(i),'/',num2str(length(D.dataset)),').\n'])
            dprintf(OPT.log,['fieldnames: ',str2line(fieldnames(D.dataset(i)),'s',','),'\n'])
           %dprintf(OPT.log,[char(fieldnames(D.dataset(i).ATTRIBUTE)),'\n'])
         end
      
         if ~isfield(D.dataset(i).ATTRIBUTE,'name')
            
            dprintf(OPT.log,'dataset has no name \n')
            
         else

         %% obtain (inherited) service name of dataset (can be [])
         
            if isfield(D.dataset(i),'serviceName')
                serviceName = D.dataset(i).serviceName;
            else
                serviceName = OPT.serviceName_inherited;
            end
            
% TO DO: serviceName can be compound service name: check whether requested OPT.serviceName is in it
% TO DO: check whether serviceName is indeed requested OPT.serviceName
% TO DO: if ~isempty(serviceName)

            if isfield(D.dataset(i).ATTRIBUTE,'urlPath')
            
         %% DIRECT dataset = create link
         %  obtain (inherited) service name of dataset (can be [])
         %  get all netCDF files with requested service name (type: OPENDAP)
            
               access.urlPath = D.dataset(i).ATTRIBUTE.urlPath;
               service.suffix = '';
               len            = length(access.urlPath);
               urlPath2add    = [OPT.serviceBaseURL access.urlPath service.suffix];
               % TO DO get TDS metadata2add   = D.dataset(i);
               % TO DO get TDS  %metadata2add   = rmfield(metadata2add,'ATTRIBUTE');
      
         %% INDIRECT dataset = container for datasets/catalog
         %  get deeper levels (recursive)
               
            elseif isfield(D.dataset(i),'dataset') | ...
                   isfield(D.dataset(i),'catalogRef')
      
               if OPT.debug
               dprintf(OPT.log,'digging deeper dataset/catalogRef \n')
               end
               urlPath2add = opendap_catalog_dataset(D.dataset(i),OPT);
               
         %% EMPTY dataset

            else
               
               if OPT.debug
               dprintf(OPT.log,'empty dataset \n')
               end
      
            end % ~isempty(serviceName)
               
         end % if ~isfield(dataset(i).ATTRIBUTE,'name')
         
% TO DO: end % if ~isempty(serviceName)
      
      end % isfield(dataset,'ATTRIBUTE')
         
      if ~isempty(urlPath2add) % prevent memory fragmentation by empty datasets
         urlPath   = cellstr(strvcat(char(urlPath),char(urlPath2add)));
      end
      
      end % i=1:length(dataset)

   end % if isfield(D,'catalogRef')

%% CATALOGREF
%  get deeper levels (recursive)
% 
% | http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#catalogRef:
% | 
% | Constructing URLs
% | The standard way to construct a dataset URL is to concatenate the service base with the access urlPath. If the service also has a sufffix, that is appended:
% | 
% |    URL = service.base + access.urlPath + service.suffix
% | 
% | A common mistake is to forget the trailing slash at the end of the service base URL.
% | Clients have access to each of these elements and may make use of the URL in protocol-specific ways. For example the OpenDAP (DODS) protocol appends dds, das, dods etc to make the actual calls to the OpenDAP server.
% | When a service base is a relative URL, it is resolved against the catalog URL. For example if the catalog URL is http://motherlode.ucar.edu:8080/thredds/dodsC/catalog.xml, and a service base is airtemp/, then the resolved base is http://motherlode.ucar.edu:8080/thredds/dodsC/airtemp/. Note that if the service base is /airtemp/, the resolved URL is http://motherlode.ucar.edu:8080/airtemp/. The java.net.URI class in JDK 1.4+ will resolve relative URLs. 
   
   if isfield(D,'catalogRef')
   
   if strcmpi(OPT.disp,'multiWaitbar')
      multiWaitbar([mfilename,'_dataset'],0,'label','processing catalogRef ','color',[0.3 0.6 0.3])
   end

      OPT2       = OPT;
   
      for i=1:length(D.catalogRef)

         if strcmpi(OPT.disp,'multiWaitbar')
            multiWaitbar([mfilename,'_dataset'],i/length(D.catalogRef),'label',['processing catalogRef ',num2str(i),'/',num2str(length(D.catalogRef))]);
         elseif ~isempty(OPT.disp) | OPT.disp==0
            disp([repmat('    ',[1 OPT.level]),num2str(i),'/',num2str(length(D.catalogRef)),' processing level ',num2str(OPT.level),' catalog'])
         end         

         if OPT.debug
            dprintf(OPT.log,'opendap_catalog: xml.dataset.catalogRef. \n')
            dprintf(OPT.log,[str2line(fieldnames(D.catalogRef(i))          ,'s',','),'\n'])
            dprintf(OPT.log,[str2line(fieldnames(D.catalogRef(i).ATTRIBUTE),'s',','),'\n'])
         end
         
         %  note that serviceBaseURL is different for catalogRef than for a dataset
         %  example: a top level catalog has no services, e.g. http://coast-enviro.er.usgs.gov/thredds/catalog.xml
   
         OPT2.serviceBaseURL = [fileparts(OPT.url) '/'];
         access.urlPath      = D.catalogRef(i).ATTRIBUTE.href; % wrt current catalog
                              %D.catalogRef(i).ATTRIBUTE.ID    % unique ID wrt ???
         service.suffix      = '';

      % in HYRAX and empty catalog at the bottom of the tree
      % refert to itself. This can be seen by looking at the 
      % * hfref: that refers relative to a url reletive to the catalog 
      % * id:    that refers relative to the top-level catalog 
      % If the ID points to the catalog it is in, it is such a dead-end.
      % Examples are:
      % * 'http://opendap.deltares.nl/opendap/rijkswaterstaat/jarkus/grids/KMLpreview/jarkusKB112_4544/catalog.xml';
      % * 'http://data.nodc.noaa.gov/opendap/NESDIS_DataCenters/metadata/Geomag_Stations/catalog.xml';
      % * 'http://data.nodc.noaa.gov/opendap/woa/ANOMALY/catalog.xml';
      
      url = path2os([OPT2.serviceBaseURL                              ],'u');
      if isfield(D.catalogRef(i).ATTRIBUTE,'ID')
      ID  = path2os([OPT.toplevel '/' D.catalogRef(i).ATTRIBUTE.ID '/'],'u');
      else
      % Not all catalogs contain IDs:
      % Examples are:
      % http://coast-enviro.er.usgs.gov/thredds/catalog.xml
      ID = [];
      end
      
      if ~strcmpi(url,ID)

      % EXTERNAL CATALOG reference (absolute)
      % this is always considerd one level deeper (tree and link)

         if strcmpi(access.urlPath(1:7),'http://')

            OPT2.level = OPT.level + 1;
            OPT2.url   = [access.urlPath service.suffix];

            if ~OPT.external
            
               dprintf(OPT.log,['Skipping external   catalog: ',OPT2.url,'\n'])
                
            else
         
               OPT2.serviceName_inherited = [];
              %OPT2.serviceBaseURL        = ''; % RESET ?
               urlPath2add                = opendap_catalog(OPT2);
            
            end % OPT.external

      % LOCAL CATALOG reference (relative to catalog root or relative to catalog url)
      % against catalog root: http://opendap.deltares.nl/thredds/catalog.html            
      % against catalog url:  http://opendap.deltares.nl/thredds/catalog/opendap/catalog.html   

         else
         
            if access.urlPath(1)=='/' % against catalog root
               ind        = strfind(OPT.serviceBaseURL,'/');
               OPT2.url   = [OPT.serviceBaseURL(1:ind(3)-1) access.urlPath service.suffix];
            else % against catalog url
               OPT2.url   = [OPT2.serviceBaseURL access.urlPath service.suffix];
            end
            
            % question: is the level related to the links, or to position in the opendap tree?
            % local catlogs are meant to make admin easier, so we can consider them as same level?
            if     strcmpi(OPT.leveltype,'link')
               OPT2.level = OPT.level + 1;
            elseif strcmpi(OPT.leveltype,'tree')
               slashes    = strfind(access.urlPath,'/');
               OPT2.level = OPT.level + length(slashes);
            end

            OPT2.serviceName_inherited = [];
            urlPath2add                = opendap_catalog(OPT2);

         end % if strcmpi(access.urlPath(1:7),'http://')
         
         if ~isempty(urlPath2add)
            urlPath = cellstr(strvcat(char(urlPath),char(urlPath2add)));
         end
         
      end % if ~strcmpi(url,ID)         
         
      end % for i=1:length(D.catalogRef)
      
   end % if isfield(D,'catalogRef')
   
% TO DO   if nargout==1
             varargout = {urlPath};
% TO DO   else
% TO DO      varargout = {urlPath,urlFolder};
% TO DO   end
  
   %% EOF