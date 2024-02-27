function varargout = KML_text(lat,lon,label,varargin)
%KML_TEXT   low-level routine for creating KML string of text
%
%   kmlstring = KML_text(lat,lon,label,<z>)
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

% $Id: KML_text.m 3623 2010-12-10 14:07:59Z boer_g $
% $Date: 2010-12-10 22:07:59 +0800 (Fri, 10 Dec 2010) $
% $Author: boer_g $
% $Revision: 3623 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_text.m $
% $Keywords: $

% TO DO: implement text at an angle/rotation

%% keyword,value

   OPT.timeIn       = [];
   OPT.timeOut      = [];
   OPT.dateStrStyle = 29;
   OPT.visible      = 0;
   
   if nargin==0; varargout = {OPT}; return; end

%% Check if 3d
   if ~isempty(varargin)
       if isnumeric(varargin{1})
           z = varargin{1};
           varargin(1) = [];
           OPT.is3D = true;
       else
           z = zeros(size(lat));
           OPT.is3D = false;
       end
   else
       z = zeros(size(lat));
       OPT.is3D = false;
   end

   if ischar(label)
      label = cellstr(label);
   end

   if ~isequal(length(label),length(lat))
      error('label should have same length as coordinates')
   end

   OPT = setproperty(OPT,varargin{:});

%% preproces timespan

   timeSpan = KML_timespan('timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'dateStrStyle',OPT.dateStrStyle);

%% preprocess altitude mode

   if OPT.is3D
       altitudeMode = '<altitudeMode>absolute</altitudeMode>';
   else
       altitudeMode = ' ';  
   end
   
   for i=1:length(lat)
   
   output = sprintf([...
    '<Placemark>\n'...
    '%s'...                % timeSpan
    '<visibility>%d</visibility>\n'... % visible
    '<name>%s</name>\n'... % label
    '<Style><IconStyle><Icon></Icon></IconStyle></Style>\n'... % this gives no icon at all, whereas leaving this ...
    '<Point>'...                                               % ... line out gives the default yellow pushpin
    '%s'...                % altitude mode
    '<coordinates>%3.8f,%3.8f,%3.3f </coordinates></Point>\n'...
    '</Placemark>\n'],...
       timeSpan,OPT.visible,label{i},altitudeMode,lon(i),lat(i),z(i));
       
   end    
   
   varargout = {output};

%% EOF