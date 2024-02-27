function varargout = wms(varargin)
%WMS construct and validate OGC WMS request from Web Mapping Service server
%
%  [url,OPT,lims] = wms(<keyword,value>)
%  [url,OPT,lims] = wms(OPT)
%
% where
% url  - is valid wms getmap request constructed from user-keywords 
%        and (cached) getcapabilities request.
% lims - are the available options per keyword.
% OPT  - contains as input the user-keywords and as output valid
%        values for the keywords, as first valid value from getcapabilities
%        or interactive selection from UI pop-up with available options, or
%        simply returns validated values unaltered.
% OPT  - also contains the vectors x and y to be used
%        for georeferencing the WMS image with the requested bounding box.
%
% Keywords layers, format and style can be 
% 1  - get 1st value from list, to prevent all user interaction
% n  - or other integer, get nth value from list
% '' - show drop-down menu with all options
% 
% Keyword axis can be [] to get overall axis from server 
% [minlon minlat maxlon maxlat]. Note that numeric array OPT.axis 
% can have lat/lon swapped with respect to character array OPT.bbox
% due to change betwen WMS 1.1.1 and 1.3.0. NOTE: some WMS servers 
% erroneously still swap [lat,lon] in the bbox @ version 1.3.0 & 
% crs=epsg:4326, notably Unidata THREDDS ncWMS.
%
% Keyword/dimensions 'time' and 'elevation' can be a 
% character - checked for validity against the possible range
%             as indicated in the getcababilities xml (e.g. '0.1' or '2004-12-05'
% 'default' - gets the default from the getcababilities, if any
% empty     - a case a selection menu is thrown.
% numeric   - values are turned to char, and then checked for possible range
%             as indicated in the getcababilities xml. Note that the ascii
%             representation is compared, which is often off due to format
%             precision digits.
%
% Example: World DEM
%
%   [url,OPT] = ogc.wms('server','http://geoport.whoi.edu/thredds/wms/bathy/smith_sandwell_v11?','colorscalerange',[-2e3 2e3]);
%   urlwrite(url,['tmp',OPT.ext]);
%   [A,map,alpha] = imread(['tmp',OPT.ext]);
%  %[A,map,OPT] = imread(url); or read direct from www, but better keep local cache
%   image(OPT.x,OPT.y,A)
%   colormap(map)
%   tickmap('ll');grid on;axislat
%   set(gca,'ydir','normal')
%
%See also: wcs, wfs, WMS_IMAGE_PLOT, arcgis, netcdf, opendap, postgresql, xml_read
%          KMLimage (wrap WMS in KML)
%          http://publicwiki.deltares.nl/display/OET/WMS+primer
%          https://pypi.python.org/pypi/OWSLib
%          http://nbviewer.ipython.org/urls/raw.github.com/Unidata/tds-python-workshop/master/wms_sample.ipynb
%          http://disc.sci.gsfc.nasa.gov/services/ogc_wms

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares - gerben.deboer@deltares.nl
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

% http://geoport.whoi.edu/thredds/wms/bathy...';

import ogc.*

lim.service = 'WMS';
lim.version = {''}; % union of those offered by server and those implemented here

% standard
OPT.server          = 'http://www.dummy.yz';
OPT.version         = '1.3.0';       % or 1.1.1
OPT.request         = 'GetMap';
OPT.layers          = '';            % from getCapabilities, coverage in WCS
OPT.axis            = [];            % check for bounds from getCapabilities
OPT.bbox            = '';            % check order for lat-lon vs. lon-lat
OPT.format          = 'image/png';   % default; from getCapabilities
OPT.crs             = 'EPSG%3A4326'; % http://viswaug.wordpress.com/2009/03/15/reversed-co-ordinate-axis-order-for-epsg4326-vs-crs84-when-requesting-wms-130-images/
OPT.width           = 800;           % default, check for max from getCapabilities
OPT.height          = 600;           % default, check for max from getCapabilities
OPT.styles          = '';            % from getCapabilities
OPT.transparent     = 'true';        % needs format image/png, note char format, as num2str(true)=1 and not 'true'
OPT.time            = '';            % from getCapabilities
OPT.elevation       = '';            % from getCapabilities

OPT.disp            = 0;             % write screen logs
OPT.cachedir        = [tempdir,'matlab.ows',filesep]; % store cache of xml (and later png)

%% non-standard

   OPT.colorscalerange = [];
   
   if nargin==0
       varargout = {[OPT]};
       return
   end
   
   OPT = setproperty(OPT,varargin);

%% get_capabilities

   xml = ogc.wxs_url_cache(OPT.server,['service=',lim.service,'&version=',OPT.version,'&request=GetCapabilities'],OPT.cachedir);

%% check available version

   if strcmpi(xml.ATTRIBUTE.version,'1.3.0')
      OPT.version = '1.3.0';
   elseif strcmpi(xml.ATTRIBUTE.version,'1.1.1')
      OPT.version = '1.1.1';
   else
       error([lim.service,' not 1.1.1 or 1.3.0'])
   end

%% check valid layers and ...

   lim.layers = {};
   for i=1:length(xml.Capability.Layer.Layer)
      if isfield(xml.Capability.Layer.Layer(i),'Layer')
         for j=1:length(xml.Capability.Layer.Layer(i).Layer)
         lim.layers{end+1} = xml.Capability.Layer.Layer(i).Layer(j).Name;
         end
      else
         lim.layers{end+1} = xml.Capability.Layer.Layer(i).Name;
      end
   end

   [OPT.layers] = wxs_keyword_match('a layer',OPT.layers,lim.layers,OPT);

%% ... get layer index into getcapabilities list

   for ilayer=1:length(xml.Capability.Layer.Layer)
      if isfield(xml.Capability.Layer.Layer(i),'Layer')       
         for jlayer=1:length(xml.Capability.Layer.Layer(ilayer).Layer)
            if strcmpi(OPT.layers,xml.Capability.Layer.Layer(ilayer).Layer(jlayer).Name)
               Layer = xml.Capability.Layer.Layer(ilayer).Layer(jlayer);
               Layer.index = [ilayer,jlayer];
               continue
            end
         end
      else
         if strcmpi(OPT.layers,xml.Capability.Layer.Layer(ilayer).Name)
            %Layer = xml.Capability.Layer.Layer(ilayer);
            %copy properties from parent
            Layer = mergestructs('overwrite',xml.Capability.Layer,xml.Capability.Layer.Layer(ilayer))
            Layer.index = [ilayer];
            continue
         end
      end
   end

%% check valid format

   lim.format = xml.Capability.Request.GetMap.Format;
   OPT.format = wxs_keyword_match('a format',OPT.format,lim.format,OPT);
   i = strfind(OPT.format,'/');OPT.ext = ['.',OPT.format(i+1:end)];

%% check valid crs: handle symbol ":" inside
%  server + layer crs
%  DO NOT USE urlencode, as it will double-encode the % from an already encoded url

   if     isfield(xml.Capability.Layer,'CRS')
      OPT.crsname = 'CRS';
   elseif isfield(xml.Capability.Layer,'SRS')
      OPT.crsname = 'SRS';
   end

   crs0 = cellfun(@(x)strrep(x,':','%3A'),ensure_cell(xml.Capability.Layer.(OPT.crsname)),'UniformOutput',0);
   if isfield(Layer,OPT.crsname)
   crs1 = cellfun(@(x)strrep(x,':','%3A'),ensure_cell(               Layer.(OPT.crsname)),'UniformOutput',0);
   else
   crs1 = {};
   end
   lim.crs = {crs0{:},crs1{:}};
   
   OPT.crs = wxs_keyword_match('a crs',strrep(OPT.crs,':','%3A'),lim.crs,OPT);
   
%% check valid axis (not yet bbox):

   if isempty(OPT.axis)
       if isfield(Layer,'EX_GeographicBoundingBox') & strcmpi(OPT.version,'1.3.0') % 1.3.0
          %disp([OPT.version,' ', OPT.crs,' ','EX_GeographicBoundingBox']);
           OPT.axis(1) = str2num(Layer.EX_GeographicBoundingBox.westBoundLongitude);
           OPT.axis(2) = str2num(Layer.EX_GeographicBoundingBox.southBoundLatitude);
           OPT.axis(3) = str2num(Layer.EX_GeographicBoundingBox.eastBoundLongitude);
           OPT.axis(4) = str2num(Layer.EX_GeographicBoundingBox.northBoundLatitude);
       elseif isfield(Layer,'LatLonBoundingBox') & strcmpi(OPT.version,'1.1.1') % 1.1.1
          %disp([OPT.version,' ', OPT.crs,' ','LatLonBoundingBox']);
           OPT.axis(1) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.minx);
           OPT.axis(2) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.miny);
           OPT.axis(3) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.maxx);
           OPT.axis(4) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.maxy);
       elseif isfield(Layer,'BoundingBox')
          %disp([OPT.version,' ', OPT.crs,' ','BoundingBox']);
         for ibox=1:length(Layer.BoundingBox)
           if strcmpi(Layer.BoundingBox(ibox).ATTRIBUTE.(OPT.crsname),'EPSG:4326')
               OPT.axis(1) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.minx); % x0
               OPT.axis(2) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.miny); % y0
               OPT.axis(3) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxx); % x1
               OPT.axis(4) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxy); % y1
           elseif strcmpi(Layer.BoundingBox(ibox).ATTRIBUTE.(OPT.crsname),'CRS:84')
               OPT.axis(1) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.minx); % x0
               OPT.axis(2) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.miny); % y0
               OPT.axis(3) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxx); % x1
               OPT.axis(4) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxy); % y1
           end % if        
         end % for
       end
   end

