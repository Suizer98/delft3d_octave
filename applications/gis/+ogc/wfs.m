function varargout = wfs(varargin)
%WFS construct and validate OGC WFS request from Web Feature Service server
%
%  [url,OPT,lims] = wfs(<keyword,value>)
%  [url,OPT,lims] = wfs(OPT)
%
% where
% url  - is valid wfs getcoverage request constructed from user-keywords 
%        and (cached) getcapabilities request.
% lims - are the available options per keyword.
% OPT  - contains as input the user-keywords and as output valid
%        values for the keywords, as first valid value from getcapabilities
%        or interactive selection from UI pop-up with available options, or
%        simply returns validated values unaltered.
%
% Keywords layers, format and style can be 
% 1  - get 1st value from list, to prevent all user interaction
% n  - or other integer, get nth value from list
% '' - show drop-down menu with all options
% 
% Keyword axis can be [] to get overall axis from server 
% [minlon minlat maxlon maxlat]. Note that numeric array OPT.axis 
% can have lat/lon swapped with respect to character array OPT.bbox
%
% Example: VLIZ.be
%
%   [url,OPT] = wfs('server','geo.vliz.be/geoserver/wfs?');
%   urlwrite(url,['tmp',OPT.ext]);
%
%See also: wcs, wms, postgresql, xml_read
%          http://publicwiki.deltares.nl/display/OET/WFS+primer
%          https://pypi.python.org/pypi/OWSLib

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares - gerben.deboer@deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

% http://geoport.whoi.edu/thredds/wcs/bathy/srtm30plus_v6?request=GetCoverage&version=1.0.0&service=WCS&format=netcdf3&coverage=topo&BBOX=0,50,10,55

import ogc.*

lim.service = 'WFS';
lim.version = {''}; % union of those offered by server and those implemented here

% standard
OPT.server          = 'http://www.dummy.yz';
OPT.version         = '1.1.0';
OPT.request         = 'GetFeature';
OPT.typename        = '';            % from getCapabilities, layers in WFS
OPT.axis            = [];            % check for bounds from getCapabilities
OPT.bbox            = '';            % check order for lat-lon vs. lon-lat
OPT.format          = 'json';        % in getCapabilities
OPT.crs             = 'EPSG%3A4326'; % http://viswaug.wordpress.com/2009/03/15/reversed-co-ordinate-axis-order-for-epsg4326-vs-crs84-when-requesting-wms-130-images/

OPT.disp            = 1;             % write screen logs
OPT.cachedir        = [tempdir,'matlab.ows',filesep]; % store cache of xml (and later png)

%% non-standard

   if nargin==0
       varargout = {[OPT]};
       return
   end
   
   OPT = setproperty(OPT,varargin);

%% get_capabilities (rebuilt url)

   xml = wxs_url_cache(OPT.server,['service=',lim.service,'&version=',OPT.version,'&request=GetCapabilities'],OPT.cachedir);

%% check available version

   if strcmpi(xml.ATTRIBUTE.version,'1.1.0')
      OPT.version = '1.1.0';
   else
       error([lim.service,' not 1.1.0'])
   end

%% check valid layers and ...

   L = xml.FeatureTypeList.FeatureType;

   lim.typename = {};
   for i=1:length(L)
         lim.typename{end+1} = L(i).Name;
   end

   [OPT.typename] = wxs_keyword_match('a coverage',OPT.typename,lim.typename,OPT);
   
%% ... get layer index into getcapabilities list
   
   for ilayer=1:length(L)
      if strcmpi(OPT.typename,L(ilayer).Name)
         Layer = L(ilayer);
         Layer.index = [ilayer];
         continue
      end
   end   

%% check valid format: use server-optional DescribeCoverage

   for ii=1:length(xml.OperationsMetadata.Operation)
      if strcmpi(xml.OperationsMetadata.Operation(ii).ATTRIBUTE.name,'GetFeature')
          break
      end
   end
   
   lim.format = xml.OperationsMetadata.Operation(ii).Parameter(2).Value;   
 
   [OPT.format] = wxs_keyword_match('a format',OPT.format,lim.format,OPT);
   
%% check crs

   
%% check interpolation

   
%% check valid axis (not yet bbox):

   if isempty(OPT.axis)
       LL = str2num(Layer.WGS84BoundingBox.LowerCorner);
       UR = str2num(Layer.WGS84BoundingBox.UpperCorner);
       OPT.axis(1) = LL(1);
       OPT.axis(2) = LL(2);
       OPT.axis(3) = UR(3);
       OPT.axis(4) = UR(4); % swap for http://geo.vliz.be/geoserver/wfs?
   end

%% check valid bbox: handle lon-lat vs. lat-lon:

   if     strcmpi(OPT.version,'1.1.0') & strcmpi(strrep(OPT.crs,':','%3A'),'EPSG%3A4326')
       % [min_lat,min_lon,max_lat,max_lon]  % reversed
       OPT.bbox  = nums2str(OPT.axis([2,1,4,3]),',');
       dprintf(2,'crs=CRS:84 to be used instead of crs=EPSG:4326 to prevent mixing-up lat-lon in THREDDS')
   end      

%% construct url: standard keywords
%  Note that the parameter names in all KVP encodings shall be handled
%  in a case insensitive manner while parameter values shall be handled in a case sensitive
%  manner. [csw 2.0.2 p 128]

   url = [OPT.server,'&service=',lim.service,...
   '&version='    ,         OPT.version,...
   '&request='    ,         OPT.request,...
   '&bbox='       ,         OPT.bbox,...
   '&typename='   ,         OPT.typename,...
   '&format='     ,         OPT.format,...
   '&crs='        ,         OPT.crs];

   varargout = {url,OPT,lim};
   
function c = ensure_cell(c)

   if ischar(c);c = cellstr(c);end


