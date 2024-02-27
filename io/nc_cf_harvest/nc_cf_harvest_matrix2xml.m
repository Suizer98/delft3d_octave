function varargout = nc_cf_harvest_matrix2xml(xmlname,D,varargin)
%nc_cf_harvest_matrix2xml  write nc_cf_harvest object to THREDDS catalog.xml
%
% L = opendap_catalog  (opendap_url) % crawl
% C = nc_cf_harvest    (L)
%     nc_cf_harvest_matrix2xml(xmlname,C)
%
% writes matrix-based nc_cf_harvest object D to THREDDS catalog.xml file.
%
%See also: NC_CF_HARVEST, nc_cf_harvest2nc, nc_cf_harvest2xls,
%          thredds_dump, thredds_info

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
% $Id: nc_cf_harvest_matrix2xml.m 8383 2013-03-28 17:44:47Z boer_g $
% $Date: 2013-03-29 01:44:47 +0800 (Fri, 29 Mar 2013) $
% $Author: boer_g $
% $Revision: 8383 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_matrix2xml.m $
% $Keywords$

%% https://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.3/InvCatalogSpec.server.html

OPT.ID                      = 'institution/dataset';
OPT.name                    = 'institution_dataset';

OPT.creator.name            = 'OpenEarth';
OPT.creator.contact.url     = 'http://www.openearth.eu';
OPT.creator.contact.email   = 'gerben.deboer@deltares.nl';

OPT.publisher.name          = '';
OPT.publisher.contact.url   = '';
OPT.publisher.contact.email = '';

OPT.dataType                = ''; % 'GRID'

OPT.documentation.summary   = '';
OPT.documentation.title     = '';
OPT.documentation.url       = '';

if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT,varargin);

fid = fopen(xmlname,'w');

output = fprintf(fid,'%s\n',['<?xml version="1.0" encoding="UTF-8"?>']);
output = fprintf(fid,'%s\n',['<catalog xmlns="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0.1">']);
output = fprintf(fid,'%s\n',['  <service name="allServices"   serviceType="Compound" base="">']);
output = fprintf(fid,'%s\n',['    <service name="dapService"  serviceType="OPENDAP"  base="/thredds/dodsC/"/>']);
output = fprintf(fid,'%s\n',['    <service name="httpService" serviceType="Download" base="/thredds/fileServer/"/>']);
output = fprintf(fid,'%s\n',['  </service>']);

output = fprintf(fid,'%s\n',['  <dataset name="',path2os(OPT.name,'http'),'" ID="varopendap/',path2os(OPT.ID,'http'),'">']);

output = fprintf(fid,'%s\n',['    <metadata inherited="true">']);
output = fprintf(fid,'%s\n',['      <serviceName>allServices</serviceName>']);
output = fprintf(fid,'%s\n',['      <dataType>',OPT.dataType,'</dataType>']);
output = fprintf(fid,'%s\n',['      <documentation xlink:href ="',  OPT.documentation.url,'"']); 
output = fprintf(fid,'%s\n',['                     xlink:title="',  OPT.documentation.title,'"/>']);
output = fprintf(fid,'%s\n',['      <documentation type="Summary">',OPT.documentation.summary,'</documentation>']);
if 0
output = fprintf(fid,'%s\n',['      <creator>']);
output = fprintf(fid,'%s\n',['        <name vocabulary="DIF">',OPT.creator.name,'</name>']);
output = fprintf(fid,'%s\n',['        <contact url="',         OPT.creator.contact.url,'" email="',OPT.creator.contact.email,'"/>']);
output = fprintf(fid,'%s\n',['      </creator>']);
output = fprintf(fid,'%s\n',['      <publisher>']);
output = fprintf(fid,'%s\n',['        <name vocabulary="DIF">',OPT.publisher.name,'</name>']);
output = fprintf(fid,'%s\n',['        <contact url="',         OPT.publisher.contact.url,'" email="',OPT.publisher.contact.email,'"/>']);
output = fprintf(fid,'%s\n',['      </publisher>']);