%% check valid bbox (handle lon-lat vs. lat-lon:
% http://viswaug.wordpress.com/2009/03/15/reversed-co-ordinate-axis-order-for-epsg4326-vs-crs84-when-requesting-wms-130-images/
% http://www.resc.rdg.ac.uk/trac/ncWMS/wiki/FrequentlyAskedQuestions#MyWMSclientuseslatitude-longitudeaxisorder
%
% Spec for 1.3.0:
% SRS=CRS:84&BBOX=min_lon,min_lat,max_lon,max_lat
% or
% SRS=EPSG:4326&=min_lat,min_lon,max_lat,max_lon <<<<<<<<<<<<<<<< THREDDS ncWMS DOES NOT DO THIS
% Spec for 1.1.1:
% SRS=EPSG:4326&BBOX=min_lon,min_lat,max_lon,max_lat 

% THREDDS DOES NOT OBEY THIS FOR 4326 !!!

   if     strcmpi(OPT.version,'1.3.0') & strcmpi(strrep(OPT.crs,':','%3A'),'EPSG%3A4326')
       % [min_lat,min_lon,max_lat,max_lon]  % reversed
       OPT.bbox  = nums2str(OPT.axis([2,1,4,3]),',');
       dprintf(2,'crs=CRS:84 to be used instead of crs=EPSG:4326 to prevent mixing-up lat-lon in THREDDS')
   else
       % [min_lon,min_lat,max_lon,max_lat]
       % [minx   ,miny   ,maxx   ,maxy   ]
       OPT.bbox  = nums2str(OPT.axis,',');       
   end   

%% check valid width, height

   if isfield(xml.Service,'MaxWidth'); OPT.width  = min(OPT.width ,str2num(xml.Service.MaxWidth ));end
   if isfield(xml.Service,'MaxHeight');OPT.height = min(OPT.height,str2num(xml.Service.MaxHeight));end

%% server + layer styles

   styles0 = {};styles1 = {};
   if isfield(xml.Capability.Layer,'Style');styles0 = {xml.Capability.Layer.Style.Name};end
   if isfield(               Layer,'Style');styles1 = {               Layer.Style.Name};end
   lim.styles = {styles0{:},styles1{:}};   
   OPT.styles = wxs_keyword_match('a style',OPT.styles,lim.styles,OPT);
   
%% optional dimensions: time + elevation + dedicated
%   current = 'true';
%   default = '2013-11-02T12:00:00.000Z';
%   multipleValues = 'true';

   if isfield(Layer,'Dimension')
     for idim=1:length(Layer.Dimension)
       if     strcmpi(Layer.Dimension(idim).ATTRIBUTE.name,'elevation')
          
         lim.elevation = wms_dim_series(Layer.Dimension(idim).CONTENT);
         
         if isfield(Layer.Dimension(idim).ATTRIBUTE,'default')
          default = Layer.Dimension(idim).ATTRIBUTE.default;
         else
          default = '';
         end
         
         if strcmpi(OPT.elevation,'default') & ~isempty(default)
            OPT.elevation = default;
         else
             if isnumeric(OPT.elevation)
                 OPT.elevation = num2str(OPT.elevation);
                 % perhaps better swap: turn lim.elevation into numeric and then compare               
             end
            [OPT.elevation] = wxs_keyword_match(['an elevation (default: ',default,')'],OPT.elevation,lim.elevation,OPT);         
         end
         ind = strfind([OPT.elevation],'/');
         if any(ind)
             [z0,z1,dz] = wms_dim_range(OPT.elevation);
             set = num2str([str2num(z0):str2num(dz):str2num(tz)]');
             [i, ok] = listdlg('ListString', set, .....
                            'SelectionMode', 'single', ...
                             'PromptString',['Select an elevation (default: ',default,'):'], ....
                                     'Name',OPT.server,...
                                 'ListSize', [500, 300]);    
             OPT.elevation = set(i,:);            
         end
         
       elseif strcmpi(Layer.Dimension(idim).ATTRIBUTE.name,'time')
          
         lim.time = wms_dim_series(Layer.Dimension(idim).CONTENT);
         if isempty(lim.time{1})
             if isfield(Layer,'Extent')
                 lim.time = wms_dim_series(Layer.Extent.CONTENT);
                 if isfield(Layer.Extent.ATTRIBUTE,'default')
                    Layer.Dimension(idim).ATTRIBUTE.default = Layer.Extent.ATTRIBUTE.default;
                 end
             end
         end
         
         if isfield(Layer.Dimension(idim).ATTRIBUTE,'default')
          default = Layer.Dimension(idim).ATTRIBUTE.default;
         else
          default = '';
         end
         
         if strcmpi(OPT.time,'default') & ~isempty(default)
            OPT.time = default;
         else
             if isnumeric(OPT.time)
                OPT.time = datestr(OPT.time,'yyyy-mm-ddTHH:MM:SS.FFFZ');
                % perhaps better swap: turn lim.time into numeric and then compare    
             end
            [OPT.time] = wxs_keyword_match(['a time (default: ',default,')'],OPT.time,lim.time,OPT);
         end
         ind = strfind([OPT.time],'/');
         if any(ind)
             [t0,t1,dt] = wms_dim_range(OPT.time);
             [Y,MO,D,H,MI,S,zone] = iso2datenum(dt);
             dt =  datenum(Y,MO,D,H,MI,S);
             [t1,zone0] = iso2datenum(t1);
             [t0,zone1] = iso2datenum(t0);

             set = datestr(t0:dt:t1,['yyyy-mm-ddTHH:MM:SS',zone0]);
             [i, ok] = listdlg('ListString', set, .....
                            'SelectionMode', 'single', ...
                             'PromptString',['Select a time(default: ',default,'):'], ....
                                     'Name',OPT.server,...
                                 'ListSize', [500, 300]);    
             OPT.time = set(i,:);            
         end

       else
         dprintf([2,'dedicated server-defined dimensions not yet implemented:',Layer.Dimension(idim).ATTRIBUTE.name])
       end % WMS name
     end % idim
   
   end

%% make center pixels

  OPT.x = linspace(OPT.axis(1),OPT.axis(3),OPT.width);
  OPT.y = linspace(OPT.axis(4),OPT.axis(2),OPT.height); % images are generally upside down: pixel(1,1) is upper left corner

%% construct url: standard keywords
%  Note that the parameter names in all KVP encodings shall be handled
%  in a case insensitive manner while parameter values shall be handled in a case sensitive
%  manner. [csw 2.0.2 p 128]

   url = [OPT.server,'&service=',lim.service,...
   '&version='    ,         OPT.version,...
   '&request='    ,         OPT.request,...
   '&bbox='       ,         OPT.bbox,...
   '&layers='     ,         OPT.layers,...
   '&format='     ,         OPT.format,...
   '&',OPT.crsname,'=',         OPT.crs,... % some require crs, KNMI: srs
   '&width='      , num2str(OPT.width),...
   '&height='     , num2str(OPT.height),...
   '&transparent=',         OPT.transparent,...
   '&styles='     , OPT.styles];

%% construct url: standard options or non-standard extensions

   if ~isempty(OPT.colorscalerange)
   url = [url, '&colorscalerange=',num2str(OPT.colorscalerange(1)),',',num2str(OPT.colorscalerange(2))];
   end

   if ~isempty(OPT.time)
      if ischar(OPT.time)
         url = [url, '&time=',OPT.time];
      else
         url = [url, '&time=',datestr(OPT.time,'YYYY-MM-DDTHH:MM:SS')];
      end
   end

   if ~isempty(OPT.elevation)
      if ischar(OPT.elevation)
         url = [url, '&elevation=',OPT.elevation];
      else
         url = [url, '&elevation=',num2str(elevation)];
      end
   end   
   
   varargout = {url,OPT,lim};
   
function c = ensure_cell(c)

   if ischar(c);c = cellstr(c);end

