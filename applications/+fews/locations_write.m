function varargout = locations_write(lon,lat,varargin)
%LOCATIONS_WRITE writes locations to FEWS xml files
%
%   fews.locations_write(lon,lat,<keyword,value>)
%
% writes Locations.xml, locationSets.xml, and Id*.xml.
%
% For available <keyword,value> pairs call fews.locations_write():
%
% * internal_name - unique name inside FEWS ("id" in Locations.xml, "internal" in IdMapFiles)
% * external_name - unique external ID needed for Imports ("exinternal" in IdMapFiles)
% * display_name  - name to be displayed in FEWS GUI ("name" in Locations.xml) (optional)
%
% * locationSet_id   - ("id" in LocationSets.xml)
% * locationSet_name - ("name" in LocationSets.xml)
%
% * xml_Locations    - name of xml file (Config\RegionConfigFiles\*.xml)
% * xml_LocationSet  - name of xml file (Config\RegionConfigFiles\*.xml
% * xml_Id.name      - name of xml file (Config\IdMapFiles\*.xml)
%
% Example:
%
% fews.locations_write([3 4  3 4],[51 51  52 52],...
%     'internal_name'   ,{'LL','LR','UR','UL'},...
%     'display_name'    ,{'lower left','lower right','upper right','upper left'},...
%     'external_name'   ,{'SW','SE','NE','NW'},...
%     'locationSet_id'  ,'box',...
%     'locationSet_name','a box in NL',...
%     'xml_Id'          ,'Id.box.xml',...
%     'xml_Locations'   ,'Locations.box.xml',...
%     'xml_LocationSets','LocationSets.box.xml')
%
%See also: nc_cf_harvest, matroos, fews

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares for internal Eureka competition.
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
% $Id: locations_write.m 8389 2013-03-29 07:42:24Z boer_g $
% $Date: 2013-03-29 15:42:24 +0800 (Fri, 29 Mar 2013) $
% $Author: boer_g $
% $Revision: 8389 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+fews/locations_write.m $
% $Keywords$

OPT.ConfigRoot       = '';
OPT.xml_Locations    = 'Config\RegionConfigFiles\locations.new.xml';
OPT.xml_LocationSets = 'Config\RegionConfigFiles\locationSets.new.xml';
OPT.xml_Id           = 'Config\IdMapFiles\Id.new.xml';

OPT.locationSet_id   = '';
OPT.locationSet_name = '';

OPT.external_name    = ''; % xml: id=
OPT.internal_name    = ''; % xml: 
OPT.display_name     = ''; % xml: name=

OPT.timeIn           = ''; % for tooltip
OPT.timeOut          = ''; % for tooltip

OPT.eolhtml          = '';
OPT.eol              = char(10);

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

fname.Locations    = [OPT.ConfigRoot,OPT.xml_Locations];
fname.LocationSets = [OPT.ConfigRoot,OPT.xml_LocationSets];
fname.Id           = [OPT.ConfigRoot,OPT.xml_Id];


%% remove double IDs

   [~,uniqueId]=unique(OPT.internal_name,'stable');
   doubleId = [];
   if length(uniqueId) < length(OPT.internal_name)
       doubleId = setxor(uniqueId,1:length(OPT.internal_name));
       warning([num2str(length(doubleId)),' double occurences found and commented out:'])
       for j=1:length(doubleId)
           disp(['inactivated redundant location: ',num2str(j),':  ',OPT.internal_name{j},' (',num2str(doubleId(j)),')'])
       end
   end

%% Locations.xml

   fid     = fopen(fname.Locations,'w');
   output = repmat(char(1),1,1e5);
   newOutput = [xmlheader('locations',OPT.eol),OPT.eol,'<geoDatum>WGS 1984</geoDatum>',OPT.eol];
   kk = 1;output(kk:kk+length(newOutput)-1) = newOutput;
   kk = kk+length(newOutput);   
       
   for j=1:length(lon)

      if ~isempty(OPT.timeIn)
         html = fews.tooltiphtml('eol',OPT.eolhtml,'timeIn',OPT.timeIn(j),'timeOut',OPT.timeOut(j));
      else
         html = fews.tooltiphtml('eol',OPT.eolhtml);
      end
      
      if intersect(j,doubleId)
      newOutput = [...
      '	<!-- location id="',OPT.internal_name{j},'" name="',OPT.display_name{j},'">',OPT.eol,...
      '		<toolTip><![CDATA[',html,']]></toolTip>',OPT.eol,...
      '		<x>',num2str(lon(j)),'</x>',OPT.eol,...
      '		<y>',num2str(lat(j)),'</y>',OPT.eol,...
      '	</location-->',OPT.eol];          
      else
      newOutput = [...
      '	<location id="',OPT.internal_name{j},'" name="',OPT.display_name{j},'">',OPT.eol,...
      '		<toolTip><![CDATA[',html,']]></toolTip>',OPT.eol,...
      '		<x>',num2str(lon(j)),'</x>',OPT.eol,...
      '		<y>',num2str(lat(j)),'</y>',OPT.eol,...
      '	</location>',OPT.eol];
      end
      
       output(kk:kk+length(newOutput)-1) = newOutput;
       kk = kk+length(newOutput);
       
       % write output to file if output is full, and reset
       if kk>1e5
           fprintf(fid,'%c',output(1:kk-1));
           kk        = 1;
           output    = repmat(char(1),1,1e5);
       end
   
   end

   fprintf(fid,'%c',output(1:kk-1));
   fprintf(fid,'</locations>');

fclose(fid);

%% LocationSets.xml

   fid     = fopen(fname.LocationSets,'w');

   %NO%: xml-element are trailing-space-sensitive
   %NO% table = addrowcol(char(OPT.internal_name),0,-1,fliplr('<locationId>'));
   %NO% table = addrowcol(table              ,0,+1,     ['</locationId>',OPT.eol]);
   %NO% fprintf(fid,table');
   
   output = repmat(char(1),1,1e5);
   newOutput = [xmlheader('locationSets',OPT.eol),OPT.eol,char(9),'<locationSet id="',OPT.locationSet_id,'" name="',OPT.locationSet_name,'">',OPT.eol];
   kk = 1;output(kk:kk+length(newOutput)-1) = newOutput;
   kk = kk+length(newOutput);   
   
   for j=1:length(lon)
      if intersect(j,doubleId)       
      newOutput = [char(9),char(9),'<!--locationId>',OPT.internal_name{j},'</locationId-->',OPT.eol];
      else
      newOutput = [char(9),char(9),'<locationId>',OPT.internal_name{j},'</locationId>',OPT.eol];          
      end
      output(kk:kk+length(newOutput)-1) = newOutput;
      kk = kk+length(newOutput);
      % write output to file if output is full, and reset
      if kk>1e5
          fprintf(fid,'%c',output(1:kk-1));
          kk        = 1;
          output    = repmat(char(1),1,1e5);
      end
   end
   fprintf(fid,'%c',output(1:kk-1));

   fprintf(fid,[char(9),'</locationSet>',OPT.eol,'</locationSets>']);

   fclose(fid);
   
%% IdMap

   if ~isempty(OPT.external_name)
   fid     = fopen(fname.Id,'w'); % OPT.xml.Id,'Id',OPT.locationSet_id,'.xml']
   
   output = repmat(char(1),1,1e5);
   newOutput = [xmlheader('idMap',OPT.eol),OPT.eol,...
      '<!--PARAMETER-->',OPT.eol,...
      '<!--LOCATION-->',OPT.eol];
   kk = 1;output(kk:kk+length(newOutput)-1) = newOutput;
   kk = kk+length(newOutput);   
   
   for j=1:length(lon)
      if intersect(j,doubleId)          
      newOutput = [char(9),'<!--location external="',OPT.external_name{j},'"',char(9),'internal="',OPT.internal_name{j},'"/-->',OPT.eol];
      else
      newOutput = [char(9),'<location external="',OPT.external_name{j},'"',char(9),'internal="',OPT.internal_name{j},'"/>',OPT.eol];
      end
      output(kk:kk+length(newOutput)-1) = newOutput;
      kk = kk+length(newOutput);
      % write output to file if output is full, and reset
      if kk>1e5
          fprintf(fid,'%c',output(1:kk-1));
          kk        = 1;
          output    = repmat(char(1),1,1e5);
      end
   end
   fprintf(fid,'%c',output(1:kk-1));

   %NO%: xml-element are trailing-space-sensitive   
   %NO% fprintf(fid,[xmlheader('idMap',OPT.eol),OPT.eol]);
   %NO% table = addrowcol(char(OPT.external_name),0,-1,fliplr('<location external="'));    
   %NO% table = addrowcol(table              ,0,+1,      ['" internal="']); 
   %NO% table = [table char(OPT.internal_name)];
   %NO% table = addrowcol(table              ,0,+1,      ['"/> ',OPT.eol]);
   %NO% fprintf(fid,table');
   
   fprintf(fid,['</idMap>',OPT.eol]);   
   fclose(fid);       
   end
      
function newOutput = xmlheader(type,eol)

   newOutput = [...
      '<?xml version="1.0" encoding="UTF-8"?>',eol,...
      '<!-- created with OpenEarthTools $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+fews/locations_write.m $ $Id: locations_write.m 8389 2013-03-29 07:42:24Z boer_g $-->',eol,...
      '<',type,'',eol,...
      ' xmlns',char(9),char(9),char(9),'="http://www.wldelft.nl/fews" ',eol,...
      ' xmlns:xsi',char(9),char(9),'="http://www.w3.org/2001/XMLSchema-instance"',eol,...
      ' xsi:schemaLocation',char(9),'="http://www.wldelft.nl/fews http://fews.wldelft.nl/schemas/version1.0/',type,'.xsd"',eol,...
      ' version',char(9),char(9),'="1.1"',' >'];

