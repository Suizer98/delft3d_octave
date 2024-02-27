function varargout = wcs(varargin)
%WCS construct and validate OGC WCS request from Web Coverage Service server
%
%  [url,OPT,lims] = wcs(<keyword,value>)
%  [url,OPT,lims] = wcs(OPT)
%
% where
% url  - is valid wcs getcoverage request constructed from user-keywords 
%        and (cached) getcapabilities request.
% lims - are the available options per keyword.
% OPT  - contains as input the user-keywords and as output valid
%        values for the keywords, as first valid value from getcapabilities
%        or interactive selection from UI pop-up with available options, or
%        simply returns validated values unaltered.
% OPT  - also contains the vectors x and y to be used
%        for georeferencing the WCS data with the requested bounding box.
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
% Example: SRTM
%
%   [url,OPT] = wcs('server','http://geoport.whoi.edu/thredds/wcs/bathy/srtm30plus_v6?');
%   urlwrite(url,['tmp',OPT.format]);
%
%See also: wms, wfs, arcgis, netcdf, opendap, postgresql, xml_read
%          http://publicwiki.deltares.nl/display/OET/WCS+primer
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

lim.service = 'WCS';
lim.version = {''}; % union of those offered by server and those implemented here

% standard
OPT.server          = 'http://www.dummy.yz';
OPT.version         = '1.0.0';
OPT.request         = 'GetCoverage';
OPT.coverage        = '';            % from getCapabilities, layers in WMS
OPT.axis            = [];            % check for bounds from getCapabilities
OPT.bbox            = '';            % check order for lat-lon vs. lon-lat
OPT.format          = 'netcdf3';     % not in getCapabilities, but in DescribeCoverage
OPT.crs             = 'EPSG%3A4326'; % http://viswaug.wordpress.com/2009/03/15/reversed-co-ordinate-axis-order-for-epsg4326-vs-crs84-when-requesting-wms-130-images/
OPT.resx            = [];            % not in getCapabilities, but in DescribeCoverage
OPT.resy            = [];            % not in getCapabilities, but in DescribeCoverage
OPT.interpolation   = '';            % not in getCapabilities, but in DescribeCoverage
OPT.time            = '';            % from getCapabilities

OPT.disp            = 1;             % write screen logs
OPT.cachedir        = [tempdir,'matlab.ows',filesep]; % store cache of xml (and later png)

OPT.fixqmark        = 1; % add ? to DescribeCoverage urls

%% non-standard

   if nargin==0
       varargout = {[OPT]};
       return
   end
   
   OPT = setproperty(OPT,varargin);

%% get_capabilities (rebuilt url)

   xml = wxs_url_cache(OPT.server,['service=',lim.service,'&version=',OPT.version,'&request=GetCapabilities'],OPT.cachedir);

%% check available version

   if strcmpi(xml.ATTRIBUTE.version,'1.0.0')
      OPT.version = '1.0.0';
   else
       error([lim.service,' not 1.0.0'])
   end

%% check valid layers and ...

if isempty(xml.ContentMetadata)
    warning('server has not any coverages to offer')
    url = '';
else
    
   L = xml.ContentMetadata.CoverageOfferingBrief;

   lim.coverage = {};
   for i=1:length(L)
         lim.coverage{end+1} = L(i).name;
   end

   [OPT.coverage] = wxs_keyword_match('a coverage',OPT.coverage,lim.coverage,OPT);
   
%% ... get layer index into getcapabilities list
   
   for ilayer=1:length(L)
      if strcmpi(OPT.coverage,L(ilayer).name)
         Layer = L(ilayer);
         Layer.index = [ilayer];
         continue
      end
   end   

%% check valid format: use server-optional DescribeCoverage

   lim.requests = fieldnames(xml.Capability.Request);
   if any(strmatch('DescribeCoverage',lim.requests))
       
      LL = xml.Capability.Request.DescribeCoverage.DCPType;
       
      for ii=1:length(LL)
          if isfield(LL(ii).HTTP,'Get') % exclude Post
             url2 = LL(ii).HTTP.Get.OnlineResource.ATTRIBUTE.href;
             if OPT.fixqmark
             if ~strcmp(url2(end),'?')
                 url2 = [url2 '?'];
             end
             end
             break
          end
      end
      
      % fix trailing ? for
      % http://thredds.jpl.nasa.gov/thredds/wcs/ncml_aggregation/Chlorophyll/seawifs/aggregate__SEAWIFS_L3_CHLA_MONTHLY_9KM_R.ncml?service=WCS&version=1.0.0&request=GetCapabilities
      
%% get_capabilities (rebuilt url)

      xml2 = wxs_url_cache(url2,['service=',lim.service,'&version=',OPT.version,'&request=DescribeCoverage&coverage=',OPT.coverage],OPT.cachedir);
      
      lim.format = xml2.CoverageOffering.supportedFormats.formats;
    
   else % guess
      warning('No DescribeCoverage, guessed file a format')
      OPT.format = 'GeoTIFF';
   end
   OPT
   [OPT.format] = wxs_keyword_match('a format',OPT.format,lim.format,OPT);
   
%% check crs

if isfield(xml2.CoverageOffering.supportedCRSs,'requestResponseCRSs')    
    lim.crs = xml2.CoverageOffering.supportedCRSs.requestResponseCRSs;
