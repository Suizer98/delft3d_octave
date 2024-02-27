function ITHK_beachext_to_kml(ii,sens)
%function ITHK_beachext_to_kml(ii,sens)
%
% Adds seaward beach extension to the KML file
%
% INPUT:
%      ii     number of beach extension
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .output
%              .duration
%              .implementation
%              .beachextension(ii).lat
%              .beachextension(ii).lon
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

% $Id: ITHK_beachext_to_kml.m 10731 2014-05-22 14:41:23Z boer_we $
% $Date: 2014-05-22 22:41:23 +0800 (Thu, 22 May 2014) $
% $Author: boer_we $
% $Revision: 10731 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/measures/ITHK_beachext_to_kml.m $
% $Keywords: $

%% code

%% Get info from structure
% General info
output = S.output;
duration = S.duration;
implementation = S.implementation;
t0 = S.kml.t0;
% Measure info
lat = S.beachextension(ii).lat;
lon = S.beachextension(ii).lon;
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
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',str2double(S.settings.EPSGcode));
% dist2 = ((MDAdata_NEW.Xcoast-x0).^2 + (MDAdata_NEW.Ycoast-y0).^2).^0.5;
% x1 = x0(dist2>1);x2 = MDAdata_NEW.Xcoast(dist2>1);
% y1 = y0(dist2>1);y2 = MDAdata_NEW.Ycoast(dist2>1);
% s1 = s0(dist2>1);

for jj=1:length(x)
    dist1 = ((MDAdata_NEW.Xcoast-x(jj)).^2 + (MDAdata_NEW.Ycoast-y(jj)).^2).^0.5;
    x1(jj) = x0(dist1==min(dist1));x2(jj) = MDAdata_NEW.Xcoast(dist1==min(dist1));
    y1(jj) = y0(dist1==min(dist1));y2(jj) = MDAdata_NEW.Ycoast(dist1==min(dist1));
    s1(jj) = s0(dist1==min(dist1));
    clear dist1
end
xpoly=[x1(1:end) x2(end:-1:1) x1(1)];
ypoly=[y1(1:end) y2(end:-1:1) y1(1)];

% convert coordinates
[lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
lonpoly     = lonpoly';
latpoly     = latpoly';

% yellow plane
output = [output KML_stylePoly('name','default','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7)];
% polygon to KML
output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+implementation,1,1),'timeOut',datenum(t0+implementation+1,1,1)+364,'styleName','default')];
clear lonpoly latpoly

% Ids for barplots
if s1(1)<s1(end) 
    sfine(1)        = s1(1)-dxFine;
    sfine(2)        = s1(end)+dxFine;
else
    sfine(1)        = s1(end)-dxFine;
    sfine(2)        = s1(1)+dxFine;
end
for ii=1:length(sfine)
    dist{ii} = abs(sgridRough-sfine(ii));
    idrough(ii) = find(dist{ii} == min(dist{ii}),1,'first');
end
%idplotrough(idrough(1):idrough(end)) = 0;

%% Save info fine and rough grids for plotting bars
S.kml.idplotrough = idplotrough;
S.output = output;