% <variables vocabulary="CF-1.0">
%   <variable name="wv" vocabulary_name="Wind Speed" units="m/s">Wind Speed @ surface</variable>
%   <variable name="wdir" vocabulary_name="Wind Direction" units= "degrees">Wind Direction @ surface</variable>
%   <variable name="o3c" vocabulary_name="Ozone Concentration" units="g/g">Ozone Concentration @ surface</variable>
% </variables>

end 
output = fprintf(fid,'%s\n',['    </metadata>']);

n  = length(D.urlPath);

   for j=1:n

      output = fprintf(fid,'%s\n',['']);

% URL

      output = fprintf(fid,'%s\n',['<dataset name   ="',             filenameext(D.urlPath{j}) '"']);
      output = fprintf(fid,'%s\n',['ID     ="varopendap/',OPT.ID,'/',filenameext(D.urlPath{j}),'"']);
      output = fprintf(fid,'%s\n',['urlPath=   "opendap/',OPT.ID,'/',filenameext(D.urlPath{j}),'">']);

      %% files (thredds auto metadata)
      if isfield(D,'dataSize') && ~isnan(D.dataSize(j))
      output = fprintf(fid,'%s\n',['<dataSize units="Mbytes">',num2str(D.dataSize(j)./1e6)                ,'</dataSize>']);
      end
      if isfield(D,'date') && ~isnan(D.date(j))
      output = fprintf(fid,'%s\n',['<date type="modified">'   ,datestr(D.date(j),'yyyy-mm-ddTHH:MM:SSZ'),'</date>']);
      end

% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   

      output = fprintf(fid,'<variables vocabulary="%s">\n',D.Conventions{j});
      variable_name = strtokens2cell(D.variable_name{j});
      standard_name = strtokens2cell(D.standard_name{j});
      units         = strtokens2cell(D.units{j});
      long_name     = strtokens2cell(D.long_name{j});
      
      for ivar=1:length(variable_name)
      output = fprintf(fid, '<variable name="%s" ',variable_name{ivar});
      output = fprintf(fid,'vocabulary_name="%s" ',standard_name{ivar});
      output = fprintf(fid,          'units="%s" ',units{ivar}        );
      output = fprintf(fid,'>%s</variable>\n'     ,long_name{ivar}    );
      end
      output = fprintf(fid,'%s\n',['</variables>']);        

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

      output = sprintf(['<geospatialCoverage>'...
                        '\n<northsouth>%s'...
                        '</northsouth>'...
                        '\n<eastwest>%s'...
                        '</eastwest>'...
                        '\n<updown>%s'...
                        '</updown>'...
                        '</geospatialCoverage>\n'],...
          spatialRange_write('start',D.geospatialCoverage_northsouth_start(j),'stop',D.geospatialCoverage_northsouth_end(j),'units','degrees_north'),...
          spatialRange_write('start',D.geospatialCoverage_eastwest_start(j)  ,'stop',D.geospatialCoverage_eastwest_end(j)  ,'units','degrees_east'),...
          spatialRange_write('start',D.geospatialCoverage_updown_start(j)    ,'stop',D.geospatialCoverage_updown_end(j)    ,'units','m'));
      fprintf(fid,output);

% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage

      output = sprintf(['<timeCoverage><start>\n'...
                        '%s</start><end>\n'...
                        '%s</end>\n'...
                        '</timeCoverage>\n'],...
          datestrnan(D.timeCoverage_start(j),'yyyy-mm-ddTHH:MM:SS',' '),...
          datestrnan(D.timeCoverage_end(j)  ,'yyyy-mm-ddTHH:MM:SS',' '));
      fprintf(fid,output);
      
      output = fprintf(fid,'%s\n',['</dataset>']);
      
   end % i
      
output = fprintf(fid,'%s\n',['  </dataset>']);
output = fprintf(fid,'%s\n',['</catalog>']);
fclose(fid);
