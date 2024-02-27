function varargout = KMLimage(lat,lon,im0,varargin)
%KMLimage just like image, writes OGC KML GroundOverlay of image, url, wms
%
%  KMLimage(lat,lon,im,<keyword,value>)
%
% where lat and lon are the bbox corners, and 
% im and keyword 'fileName' govern the image handling.
%
%  'fileName' | im    | image
%  -----------+-------+--------------
%   kml       | file  | linked
%   kml       | url   | linked
%   kmz       | file  | copied into kmz, source lineage remembered
%   kmz       | url   | copied into kmz, source lineage remembered
%  -----------+-------+--------------
%
% Example: WMS url or saved (WMS) image wrapped in kml
%
%   url = 'http://geoport.whoi.edu/thredds/wms/bathy/etopo2_v2c.nc?&service=wms&version=1.3.0&request=GetMap&bbox=-90,-180,90,180&layers=topo&format=image/png&CRS=EPSG%3A4326&width=800&height=600&transparent=true&styles=boxfill/ferret&colorscalerange=-4000,4000';
%
%   KMLimage([-90 90],[-180 180],url,'fileName','etopo2_v2c_wms.kml');
%   KMLimage([-90 90],[-180 180],url,'fileName','etopo2_v2c_wms.kmz');
%
%   url = 'c:\Users\me\AppData\Local\Temp\matlab.wms\geoport_whoi_edu_thredds_wms_bathy_etopo2_v2c_nc.png'; % local cache
%   KMLimage([-90 90],[-180 180],url,'fileName','etopo2_v2c_local_machine.kml')
%   KMLimage([-90 90],[-180 180],url,'fileName','etopo2_v2c_local_machine.kmz')
%
% For a list of keywords call: OPT = KMLimage
%
%   Keyword 'rotation' rotates the image (degrees in Cartesian convention)
%   Keyword 'timespan' sets the time in which the image is shown in Google
%                      Earth, this also adds a time axis in Google Earth.
%                      In format: [matlab_datenum_start matlab_datenum_end]
%                      Combine multiple KMLs for a time dependent animation
%
%See also: googleplot, image, wms, KMLfigure_tiler

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares.nl, gerben.deboer@deltares.nl
%                 2015 Deltares.nl, freek.scheel@deltares.nl

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

%%
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% process <keyword,value>

   OPT               = KML_header();

   OPT.fileName      = 'KMLimage.kml';
   OPT.description   = '';
   OPT.openInGE      = false;
   OPT.rotation      = 0;
   OPT.timespan      = [];
   OPT.altitude      = NaN;
   OPT.altitudeMode  = 'absolute'; % or 'relativeToGround'
   

   eol = char(10);
   
   if nargin==0
      varargout = {OPT};
      return
   end

   [OPT, Set, Default] = setproperty(OPT, varargin);

%% input check

   if any((abs(lat)/90)>1)
       error('latitude out of range, must be within -90..90')
   end
   % This is not an issue (even created issues), removed:
%    lon(lon > 0) = lon(lon > 0) - 1e-12;% handle issue with [-180 180]
%    lon(lon < 0) = lon(lon < 0) + 1e-12;
%    lon = mod(lon+360, 360);

%% get filename, gui for filename, if not set yet

   if ischar(OPT.fileName) && isempty(OPT.fileName); % can be char ('', default) or fid
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);

%% set kmlName if it is not set yet

      if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
      end
   end

%% start KML

   OPT.fid = fopen(OPT.fileName,'w');

   output = KML_header(OPT); % handles time etc.
   lineage = '';
   if strcmpi  ( OPT.fileName(end-2:end),'kmz') % include im in kkmz and make ref local
      lineage = ['<!-- source: ',im0,'-->'];       
      if isurl(im)
         im.url       = im0;
         im.kmllink   = 'temporary_image_name';
         im.cachename = [tempdir,filesep,im.kmllink];
         urlwrite(im.url,im.cachename);
      else
         im.cachename = im0;
         im.kmllink   = filenameext(im.cachename);
      end
   else
      if isurl(im0)
         im.url       = im0;
         im.kmllink   = strrep(im.url,'&','&amp;'); % Google Earth requires this for OGC WMS urls
      else
         im.kmllink   = im0;
      end
      im.cachename = '';
   end
   
   if ~isempty(OPT.timeIn) & ~isempty(OPT.timeOut)
       timestr = '<TimeSpan>';
       if ~isempty(OPT.timeIn)
           timestr = [timestr,'<begin>',datestr(OPT.timeIn ,OPT.dateStrStyle),'</begin>'];
       end
       if ~isempty(OPT.timeOut)
           timestr = [timestr,'<end>'  ,datestr(OPT.timeOut,OPT.dateStrStyle),'</end>'];
       end
       timestr = [timestr,'</TimeSpan>'];
   else
       timestr = '';
   end

   if ~isnan(OPT.altitude)
       altitudestring = ['<altitude>', num2str(OPT.altitude), '</altitude>', eol, ...  
                         '<altitudeMode>', num2str(OPT.altitudeMode), '</altitudeMode>', eol];
   else
       altitudestring = '';
   end

   
   output = [output eol ...
       '<GroundOverlay>' eol,...
       '<name>',OPT.kmlName,'</name>' eol ...
       altitudestring, ... 
       '<description>',OPT.description,'</description>' eol,...
       timestr,...
       '<Icon>' eol,...
       lineage eol,... % remember original url
       '<href>',im.kmllink,'</href>' eol,...
       '</Icon>' eol,...
       '<LatLonBox>' eol,...
       ' <north>',num2str(lat(2)),'</north>' eol,...
       ' <south>',num2str(lat(1)),'</south>' eol,...
       ' <east>', num2str(lon(2)),'</east>' eol,...
       ' <west>', num2str(lon(1)),'</west>' eol,...
       ' <rotation>', num2str(OPT.rotation),'</rotation>' eol,...
       '</LatLonBox>' eol,...
       '</GroundOverlay>'];
   
   if ~isempty(OPT.timespan)
       % Add timespan (Activates time slider in GE) if keyword timespan is specified 
       output = strrep(output,'</GroundOverlay>',['<TimeSpan>' eol '<begin>' datestr(OPT.timespan(1),OPT.dateStrStyle) '</begin>' eol '<end>' datestr(OPT.timespan(2),OPT.dateStrStyle) '</end>' eol '</TimeSpan>' eol '</GroundOverlay>']);
   end
   
   if OPT.fid > 0
      fprintf(OPT.fid,'%s',output);
   end

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,{[OPT.fileName(1:end-3) 'kml'],im.cachename});
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?

   if OPT.openInGE
       system([OPT.fileName ' &']);
   end

   varargout = {};

%% EOF