function PCRGLOB2KMLTimeSeriesClim(lats,lons,model,scenario,var,varargin)
%PCRGLOB2KMLTIMESERIESCLIM   time series of computed from PCR-GLOBWB climate scenarios
%
%   PCRGLOB2KMLTimeSeriesClim(lats,lons,model,scenario,var)
%
% General description
% ==============================
% This script retrieves location-specific time series of variables of
% interest, as computed from PCR-GLOBWB climate scenarios. The computations
% are based on a certain climate model and scenarios, which the user can
% specify. This script then provides climatologies of the current climate
% (1971-1990) and of the future climate (2081-2100)
% usage:    PCRGLOB2KMLTimeSeriesClim(lat,lon,model,scenario,var)
%
% Inputs:
% ==============================
% lats:     vector with latitude values of interest(range: -90/90)
% lons:     vector with longitude values of interest (range: -180/180)
% model:    Climate model used for computation: can be the following:
%           'FREDERIEK, KUN JE DIT INVULLEN ZOALS BENEDEN? EERST DE CODERING, DAN
%           DE BESCHRIJVING?
%
% scenario: Scenario computed: can be the following:
%           'SRESA1B'
%           'SRESA2'
% var:      variable of interest: can be the following:
%           'EACT'    : actual evaporation (m/day)
%           'ETP'     : potential evaporation (m/day)
%           'QC'      : accumulated river discharge (m3/s)
% Optional inputs:
% ============================
% OPT.Description:  cell array with strings, with additional description of each location
% MATLAB will not give any outputs to the screen. The result will be a
% KML-file located in a new folder, specified by
% <model>_<scenario>_<var>. Do not change the file structure within
% this folder, it will render the kml unusable! You can however shift the
% whole folder to other locations.
%
% No additional options are available, all inputs are compulsory
%
%See also: KMLPlaceMark, googleplot

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

% $Id: PCRGLOB2KMLTimeSeriesClim.m 4295 2011-03-17 12:23:08Z winsemi $
% $Date: 2011-03-17 20:23:08 +0800 (Thu, 17 Mar 2011) $
% $Author: winsemi $
% $Revision: 4295 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/FEWS-World/PCRGLOB2KMLTimeSeriesClim.m $

% OPT.name          = '';
% [OPT, Set, Default] = setproperty(OPT, varargin{:});

% Fix the location of nc-files. Can be either local or OpenDAP
% (https://....);
% model = CCSR-MIROC32med
OPT.description   = '';
[OPT, Set, Default] = setproperty(OPT, varargin{:});

nc_location = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/FEWS-IPCC/';
baseline = '20CM3';
if max(lats) > 90 | min(lats) < -90 | max(lons) > 180 | min(lons) < -180
    disp('Latitude or longitude out range. Permitted range for longitudes is -180....180, permitted range for latitudes -90....90. Exiting...');
    return
end
if length(lats)~=length(lons)
    disp('lats and lons must have same lengths. Exiting...');
    return
end
legendEntries = {'Current (1971-1990)';'Future (2081-2100)'};
ncFile{1} = [nc_location baseline '_' model '_1971-1990.nc'];
ncFile{2} = [nc_location scenario '_' model '_2081-2100.nc'];
col = {'k','r'};

KMLName = [model '_' scenario '_' var '.kml'];
Folder = [model '_' scenario '_' var];
if(isdir(Folder)==0)
    mkdir(Folder);
end
% Check for units:
try
    info = nc_getvarinfo(ncFile{1},var);
    units = info.Attribute(1).Value;
    % Retrieve variables indicating extent of dimensions
    time = nc_varget(ncFile{1},'time');
    lat = nc_varget(ncFile{1},'latitude');
    lon = nc_varget(ncFile{1},'longitude');
catch
    fprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n','Wrong selection of either model or scenario of interest.',...
        'model can be:',...
        ': ''MODEL1''',...
        'etc...',...
        'scenario can be',...
        ': ''SRESA1B''',...
        ': ''SRESA2''',...
        'Exiting...');
    return
end
% predefine what the time series will look like and datenumbers
clim_series = nan(12,length(ncFile));
datevecs = zeros(12,6);
datevecs(:,1) = 2000;
datevecs(:,2) = 1:12;
datevecs(:,3) = 1;
datenums = datenum(datevecs);
for place = 1:length(lats)
    % Search for position in lat/lon axes
    a=find(abs(lat-lats(place))==min(abs(lat-lats(place))));
    latpos(place)=a(1)-1;
    b=find(abs(lon-lons(place))==min(abs(lon-lons(place))));
    lonpos(place)=b(1)-1;

    % Start making a time,value plot
    h = figure;
    hold;
    for climperiod = 1:length(ncFile)
        try
            time_series = nc_varget(ncFile{climperiod},var,[0 latpos(place) lonpos(place)],[-1 1 1]);
    % Read NetCDF according to Lineke's scripts
    % Choose correct time series and average over months
    %units = nc_varget....
        % reshape(,12)
            clim = reshape(time_series,12,length(time_series)/12);
            clim_series(:,climperiod) = mean(clim,2);
        catch
            fprintf('%s\n%s\n%s\n%s\n%s\n','The var of interest is not available. Variable can be:',...
                ': ''EACT''',...
                ': ''ETP''',...
                ': QC''',...
                'Exiting...');
            return
        end
        plot(datenums,clim_series(:,climperiod),col{climperiod},'linewidth',2);
    end
    datetick('x',3); % display months on x axis.
    xlabel('Time');
    ylabel([var ' [' units ']']);
    grid on;
    title(['variable: ' var '; model: ' model '; scenario: ' scenario ' at ' OPT.description{place} '; Lat: ' num2str(lats(place)) ', Lon: ' num2str(lons(place))]);
    legend(legendEntries(1:length(ncFile)));
    % Save the figure to .jpg format, in the end make sure the files are
    % saved in a separate folder, that indicates the chosen climate
    % scenario, variable, etc.
    ImgName{place} = [model '_' scenario '_' var '_clim' num2str(place) '.jpg'];
    PlaceMarkText{place} = [var ' at ' OPT.description{place} '; Lat: ' num2str(lats(place)) ', Lon: ' num2str(lons(place)) '<img src="' ImgName{place} ' " width=600>'];
    Name{place} = [scenario ' ' var ' ' num2str(place)];
    print(h,'-djpeg',[Folder filesep ImgName{place}]);
    close(h);
end
kmlName = [Folder filesep KMLName];
KMLPlaceMark(lats,lons,kmlName,'name',Name,'description',PlaceMarkText);

