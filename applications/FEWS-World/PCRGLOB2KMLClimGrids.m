function PCRGLOB2KMLClimGrids(lat_range, lon_range, model, scenario, var, outFolder)
%PCRGLOB2KMLClimGrids   climatology grids computed from PCR-GLOBWB climate scenarios
%
%   PCRGLOB2KMLClimGrids(lat_range,lon_range,model,scenario,var)
%
% General description
% ==============================
% This script retrieves climatology grids of a selected variable of
% interest, as computed from PCR-GLOBWB climate scenarios. The computations
% are based on a certain climate model and scenarios (or base-line), which the user can
% specify. This script then provides climatologies of the current climate
% (1971-1990) or of the future climate (2081-2100)
% usage:    PCRGLOB2KMLTimeSeriesClim(lat,lon,model,scenario,variable)
%
% Inputs:
% ==============================
% lat_range:    2-element vector with latitude bounds of interest(range: -90/90)
% lon_range:    2-element vector with longitude bounds of interest (range: -180/180)
% model:        Climate model used for computation: can be the following:
% 
% BCM2.0        Bjerknes Centre for Climate Research	 Norway	 BCCR
% CGCM3.1       Canadian Centre for Climate Modelling and Analysis	 Canada	 CCCMA
% CGCM2.3.2     Meteorological Research Institute	 Japan	 CGCM
% CSIRO-Mk3.0   Commonwealth Scientific and Industrial Research Organization	 Australia	 CSIRO
% ECHAM5        Max Planck Institute	 Germany	 ECHAM
% ECHO-G        Freie Universität Berlin	 Germany	 ECHO
% GFDL-CM2.1    Geophysical Fluid Dynamics Centre	 USA	 GFDL
% GISS-ER       Goddard institute for Space Studies	 USA	 GISS
% IPSL-CM4      Institute Pierre Simon Laplace	 France	 IPSL
% MIROC3.2med   Center of Climate System Research	 Japan	 MIROC
% CCSM3         National Center for Atmospheric Research	 USA	 NCAR
% HADGEM1       Met Office's Hadley Centre for Climate Prediction	 UK	 HADGEM


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
% outLocation:  A local folder where KML output files are to be stored
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

% $Id: PCRGLOB2KMLClimGrids.m 2826 2010-07-13 11:24:02Z winsemi $
% $Date: 2010-07-13 19:24:02 +0800 (Tue, 13 Jul 2010) $
% $Author: winsemi $
% $Revision: 2826 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/FEWS-World/PCRGLOB2KMLClimGrids.m $

% OPT.name          = '';
% [OPT, Set, Default] = setproperty(OPT, varargin{:});

