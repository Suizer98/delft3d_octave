function [X, Y, Z, Ztime, OPT] = grid_orth_getDataInPolygon(varargin)
%GRID_ORTH_GETDATAINPOLYGON  Load netcdf tiles, identifies which maps are located in polygon and retrieves the data.
%
%   Script to load fixed maps from OPeNDAP (or directory), identify which maps are located
%   inside a polygon and retrieve the data. This script is based on prevous versions of the
%   rws_getDataInPolygon script. This grid_orth_ version is more generic. It works for all bathymetry 
%   data that is stored in so-called fixed map style.
%
%   Syntax:
%
%       [X, Y, Z, Ztime] = grid_orth_getDataInPolygon(<keyword,value>);
%
%   Input:
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%       'dataset'        , 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml' = URL for fixed map dataset to use 
%       'tag             , 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml' =
%       'ldburl          , 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc' 
%       'workdir         , 'sedbudget\'                      = directory where to store all results
%       'polygondir      , 'sedbudget\polygons\'             = directory with polygons to use
%       'polygon         , []                                = two column matrix containing x and y values of polygon
%       'cellsize        , []                                = left empty will be determined automatically
%       'datathinning    , 1                                 = stride with which to skip through the data
%       'inputtimes      , datenum((2000:2008)',12, 31)      = starting points (in Matlab epoch time), left empty will be determined automatically
%       'starttime       , OPT.inputtimes(1)                 = starting time is by default the first of the input times, left empty will be determined automatically
%       'searchinterval  , -730                              = acceptable interval to include data from (in days)
%       'min_coverage    , 25                                = coverage percentage (can be several, e.g. [50 75 90]
%       'plotresult      , 1                                 = indicates whether the output should be plotted
%       'plotoverview'   , 1                                 = indicates whether the overview map should be plotted 
%       'warning         , 1                                 = indicates whether warnings should be turned on (1) or off (0)
%       'postProcessing  , 1                                 =  
%       'whattodo        , 1                                 =  
%       'type            , 1                                 =  
%       'counter         , 0                                 = 
%       'urls            , []                                = urls of the fixed maps 
%       'x_ranges        , []                                = values of x_ranges of fixed maps (for plotting on an overview)
%       'y_ranges        , []                                = values of y_ranges of fixed maps (for plotting on an overview)
%
%   Output:
%       X                = x-coordinates of extracted data
%       Y                = y-coordinates of extracted data
%       Z                = elevation values 
%       Ztime            = time stamp of elevation values
%
%   Example:
%{
    polygon = [59090.8 438855
    	58110.4 439599
    	59293.6 441289
    	60409.3 440512
    	59090.8 438855];

    datasets = {...
        'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
        'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml'};

    for i = 1:length(datasets)
        close all
        [X, Y, Z, Ztime] = grid_orth_getDataInPolygon(...
            'dataset'       , datasets{i}, ...
            'starttime'     , datenum([2010 06 01]), ...
            'searchinterval', -10*365, ...
            'datathinning'  , 1, ...
            'cellsize'      , OPT.cellsize,...
            'polygon'       , polygon);
        pause
    end
%}
%
% See also: grid_2D_orthogonal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_getDataInPolygon.m 5697 2012-01-12 12:34:32Z ormondt $
% $Date: 2012-01-12 20:34:32 +0800 (Thu, 12 Jan 2012) $
% $Author: ormondt $
% $Revision: 5697 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getDataInPolygon.m $
% $Keywords: $

%% TODO: the script does not work yet for all thinning factors. Some counter problems remain.
OPT.dataset         = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';
OPT.tag             = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc';
OPT.workdir         = 'sedbudget\';
OPT.polygondir      = 'sedbudget\polygons\';
OPT.polygon         = [];
OPT.cellsize        = [];                               % left empty will be determined automatically
OPT.datathinning    = 1;                                % stride with which to skip through the data
OPT.inputtimes      = datenum((2000:2008)',12, 31);     % starting points (in Matlab epoch time)
OPT.starttime       = OPT.inputtimes(1);
OPT.searchinterval  = -730;                             % acceptable interval to include data from (in days)
OPT.min_coverage    = 25;                               % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult      = 1;
OPT.plotoverview    = 1;
OPT.warning         = 1;
OPT.postProcessing  = 1;
OPT.whattodo        = 1;
OPT.type            = 1;
OPT.counter         = 0;
OPT.urls            = [];
OPT.x_ranges        = {};
OPT.y_ranges        = {};

OPT = setproperty(OPT, varargin{:});

%% Step 0: create a figure with tagged patches
OPT = grid_orth_getOverview(OPT);

%% Step 1: go to the axes with tagged patches and select fixed maps using a polygon
OPT = grid_orth_getPolygon(OPT);

% delete the pre existing polygon and replace it with the just generated closed one
if OPT.plotoverview
    try delete(findobj(ah,'tag','selectionpoly')); end
    try axes(ah); end; hold on
end
if ~all(OPT.polygon(1,:)==OPT.polygon(end,:))
    OPT.polygon = [OPT.polygon;OPT.polygon(1,:)];
end

if OPT.plotoverview
    plot(OPT.polygon(:,1), OPT.polygon(:,2),'color', 'g', 'linewidth', 2,'tag' ,'selectionpoly');drawnow;
end
%
% %axis([min(x) max(x) min(y) max(y)]) % does not work

%% Step 2: identify which maps are in polygon
[mapurls, minx, maxx, miny, maxy] = grid_orth_identifyWhichMapsAreInPolygon(OPT, OPT.polygon);

if isempty(mapurls) & OPT.warning
    
    X     = [];
    Y     = [];
    Z     = [];
    Ztime = [];
    warndlg('No data found in specified polygon');
    
else
    
    % Adjust minx and maxx to limit memory use (generates a smaller Z)

    X1 = [];
    Y1 = [];
    for nn = 1:length(mapurls)
        xxx = nc_varget(mapurls{nn},'x'); % make sure that dims [1 n] and [n 1] work
        yyy = nc_varget(mapurls{nn},'y');
        X1 = [X1 xxx(:)'];
        Y1 = [Y1 yyy(:)'];
    end
    
    X1 = unique(X1);
    Y1 = unique(Y1);
    
    minx = min(OPT.polygon(:,1));
    maxx = max(OPT.polygon(:,1));
    miny = min(OPT.polygon(:,2));
    maxy = max(OPT.polygon(:,2));
    
    % included the min and max statements to fix a bug that allowed return of empty minx, maxx, miny, maxy
    minx  = X1(find(X1>minx, 1, 'first'));
    maxx  = X1(find(X1<maxx, 1, 'last'));
    miny  = Y1(find(Y1>miny, 1, 'first'));
    maxy  = Y1(find(Y1<maxy, 1, 'last'));
 
    %% Step 3: retrieve data and place it on one overall grid
    [X, Y, Z, Ztime]                  = grid_orth_getDataFromNetCDFGrids(mapurls, minx, maxx, miny, maxy, OPT);
    
    if all(isnan(Ztime)) & OPT.warning
        disp(' ')
        disp('No data found in specified time period (yet grids available in polygon)')
    end
    
    
    %% Step 4: plot the end result (Z and Ztime)
    if OPT.plotresult
        % reduce the number of point to plot
        OPT.datathinning = OPT.datathinning * 2;
        
        % plot X, Y, Z and X, Y, Ztime
        grid_orth_plotDataInPolygon(X, Y, Z, Ztime,'polygon',OPT.polygon,'datathinning',OPT.datathinning,'ldburl',OPT.ldburl)
    end
    
end
