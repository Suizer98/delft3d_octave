function PCRGLOB2KMLClimGrids_annual(lat_range, lon_range, model, scenario, var)
%PCRGLOB2KMLClimGrids   climatology grids computed from PCR-GLOBWB climate scenarios
%
%   PCRGLOB2KMLClimGrids_annual(lat_range,lon_range,model,scenario,var)
%
% General description
% ==============================
% This script retrieves climatology grids of a selected variable of
% interest, as computed from PCR-GLOBWB climate scenarios and base-line run. The computations
% are based on a certain climate model and scenarios, which the user can
% specify. This script then provides an interpolated time series going from the current climate
% (1971-1990) with time steps into the future climate (2081-2100)
% usage:    PCRGLOB2KMLClimGrid_annual_test(lat,lon,model,scenario,variable)
%
% Inputs:
% ==============================
% lat_range:    2-element vector with latitude bounds of interest(range: -90/90)
% lon_range:    2-element vector with longitude bounds of interest (range: -180/180)
% model:        Climate model used for computation: can be the following:
%               'FREDERIEK, KUN JE DIT INVULLEN ZOALS BENEDEN? EERST DE CODERING, DAN
%               DE BESCHRIJVING?
%
% scenario:     Scenario computed: can be the following:
%               'SRESA1B'
%               'SRESA2'
% var:          variable of interest: can be the following:
%               'EACT'    : actual evaporation (m/day)
%               'ETP'     : potential evaporation (m/day)
%               'QC'      : accumulated river discharge (m3/s)
%
% MATLAB will not give any outputs to the screen. The result will be 2
% KML-files located in a new folder, specified by
% <scenario>_<model>_<period>_<variable>. The 2 files are compilations of
% maps and animated maps respectively.
% Do not change the file structure within
% this folder, it will render the kml unusable! You can however shift the
% whole folder to other locations.
%
% No additional options are available, all inputs are compulsory
%
%See also: KMLanimate, googleplot, PCRGLOB2KMLTimeSeriesClim

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

% $Id: PCRGLOB2KMLClimGrids_annual.m 2728 2010-06-24 16:16:08Z winsemi $
% $Date: 2010-06-25 00:16:08 +0800 (Fri, 25 Jun 2010) $
% $Author: winsemi $
% $Revision: 2728 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/FEWS-World/PCRGLOB2KMLClimGrids_annual.m $

% OPT.name          = '';
% [OPT, Set, Default] = setproperty(OPT, varargin{:});

% Fix the location of nc-files. Can be either local or OpenDAP
% note HCW 22-01-2010: ncLocation will soon be changed to OpenDAP!!
% (https://....);
% model = CCSR-MIROC32med
nc_location = ('f:\raw_data');
baseline = '20CM3';

try
    if strcmp(scenario,'SRESA1B') | strcmp(scenario,'SRESA2')
        period = '2081-2100';
    else
        period = '1971-1990';
    end
catch
    disp(['Scenario ''' scenario ''' is not available. Exiting....']);
end
% Build the filename from all provided information
nc_file{1} = [nc_location filesep baseline '_' model '_1971-1990.nc'];
nc_file{2} = [nc_location filesep scenario '_' model '_2081-2100.nc'];
kmlFolder = [scenario '_' model '_' period '_' var '_annual_interpolated'];
% if target directory does not exist, create the directory
if isdir(kmlFolder)==0
    mkdir(kmlFolder)
end

latmin=max(min(lat_range),-90);
latmax=min(max(lat_range),90);
lonmin=max(min(lon_range),-180);
lonmax=min(max(lon_range),180);

lat_range = [latmin latmax];
lon_range = [lonmin lonmax];

%Get data
info = nc_getvarinfo(nc_file{1},var);
units = info.Attribute(1).Value;
lat = nc_varget(nc_file{1},'latitude');
lon = nc_varget(nc_file{1},'longitude');
time = nc_varget(nc_file{1},'time');
nryears = floor(info.Size(1)/12);

%Get rows for chosen latitudes and longitudes
a=find(abs(lat-latmax)==min(abs(lat-latmax)));
startlat=a(1);
b=find(abs(lat-latmin)==min(abs(lat-latmin)));
endlat=b(end);
nrrows=abs(endlat-startlat)+1;

c=find(abs(lon-lonmin)==min(abs(lon-lonmin)));
startlon=c(1);
d=find(abs(lon-lonmax)==min(abs(lon-lonmax)));
endlon=d(end);
nrcols=abs(endlon-startlon)+1;
lat2 = linspace(lat(startlat),lat(endlat),nrrows);
lon2 = linspace(lon(startlon),lon(endlon),nrcols);

% Calculate axes and create images
[loni,lati] = meshgrid(lon2,lat2);
nrofyears = 20;
out_raster = zeros(nrrows,nrcols,nrofyears);
% count number of pixels for quality
nrofpix = length(loni(:));

% generate average of variable (1971-1990 and 2080-2100)
%nc_file for 1971-1990:
climavg = zeros(nrrows,nrcols,length(nc_file));

for climperiod = 1:length(nc_file)
for y = 1:nrofyears
    rasters = zeros(nrrows,nrcols,12);
    for t = 1:12
        rasters(:,:,t) = nc_varget(nc_file{climperiod},var,[(t-1)+(y-1)*12 startlat-1 startlon-1],[1 nrrows nrcols]);
    end
    out_raster(:,:,y) = mean(rasters,3);
    %[loni,lati];
end
climavg(:,:,climperiod) = mean(out_raster,3);
end

% interpolate values from 1970-1991 average to 2080-2100 average (5 year intervals)
interval  = 5; %years
nrofsteps = (2090-1980)/interval+1;

deriv=(((climavg(:,:,2))-(climavg(:,:,1)))/(((2090-1980)/interval)+1));

% % determine minimum value and maximum value to fix plot
out_raster = climavg(:,:,1);
maxval = max(max(max(climavg)));
minval = min(min(min(climavg)));
% Now plot the interpolation in KML
for t = 1:nrofsteps
    currdir = pwd;
    cd(kmlFolder);
    kmlName{t} = [scenario '_' model '_interpolation_' datestr([1980+interval*(t-1) 1 1 0 0 0],'yyyy') '.kml'];
    mapName{t} = [scenario '_' model '_interpolation_' datestr([1980+interval*(t-1) 1 1 0 0 0],'yyyy')];
    h=pcolorcorcen(loni,lati,out_raster);
    colormap([var 'map']);
    % fix color axis
    caxis([0 round(maxval*10000)/10000]);
    colorbarwithtitle(units);
    KMLfig2png(h,'fileName',kmlName{t},'levels',[0 0],'dim',min(round(nrofpix/20),1024));
    close all
    cd(currdir);
    out_raster = out_raster + deriv;
end

descript = ['Interpolation from observed average' var '(1971-1990) to simulated' var 'from ' model ' and scenario ' scenario];
outFile = [scenario '_' model '_interp.kml'];
currdir = pwd;
cd(kmlFolder);
% Combine created KML files and give the combination a name
KMLmerge_files('fileName',outFile,'sourceFiles',kmlName,'description',descript,'deleteSourceFiles','True');
% Create animation of kmlFiles
inFile=outFile;
begintime = [1980 01 01 0 0 0];
timestep = 5;
timeunit = 'year';
outFile = [scenario '_' model '_interp_anim.kml'];
KMLanimate(inFile, outFile, mapName, begintime, timestep, timeunit)
cd(currdir);

