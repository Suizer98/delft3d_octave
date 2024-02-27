function ITHK_distrsupp_to_kml(ii,sens)
%function ITHK_distrsupp_to_kml(ii,sens)
%
% Adds distributed nourishment to the KML file
%
% INPUT:
%      ii     number of distributed nourishment
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .output
%              .duration
%              .implementation
%              .distrsupp(ii).lat
%              .distrsupp(ii).lon
%              .distrsupp(ii).magnitude
%              .MDAdata_NEW.Xcoast
%              .MDAdata_NEW.Ycoast
%              .kml.t0
%              .kml.s0
%              .kml.x0
%              .kml.y0
%              .kml.sgridRough
%              .kml.dxFine
%              .kml.sVectorLength
%              .kml.idplotrough
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .kml.idplotrough
%              .output
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_distrsupp_to_kml.m 10731 2014-05-22 14:41:23Z boer_we $
% $Date: 2014-05-22 22:41:23 +0800 (Thu, 22 May 2014) $
% $Author: boer_we $
% $Revision: 10731 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/measures/ITHK_distrsupp_to_kml.m $
% $Keywords: $

%% code

global S

%% Get info from structure
% General info
output = S.output;
duration = S.duration;
implementation = S.implementation;
t0 = S.kml.t0;
% Measure info
lat = S.distrsupp(ii).lat;
lon = S.distrsupp(ii).lon;
mag = S.distrsupp(ii).magnitude;
% MDA info
MDAdata_NEW = S.MDAdata_NEW;
x0 = S.kml.x0;
y0 = S.kml.y0;
s0 = S.kml.s0;
% Grid info
sgridRough = S.kml.sgridRough; 
dxFine = S.kml.dxFine;
sVectorLength = S.kml.sVectorLength;
idplotrough = S.kml.idplotrough;

%% preparation
x = S.kml.x0(1:307);
y = S.kml.y0(1:307);

% width nourishment
width               = (abs(x(1)-x(end))^2+abs(y(1)-y(end))^2)^0.5;

% project nourishment location on coast line
% for jj=1:length(x)
%     dist2           = ((x0-x(jj)).^2 + (y0-y(jj)).^2).^0.5;  % distance to coast line
%     idNEAREST       = find(dist2==min(dist2),1,'first');
%     x1(jj)          = x0(idNEAREST);
%     y1(jj)          = y0(idNEAREST);
%     s1(jj)          = s0(idNEAREST);
%     clear dist2 idNEAREST
% end


%% nourishment to KML
h = mag/width;
for jj=1:length(x)-1
    alpha = atan((y(jj+1)-y(jj))/(x(jj+1)-x(jj)));
    if alpha>0
        x2(jj)     = x(jj)+0.5*S.kml.sVectorLength*h*cos(alpha+pi()/2);
        y2(jj)     = y(jj)+0.5*S.kml.sVectorLength*h*sin(alpha+pi()/2);
    elseif alpha<=0
        x2(jj)     = x(jj)+0.5*S.kml.sVectorLength*h*cos(alpha-pi()/2);
        y2(jj)     = y(jj)+0.5*S.kml.sVectorLength*h*sin(alpha-pi()/2);
    end
end
x2 = x2'; y2 = y2';
xpoly=[x; flipud(x2); x(1)];
ypoly=[y; flipud(y2); y(1)];

% convert coordinates
[lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,S.EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');

% yellow triangle
output = [output KML_stylePoly('name','default','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7)];
% polygon to KML
output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+implementation,1,1),'timeOut',datenum(t0+duration,1,1)+364,'styleName','default')];
clear lonpoly latpoly

%% Save info fine and rough grids for plotting bars
S.kml.idplotrough = idplotrough;
S.output = output;




