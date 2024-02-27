function varargout = KML_style(varargin)
%KML_STYLE low-level routine for creating KML string of line style
%
%   kmlstring = KML_style(<keyword,value>)
%
% where the following <keyword,value> pairs have been implemented:
%
%   * name        name of style (default '')
%   * lineColor   color of the lines in RGB (0..1) values, default white ([0 0 0])
%   * lineAlpha   transparency of the line, (0..1) with 0 transparent
%   * lineWidth   line width, can be a fraction (default 1)
%
% See also: KML_footer, KML_header, KML_line, KML_poly, KML_stylePoly,
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

% $Id: KML_style.m 5725 2012-01-19 05:04:28Z boer_g $
% $Date: 2012-01-19 13:04:28 +0800 (Thu, 19 Jan 2012) $
% $Author: boer_g $
% $Revision: 5725 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_style.m $
% $Keywords: $

%% Properties

OPT.name       = 'black';
OPT.lineColor  = [0 0 0];
OPT.lineAlpha  = 1;
OPT.lineWidth  = 1;

if nargin==0; varargout = {OPT}; return; end

OPT = setproperty(OPT,varargin{:});

if isempty(OPT.name)
   warning('property ''name'' required')
end

%% type STYLE
temp      = dec2hex(round([OPT.lineAlpha, OPT.lineColor].*255),2);
%http://code.google.com/intl/nl/apis/kml/documentation/kmlreference.html#color
%
% Color and opacity (alpha) values are expressed in hexadecimal notation. 
% The range of values for any one color is 0 to 255 (00 to ff). 
% For alpha, 00 is fully transparent and ff is fully opaque. The order of 
% expression is aabbggrr, where 
% aa = alpha (00 to ff); 
% bb = blue  (00 to ff); 
% gg = green (00 to ff); 
% rr = red   (00 to ff). 
% For example, if you want to apply
% a blue color with 50 percent opacity to an overlay, you would specify the 
% following: <color>7fff0000</color>, where alpha=0x7f, blue=0xff, green=0x00, and red=0x00.
lineColor = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)]; % a b g r

output = sprintf([...
    '<Style id="%s">\n'...      % OPT.name
    '<LineStyle>\n'...
    '<color>%s</color>\n'...    % lineColor
    '<width>%0.1f</width>\n'... % OPT.lineWidth
    '</LineStyle>\n'...
    '</Style>\n'],...
    OPT.name,lineColor,OPT.lineWidth);
    
    varargout = {output};

%% EOF