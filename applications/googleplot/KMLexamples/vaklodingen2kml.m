%VAKLODINGEN2KML   make kml file of each vaklodingen grid
%
%See also: jarkus_grids2kml, vaklodingen2png, vaklodingen_overview

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

% $Id: vaklodingen2kml.m 911 2009-09-02 16:54:44Z damsma $
% $Date: 2009-09-03 00:54:44 +0800 (Thu, 03 Sep 2009) $
% $Author: damsma $
% $Revision: 911 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLexamples/vaklodingen2kml.m $
% $Keywords: $

clear all
outputDir = 'F:\vaklodingen3D';
url       = vaklodingen_url;
EPSG      = load('EPSG');

for ii = 107:1:length(url);
    [path, fname] = fileparts(url{ii});
    x    = nc_varget(url{ii},   'x');
    y    = nc_varget(url{ii},   'y');
    time = nc_varget(url{ii},'time');

    %create output directory
    outputDir2 = [outputDir filesep fname filesep];

    %Check dir, make if needed
    if ~isdir(outputDir2)
        mkdir(outputDir2);
    end

    % calculate coordinates, should not be necessary!!
    % it is though ... but it goes lightning fast anyways ;-)
    [x,y] = meshgrid(x,y);

    % convert time to years
    time = datestr(time+datenum(1970,1,1),'yyyy-mm-dd');
    % convert coordinates
    [lon,lat] = convertCoordinates(x,y,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');

    %loop through all the years
    for jj = size(time,1)
%         try
            % display progress
            disp([num2str(ii) '/' num2str(length(url)) ' ' fname ' ' time(jj,:)]);
            z=[];


            if ~exist([outputDir2 time(jj,:) '_3D.kmz'],'file')
                % load z data
                z = nc_varget(url{ii},'z',[jj-1,0,0],[1,-1,-1]);
                z(z>500) = nan;
                disp(['elements: ' num2str(sum(~isnan(z(:))))]);
                
% lat = lat(1:300,1:300);
% lon = lon(1:300,1:300);
% z = z(1:300,1:300);
                % make *.kmz
                KMLsurf_tiled(lat,lon,z)%,'fileName',[outputDir2 time(jj,:) '_3D.kmz'],...
                    %'kmlName',[fname ' ' time(jj,:) ' 2D'],'cLim',[(a-c)*b (a+c)*b]);
            else
                disp ([outputDir2 time(jj,:) '_3D.kmz already exists'])
            end

%             % pcolor
%             if ~exist([outputDir2 time(jj,:) '_2D.kmz'],'file')
%                 if isempty(z)
%                     % load z data
%                     z = nc_varget(contents{ii},'z',[jj-1,0,0],[1,-1,-1]);
%                     z(z>500) = nan;
%                     disp(['elements: ' num2str(sum(~isnan(z(:))))]);
%                 end
%                 z= (z+a)*b;
%                 KMLpcolor(lat,lon,z,'fileName',[outputDir2 time(jj,:) '_2D.kmz'],...
%                     'kmlName',[fname ' ' time(jj,:) ' 2D'],'lineWidth',0.3,'lineAlpha',.6,'fillAlpha',.8,...
%                     'colormap','colormapbathymetry','colorSteps',64,...
%                     'cLim',[(a-c)*b (a+c)*b]);
%             else
%                 disp ([outputDir2 time(jj,:) '_2D.kmz already exists'])
%             end
%         catch
%             warning([num2str(ii) '/' num2str(length(url)) ' ' fname ' ' time(jj,:) ' FAILED']); %#ok<WNTAG>
%         end
    end
end