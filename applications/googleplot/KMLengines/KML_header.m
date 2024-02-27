function varargout = KML_header(varargin)
%KML_HEADER  low-level routine for creating KML string of header
%
%   kml = KML_header(<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * kmlName      name that appears in Google Earth Places list (default 'ans.kml')
%   * snippet      name that appears in Google Earth Places list (default 'ans.kml')
%   * description  text balloon that appears when clicking the snippet/name
%   * open         whether to open kml file in GoogleEarth in call of KMLline (default 0)
%   * visible      whether by default visible outside GE list item menu
% 
%   * cameralon    specify camera viewpoint
%   * cameralat    specify camera viewpoint
%   * cameraz      specify camera viewpoint
%
%   * timeIn       specify start of timespan of timeslider (datenum or 'yyyy-mm-ddTHH:MM:SS')
%   * timeOut      specify stop of  timespan of timeslider (datenum or 'yyyy-mm-ddTHH:MM:SS')
%   * dateStrStyle how to write time string into kml: dtermines accuracy (default 29)
%
% See also: KML_footer, KML_line, KML_poly, KML_style, KML_stylePoly,
% KML_text, KML_upload

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
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

% $Id: KML_header.m 10138 2014-02-05 13:23:46Z boer_g $
% $Date: 2014-02-05 21:23:46 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10138 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_header.m $
% $Keywords: $

%% Properties

   OPT.open         = [];
   OPT.kmlName      = '';
   OPT.snippet      = '';
   OPT.description  = '';
   OPT.visible      = true;
   OPT.icon         = '';
   OPT.scale        = [];

   OPT.cameralon    = [];
   OPT.cameralat    = [];
   OPT.cameraz      = [];
   
   OPT.timeIn       = [];
   OPT.timeOut      = [];
   OPT.dateStrStyle = 'yyyy-mm-ddTHH:MM:SSZ';
   
   OPT.LookAtLon      = []; % <longitude>3.2</longitude>                       <!-- kml:angle180 --> 
   OPT.LookAtLat      = []; % <latitude>52.3</latitude>                         <!-- kml:angle90 --> 
   OPT.LookAtAltitude = []; % <altitude></altitude>                        <!-- double -->    
   OPT.LookAtrange    = []; % <range>2e5</range>                               <!-- double -->   
   OPT.LookAttile     = []; % <tilt>70</tilt>                                <!-- float -->   
   OPT.LookAtheading  = []; % <heading>25</heading>                          <!-- float -->   
   
   if nargin==0; varargout = {OPT}; return; end

   if isstruct(varargin{1})
      OPT = mergestructs('overwrite',OPT,varargin{1}); % varargin struct can have field that are not in OPT
   else
      OPT = setproperty(OPT,varargin{:}); % varargin struct can NOT have any field that is not in OPT
   end

%% preproces timespan

   timeSpan = KML_timespan('timeIn',min(OPT.timeIn),'timeOut',min(OPT.timeOut),'dateStrStyle',OPT.dateStrStyle);
   
%% camera

   if ~(isempty(OPT.cameralon) || isempty(OPT.cameralat) || isempty(OPT.cameraz))
      camera = sprintf([...
      '<Camera>\n'...
      '	<longitude>%g</longitude>\n'...
      '	<latitude>%g</latitude>\n'...
      '	<altitude>%g</altitude>\n'...
      '%s\n'...
      '</Camera>\n'],OPT.cameralon,OPT.cameralat,OPT.cameraz,timeSpan); % timespan only works when also coordinates are supplied
   else
      % timespan only works when also coordinates are supplied
      camera = '';
   end
   
%% lookat
    gxTimeSpan = timeSpan;
    gxTimeSpan = strrep(gxTimeSpan,'<T','<gx:T');
    gxTimeSpan = strrep(gxTimeSpan,'</T','</gx:T');
   if ~(isempty(OPT.LookAtLon))
      LookAt = sprintf([...
      '<LookAt>\n'...
      '  <longitude>%g</longitude>\n'...
      '  <latitude>%g</latitude>\n'...
      '  <altitude>%g</altitude>\n'...
      '  <range>%g</range>\n'...
      '  <tilt>%g</tilt>\n'...
      '  <heading>%g</heading>\n'...
      '  %s\n'...
      '</LookAt>\n'],...
      OPT.LookAtLon,OPT.LookAtLat,OPT.LookAtAltitude,OPT.LookAtrange,OPT.LookAttile,OPT.LookAtheading,gxTimeSpan);
   else
      LookAt = '';
   end
   

%% type HEADER

   if ~isempty(OPT.description)
   OPT.description = ['<![CDATA[', str2line(cellstr(OPT.description),'s','') ']]>'];
   end

   output = sprintf([...
    '<?xml version="1.0" encoding="UTF-8"?>\n'...
    '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n'...
    '<!-- Created with Matlab (R) googlePlot toolbox $Revision: 10138 $ $Date: 2014-02-05 21:23:46 +0800 (Wed, 05 Feb 2014) $ from OpenEarthTools http://www.OpenEarth.eu-->\n',...
    '<Document>\n'...
    '%s%s'...
    '<name>%s</name>\n'...
    '<snippet>%s</snippet>\n'...
    '<description>%s</description>\n'...
    '<visibility>%s</visibility>\n'...
    '<open>%d</open>\n' ],...
    camera,LookAt,OPT.kmlName,OPT.snippet,OPT.description,num2str(OPT.visible),OPT.open);

   varargout = {output};