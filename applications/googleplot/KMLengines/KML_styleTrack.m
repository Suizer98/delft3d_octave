function [output] = KML_style(varargin)
%KML_styleTrack low-level routine for creating KML string of line style
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

% $Id: KML_styleTrack.m 10842 2014-06-12 12:50:54Z scheel $
% $Date: 2014-06-12 20:50:54 +0800 (Thu, 12 Jun 2014) $
% $Author: scheel $
% $Revision: 10842 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_styleTrack.m $
% $Keywords: $

%% Properties

OPT.name         = [];
OPT.lineColor    = [.3 .3 1];
OPT.lineAlpha    = 0.7;
OPT.lineWidth    = 4;
OPT.icon         = 'http://maps.google.com/mapfiles/kml/shapes/track.png';
OPT.iconColor    = [];
OPT.iconScale    = 1;
OPT.hlLineColor  = [0 0 1];
OPT.hlLineAlpha  = 0.9;
OPT.hlLineWidth  = 6;
OPT.hlIcon       = 'http://maps.google.com/mapfiles/kml/shapes/track.png';
OPT.hlIconColor  = [];
OPT.hlIconScale  = 1.2;
OPT.balloonStyle = '';

OPT = setproperty(OPT,varargin{:});

if isempty(OPT.name)
   warning('property ''name'' required')
end

if nargin==0
   output = OPT;
   return
end

%% type STYLE
temp        = dec2hex(round([OPT.lineAlpha, OPT.lineColor].*255),2);
%http://code.google.com/intl/nl/apis/kml/documentation/kmlreference.html#color
%
% Color and opacity (alpha) values are expressed in hexadecimal notation. 
% The range of values for any one color is 0 to 255 (00 to ff). 
% For alpha, 00 is fully transparent and ff is fully opaque. The order of 
% expression is aabbggrr, where aa=alpha (00 to ff); bb=blue (00 to ff); 
% gg=green (00 to ff); rr=red (00 to ff). For example, if you want to apply
% a blue color with 50 percent opacity to an overlay, you would specify the 
% following: <color>7fff0000</color>, where alpha=0x7f, blue=0xff, green=0x00, and red=0x00.
lineColor   = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)]; % a b g r
temp        = dec2hex(round([OPT.hlLineAlpha, OPT.hlLineColor].*255),2);
hlLineColor = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)]; % a b g r

if isempty(OPT.iconColor)
    iconColor = '';
else
    temp      = dec2hex(round([1 OPT.iconColor].*255),2);
    iconColor = ['          <color>' temp(1,:) temp(4,:) temp(3,:) temp(2,:) '</color>'];
end
if isempty(OPT.hlIconColor)
    hlIconColor = '';
else
    temp      = dec2hex(round([1 OPT.hlIconColor].*255),2);
    hlIconColor = ['          <color>' temp(1,:) temp(4,:) temp(3,:) temp(2,:) '</color>'];
end

%% preprocess balloonstyle
if  isempty(OPT.balloonStyle)
    balloonStyle = '';
else
    balloonStyle = ['<BalloonStyle>' OPT.balloonStyle '</BalloonStyle>'];
end


output = sprintf([...
'<!-- Normal multiTrack style -->\n'...
'    <Style id="%s_n">\n'...OPT.name
'      %s'...balloonStyle
'      <LineStyle>\n'...
'        <color>%s</color>\n'...lineColor
'        <width>%0.1f</width>\n'...OPT.lineWidth
'      </LineStyle>\n'...
'      <IconStyle>\n'...
'        <scale>%2.1f</scale>\n'...OPT.iconScale
'        <Icon>\n'...
'          <href>%s</href>\n'... OPT.icon
'        </Icon>\n'...
'%s'... iconColor
'      </IconStyle>\n'...
'    </Style>\n'...
'<!-- Highlighted multiTrack style -->\n'...
'    <Style id="%s_h">\n'...OPT.name
'      %s'...balloonStyle
'      <LineStyle>\n'...
'        <color>%s</color>\n'...lineColor
'        <width>%0.1f</width>\n'...OPT.hlLineWidth
'      </LineStyle>\n'...
'      <IconStyle>\n'...
'        <scale>%2.1f</scale>\n'... OPT.hlIconScale
'        <Icon>\n'...
'          <href>%s</href>\n'... OPT.hlIcon
'        </Icon>\n'...
'%s'... hlIconColor
'      </IconStyle>\n'...
'    </Style>\n'...
'    <StyleMap id="%s">\n'...OPT.name
'      <Pair>\n'...
'        <key>normal</key>\n'...
'        <styleUrl>#%s_n</styleUrl>\n'...OPT.name
'       </Pair>\n'...
'       <Pair>\n'...
'         <key>highlight</key>\n'...
'         <styleUrl>#%s_h</styleUrl>\n'...OPT.name
'       </Pair>\n'...
'     </StyleMap>\n'],...
    OPT.name,balloonStyle,  lineColor,OPT.lineWidth,OPT.iconScale,OPT.icon,iconColor,...
    OPT.name,balloonStyle,hlLineColor,OPT.hlLineWidth,OPT.hlIconScale,OPT.hlIcon,hlIconColor,...
    OPT.name,OPT.name,OPT.name);

%% EOF