% Fix the location of nc-files. Can be either local or OpenDAP
% note HCW 22-01-2010: ncLocation will soon be changed to OpenDAP!!
% (https://....);
ncLocation = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/FEWS-IPCC';
model_abbrev = {'BCM2.0';'CGCM3.1';'CGCM2.3.2';'CSIRO-Mk3.0';'ECHAM5';...
    'ECHO-G';'GFDL-CM2.1';'GISS-ER';'IPSL-CM4';'MIROC3.2med';'CCSM3';...
    'HADGEM1'};

models = {'BCCR-BCM2';'CCCMA-CGCM31';'MRI-CGCM232';'CSIRO-Mk3';'MPI-ECHAM5';'FreieUniBerlin-ECHO-G';...
    'GFDL-CM21';'GISS-ER';'IPSL-CM4';'CCSR-MIROC32med';'NCAR-CCSM3';'HadleyCentre-HADGEM1'};

idx = strcmp(model_abbrev,model);
i = find(idx == 1);
if length(i) == 1
    disp(['Model abbreviation ''' model ''' found, model ''' models{i} ''' is used.']);
elseif length(i) > 1
    disp(['Multiple instances found for model abbreviation ''' model ''', please make description more specific']);
    disp('exiting...bye bye!');
    return
else
    disp(['No model descriptor found for abbreviation ''' model ''', please spell-check or check ''help PCRGLOB2KMLClimGrids'' for valid abbreviations']);
end
model = models{idx};
if ~(strcmp(scenario,'SRESA1B') | strcmp(scenario,'SRESA2') | strcmp(scenario,'20CM3'))
    disp(['Scenario ''' scenario ''' seems to be unavailable. Please check ''help PCRGLOB2KMLClimGrids'' for valid scenarios.']);
    disp('exiting...bye bye!')
    return
end    
% Any value > thres is assumed to be wrong! these values are removed
thres = 1e7;
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
nc_file = [ncLocation '/' scenario '_' model '_' period '.nc'];
disp(['NetCDF file to be accessed: ' nc_file]);
kmlFolder = [outFolder filesep scenario '_' model '_' period '_' var '_clim'];
disp(['KML file plus folder structure will be written in: ' kmlFolder]);
% if target directory does not exist, create the directory
if isdir(kmlFolder)==0
    disp('KML folder non-existent, creating folder...');
    mkdir(kmlFolder)
else
    disp('KML folder is available...');
end
latmin=max(min(lat_range),-90);
latmax=min(max(lat_range),90);
lonmin=max(min(lon_range),-180);
lonmax=min(max(lon_range),180);

lat_range = [latmin latmax];
lon_range = [lonmin lonmax];

disp(['Latitude range: ' num2str(latmin) '; ' num2str(latmax)]);
disp(['Longitude range: ' num2str(lonmin) '; ' num2str(lonmax)]);

%Get data
info = nc_getvarinfo(nc_file,var);
units = info.Attribute(2).Value;
lat = nc_varget(nc_file,'latitude');
lon = nc_varget(nc_file,'longitude');
time = nc_varget(nc_file,'time');
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
out_raster = zeros(nrrows,nrcols,12);
% count number of pixels for quality
nrofpix = length(loni(:));
% generate climatology
for t = 1:12 
    rasters = zeros(nrrows,nrcols,nryears);
    for y = 1:20
        rasters(:,:,y) = nc_varget(nc_file,var,[(y-1)*12+t-1 startlat-1 startlon-1],[1 nrrows nrcols]);
    end
    out_raster(:,:,t) = mean(rasters,3);
    %[loni,lati];
end
% remove incorrect values
ii = find(out_raster > thres)
out_raster(ii) = NaN;
% determine minimum value and maximum value to fix plot
maxval = max(max(max(out_raster)));
minval = min(min(min(out_raster)));
% Now plot the climatology in KML
for t = 1:12
    currdir = pwd;
    cd(kmlFolder);
    kmlName{t} = [scenario '_' model '_clim_' datestr([2000 t 1 0 0 0],'mmm') '.kml'];
    mapName{t} = [scenario '_' model '_clim_' datestr([2000 t 1 0 0 0],'mmm')];
    h=pcolorcorcen(loni,lati,out_raster(:,:,t));
    colormap([var 'map']);
    % fix color axis
    caxis([0 round(maxval*10000)/10000]);
    colorbarwithtitle(units);
    KMLfig2png(h,'fileName',kmlName{t},'levels',[0 0],'dim',min(round(nrofpix/20),1024));
    close all
    cd(currdir);
end

descript = ['Climatology of model ' model ' and scenario ' scenario];
outFile = [scenario '_' model '_clim.kml'];
currdir = pwd;
cd(kmlFolder);
% Combine created KML files and give the combination a name
KMLmerge_files('fileName',outFile,'sourceFiles',kmlName,'description',descript,'deleteSourceFiles','True');
% Create animation of kmlFiles
inFile=outFile;
begintime = [0000 01 01 0 0 0];
timestep = 1;
timeunit = 'month';
outFile = [scenario '_' model '_clim_anim.kml'];
KMLanimate(inFile, outFile, mapName, begintime, timestep, timeunit)
cd(currdir);

