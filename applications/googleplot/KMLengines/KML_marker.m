function varargout = KML_marker(lat,lon,varargin)
%KML_MARKER     low-level routine for creating KML string of marker
%
%   kmlstring = KML_marker(lat,lon,<keyword,value>)
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_style, 
% KML_stylePoly, KML_upload

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

% $Id: KML_marker.m 10077 2014-01-28 10:32:05Z stengs $
% $Date: 2014-01-28 18:32:05 +0800 (Tue, 28 Jan 2014) $
% $Author: stengs $
% $Revision: 10077 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_marker.m $
% $Keywords: $

%% keyword,value

   OPT = KML_header;

   if nargin==0; varargout = {OPT}; return; end
   
   OPT = setproperty(OPT,varargin{:});

%% preproces timespan

   timeSpan = KML_timespan('timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'dateStrStyle',OPT.dateStrStyle);

   if ~isempty(OPT.icon)
      if ~isempty(OPT.scale)
         OPT.icon = sprintf('<Style><IconStyle><Icon>%s</Icon><scale>%3.2f</scale></IconStyle></Style>',OPT.icon,OPT.scale);
      else
         OPT.icon  = sprintf('<Style><IconStyle><Icon>%s</Icon></IconStyle></Style>',OPT.icon);
      end
   end

   
%% 
output = sprintf([...
 '<Placemark>'...
 '%s'...                                                   % timeSpan
 '<name>%s</name>'...                                      % name
 '<description>%s</description>'...                        % description
 '%s'...% icon
 '<Point><coordinates>%3.8f,%3.8f,0</coordinates></Point>'...
 '</Placemark>\n'],...
 timeSpan,OPT.kmlName,['<![CDATA[',OPT.description,']]>'],OPT.icon,lon,lat);
 
 varargout = {output};

%% EOF