elseif isfield(xml2.CoverageOffering.supportedCRSs,'requestCRSs')    
    lim.crs = xml2.CoverageOffering.supportedCRSs.requestCRSs;
else
    xml2.CoverageOffering.supportedCRSs
    error('above WCS supportedCRSs not understood')
end
   [OPT.crs] = wxs_keyword_match('a crs',OPT.crs,lim.crs,OPT);
   
%% check interpolation (or use default)

   lim.interpolation = xml2.CoverageOffering.supportedInterpolations.interpolationMethod;
   [OPT.interpolation] = wxs_keyword_match('a interpolation',OPT.interpolation,lim.interpolation,OPT);
   
%% check valid axis and time (not yet bbox):

    if isempty(OPT.axis)
       LL = str2num(Layer.lonLatEnvelope.pos{1});
       UR = str2num(Layer.lonLatEnvelope.pos{2});
       OPT.axis(1) = LL(1);
       OPT.axis(2) = LL(2);
       OPT.axis(3) = UR(1);
       OPT.axis(4) = UR(2);
    end

    if isfield(xml2.CoverageOffering.domainSet.spatialDomain,'EnvelopeWithTimePeriod')
        envelope = 'EnvelopeWithTimePeriod';
        LL = str2num(xml2.CoverageOffering.domainSet.spatialDomain.(envelope).pos(1).CONTENT);
        UR = str2num(xml2.CoverageOffering.domainSet.spatialDomain.(envelope).pos(2).CONTENT);
        if isfield(xml2.CoverageOffering.domainSet.spatialDomain.(envelope),'timePosition')
        lim.time = xml2.CoverageOffering.domainSet.spatialDomain.(envelope).timePosition;
        
        if ~isempty(OPT.time)
            t0 = datenum(lim.time{1},'yyyy-mm-ddTHH:MM:SS');
            t1 = datenum(lim.time{2},'yyyy-mm-ddTHH:MM:SS');
            
            if ~isnumeric(OPT.time)
            t  = datenum(OPT.time   ,'yyyy-mm-ddTHH:MM:SS');
            else
            t  = OPT.time;
            end
            while t < t0 | t > t1
                dprintf(2,['wxs:not in valid range: ',datestr(t,'yyyy-mm-ddTHH:MM:SS'),' [',lim.time{1},'..',lim.time{2},']'])
                t = inputdlg(['time: ',lim.time{1},'..',lim.time{2}],'WCS time',1,lim.time);
                t = datenum(t,'yyyy-mm-ddTHH:MM:SS');
            end
            OPT.time = datestr(t,'yyyy-mm-ddTHH:MM:SS');
        end
        end
    else
        envelope = 'Envelope';
        LL = str2num(xml2.CoverageOffering.domainSet.spatialDomain.(envelope).pos{1});
        UR = str2num(xml2.CoverageOffering.domainSet.spatialDomain.(envelope).pos{2});
    end
   
   lim.axis = [LL(1) LL(2) UR(1) UR(2)];
   
%% check time   

%% check valid bbox: handle lon-lat vs. lat-lon:

   if     strcmpi(OPT.version,'1.0.0') % CRS:84
       % [min_lon,min_lat,max_lon,max_lat]
       % [minx   ,miny   ,maxx   ,maxy   ]
       OPT.bbox  = nums2str(OPT.axis,',');       
   end
   
%% check resolution

   dx = str2num(xml2.CoverageOffering.domainSet.spatialDomain.RectifiedGrid.offsetVector{1});
   dy = str2num(xml2.CoverageOffering.domainSet.spatialDomain.RectifiedGrid.offsetVector{2});
   
   % limits.GridEnvelope.low = '0 0';
   % limits.GridEnvelope.high = '37151 39999';
   % axisName = {'X' 'Y'};
   % origin.pos = '19242.5 506247.5';
   % offsetVector = {'5.0 0.0' '0.0 -5.0'};
   % ATTRIBUTE.dimension = '2';
   % ATTRIBUTE.srsName = 'EPSG:28992';

   lim.resx = dx(1);
   lim.resy = dy(2);

%% make center pixels

  OPT.x = OPT.axis(1):OPT.resy:OPT.axis(3);
  OPT.y = OPT.axis(4):-OPT.resy:OPT.axis(2); % images are generally upside down: pixel(1,1) is upper left corner

%% construct url: standard keywords
%  Note that the parameter names in all KVP encodings shall be handled
%  in a case insensitive manner while parameter values shall be handled in a case sensitive
%  manner. [csw 2.0.2 p 128]

   url = [OPT.server,'&service=',lim.service,...
   '&version='    ,         OPT.version,...
   '&request='    ,         OPT.request,...
   '&bbox='       ,         OPT.bbox,...
   '&coverage='   ,         OPT.coverage,...
   '&format='     ,         OPT.format,...
   '&resx='       ,         num2str(OPT.resx),...
   '&resy='       ,         num2str(OPT.resy),...
   '&crs='        ,         OPT.crs];

%% construct url: standard options or non-standard extensions

   if ~isempty(OPT.time)
      if ischar(OPT.time)
         url = [url, '&time=',OPT.time];
      else
         url = [url, '&time=',datestr(OPT.time,'YYYY-MM-DDTHH:MM:SS')];
      end
   end

end % any coverages 

   varargout = {url,OPT,lim};
   
function c = ensure_cell(c)

   if ischar(c);c = cellstr(c);end


