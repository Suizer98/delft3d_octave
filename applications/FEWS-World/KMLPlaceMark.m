function KMLPlaceMark(lat,lon,kmlName,varargin)
%KMLPLACEMARK   plots PlaceMarks in a KML file at user-specified locations
%
%   KMLPlaceMark(lat,lon,kmlName,varargin)
%
% General description
% ==============================
% This function plots PlaceMarks in a KML file at user-specified locations
% and saves in user-specified file.
%
% usage:    KMLTimeSeriesClim(lat,lon,model,scenario,variable)
%
% Compulsory inputs:
% ==============================
% lat:     vector with latitude values of interest(range: -90/90)
% lon:     vector with longitude values of interest (range: -180/180)
% kmlName: Name of KML file to export to:
%
% MATLAB will not give any outputs to the screen. The result will be a
% KML-file located in a new folder, specified by
% <model>_<scenario>_<variable>. Do not change the file structure within
% this folder, it will render the kml unusable! You can however shift the
% whole folder to other locations.
%
% No additional options are available, all inputs are compulsory
%
%See also: KMLTimeSeriesClim, googleplot

%% OpenEarth general information
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Hessel C. Winsemius
%
%       hessel.winsemius@deltares.nl
%       (tel.: +31 88 335 8465)
%       Rotterdamseweg 185
%       Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: KMLPlaceMark.m 13740 2017-09-20 11:31:47Z groenenb $
% $Date: 2017-09-20 19:31:47 +0800 (Wed, 20 Sep 2017) $
% $Author: groenenb $
% $Revision: 13740 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/FEWS-World/KMLPlaceMark.m $

%% Keywords

OPT.name(1:length(lat))          = {''};
OPT.description(1:length(lat))   = {''};
OPT.Z             = zeros(size(lat));
OPT.icon          = 'http://maps.google.com/mapfiles/kml/paddle/blu-stars.png';
OPT.iconScale     = 1.4;
[OPT, Set, Default] = setproperty(OPT, varargin{:});
if nargin<3
    disp('Minimal number of arguments is 3 (lat, lon, filename)');
  return
end
if length(lat)~=length(lon)
    disp('lats and lons must have same lengths');
    return
end
if max(lat) > 90 | min(lat) < -90 | max(lon) > 180 | min(lon) < -180
    disp('Latitude or longitude out range. Permitted range for longitudes is -180....180, permitted range for latitudes -90....90. Exiting...');
    return
end

%% do the work

fid = fopen(kmlName,'w');
fprintf(fid,'%s\n','<Document>');
    fprintf(fid,'%s\n','<Style id="sh_caution">');
    fprintf(fid,'%s\n','<IconStyle><scale>2.0</scale><Icon>');
    fprintf(fid,'%s\n',['  <href>' OPT.icon]);
    fprintf(fid,'%s\n','  </href></Icon></IconStyle>');
    fprintf(fid,'%s\n','  <ListStyle>');
	fprintf(fid,'%s\n','  </ListStyle>');
    fprintf(fid,'%s\n','</Style>');
    fprintf(fid,'%s\n','<Style id="sn_caution">');
    fprintf(fid,'%s\n','<IconStyle><scale>',num2str(OPT.iconScale,'%.1f'),'</scale><Icon>');
    fprintf(fid,'%s\n',['  <href>' OPT.icon]);
    fprintf(fid,'%s\n','  </href></Icon></IconStyle>');
    fprintf(fid,'%s\n','  <ListStyle>');
	fprintf(fid,'%s\n','  </ListStyle>');
    fprintf(fid,'%s\n','</Style>');
	fprintf(fid,'%s\n','<StyleMap id="msn_caution">');
	fprintf(fid,'%s\n','	<Pair>');
	fprintf(fid,'%s\n','		<key>normal</key>');
	fprintf(fid,'%s\n','		<styleUrl>#sn_caution</styleUrl>');
	fprintf(fid,'%s\n','	</Pair>');
	fprintf(fid,'%s\n','	<Pair>');
	fprintf(fid,'%s\n','        <key>highlight</key>');
	fprintf(fid,'%s\n','		<styleUrl>#sh_caution</styleUrl>');
	fprintf(fid,'%s\n','	</Pair>');
	fprintf(fid,'%s\n','</StyleMap>');
for place = 1:length(lat)
    fprintf(fid,'%s\n','<Placemark id="point">');
    fprintf(fid,'%s\n','<name>');
    fprintf(fid,'%s\n',['  ' OPT.name{place}]);
    fprintf(fid,'%s\n','</name>');
    fprintf(fid,'%s\n','<visibility>');
    fprintf(fid,'%s\n','  1');
    fprintf(fid,'%s\n','</visibility>');
    fprintf(fid,'%s\n','<description>');
    fprintf(fid,'%s\n',['  <![CDATA[' OPT.description{place} ']]>']);
    fprintf(fid,'%s\n','</description>');
    fprintf(fid,'%s\n','<styleUrl>#msn_caution</styleUrl>');
    fprintf(fid,'%s\n',['<Point id="Marker_' num2str(place) '">']);
    fprintf(fid,'%s\n','<altitudeMode>relativeToGround</altitudeMode>');
    fprintf(fid,'%s\n','<tessellate>');
    fprintf(fid,'%s\n','1');
    fprintf(fid,'%s\n','</tessellate>');
    fprintf(fid,'%s\n','<extrude>0</extrude>');
    fprintf(fid,'%s\n','<coordinates>');
    fprintf(fid,'%s\n',['  ' num2str(lon(place),'%.10e') ',' num2str(lat(place),'%.10e') ',' num2str(OPT.Z(place),'%.10e')]);
    fprintf(fid,'%s\n','</coordinates>');
    fprintf(fid,'%s\n','</Point>');
    fprintf(fid,'%s\n','</Placemark>');
end
fprintf(fid,'%s\n','</Document>');

fclose(fid);