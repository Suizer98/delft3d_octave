function [results] = grid_orth_generateDifferenceMaps(varargin)
%GRID_ORTH_GENERATEDIFFERENCEMAPS  General difference map tool.

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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: grid_orth_generateDifferenceMaps.m 5401 2011-10-31 16:27:18Z tda.x $
% $Date: 2011-11-01 00:27:18 +0800 (Tue, 01 Nov 2011) $
% $Author: tda.x $
% $Revision: 5401 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_generateDifferenceMaps.m $
% $Keywords: $

clc; warning off %#ok<WNOFF>

%% INITIALIZE ---------------------------------------------------------------------------

%% settings
% identify dataset and landboundary file to use
OPT.dataset                = 'd:\checkouts\vo_nc\projects\151027_maasvlakte_2\elevation_data\gebiedsmodel_2.5x2.5_weekly_filled\catalog.nc';
OPT.ldburl                 = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc'; % indicate landboundary file to use in plotting (default holland.nc)
OPT.polygon                = [];

% provide general settings for grid_orth_getDataInPolygon
OPT.thinning               = 1;

% reference time: specify settings for grid_orth_getDataInPolygon
OPT.time_bathy_ref         = datenum(2010,10,10);                    % sedimentation erosion is determined by calculating bathy minus bathy_ref
OPT.searchinterval_ref     = -7;                                     % acceptable interval to include data from (in days - minus: looking back, plus: looking forward)

% target time: specify settings for grid_orth_getDataInPolygon
OPT.time_bathy             = datenum(2010,11,10);                    % sedimentation erosion is determined by calculating bathy minus bathy_ref
OPT.searchinterval         = -7;                                     % acceptable interval to include data from (in days - minus: looking back, plus: looking forward)

% specify plotting details
OPT.plot_difference_map    = 1;
OPT.caxis                  = [-2 2];                                 % coloring limits to use in the difference plot
OPT.colormap               = colormap(colormap_cpt('srtRdBu10',100));
OPT.figure_handle          = 3;

OPT = setproperty(OPT, varargin{:});


%% GETDATA --------------------------------------------------------------------------

% get the data from the OpenDap server
disp('Getting data ...')

% get bathy at reference time
[X1, Y1, Z1, ~, OPT2] = grid_orth_getDataInPolygon(...
    'dataset',          OPT.dataset, ...
    'starttime',        OPT.time_bathy_ref, ...
    'searchinterval',   OPT.searchinterval_ref, ...
    'datathinning',     OPT.thinning, ...
    'polygon',          OPT.polygon, ...
    'plotresult',       0);

OPT = mergestructs(OPT, OPT2); clear OPT2

% get bathy at target time
[~, ~, Z2, ~, OPT2]   = grid_orth_getDataInPolygon(...
    'dataset',          OPT.dataset, ...
    'starttime',        OPT.time_bathy, ...
    'searchinterval',   OPT.searchinterval, ...
    'datathinning',     OPT.thinning, ...
    'polygon',          OPT.polygon, ...
    'plotresult',       0);

OPT = mergestructs(OPT, OPT2); clear OPT2

%% COMPUTE RESULTS --------------------------------------------------------------------------

%% get some basic info useful for the volume computations
% get difference info (contains only values for pixels that are not NaN in both datasets!)
Z3 = Z2 - Z1;

% get cell size
cellsize                                 = median(diff(X1(1,:)));
clear results
%% initialise results structure
results.total_volume                     =  [];
results.sedimentation_volume             =  [];
results.erosion_volume                   =  [];

results.total_area                       =  [];
results.sedimentation_area               =  [];
results.erosion_area                     =  [];
results.no_change_area                   =  [];

results.total_coverage_perc              =  [];
results.sedimentation_coverage_perc      =  [];
results.erosion_coverage_perc            =  [];
results.no_change_coverage_perc          =  [];

%% compute results
% compute results for total area:
id                                       = ~isnan(Z1) & ~isnan(Z2);

results.total_volume                     = sum((Z2(id)-Z1(id)) * (cellsize * OPT.thinning * cellsize * OPT.thinning));
results.total_area                       = sum(sum(sum(id))    * (cellsize * OPT.thinning * cellsize * OPT.thinning));

total                                    = sum(sum(inpolygon(X1, Y1, OPT.polygon(:,1), OPT.polygon(:,2))));
results.total_coverage_perc              = (sum(sum((~isnan(Z2(id)-Z1(id)))))/total) * 100; 

% compute results for areas with: sedimentation
id                                       = Z3 > 0;
results.sedimentation_volume             = sum((Z2(id)-Z1(id)) * (cellsize * OPT.thinning * cellsize * OPT.thinning));
results.sedimentation_area               = sum(sum(sum(id))    * (cellsize * OPT.thinning * cellsize * OPT.thinning));

total                                    = sum(sum(inpolygon(X1, Y1, OPT.polygon(:,1), OPT.polygon(:,2))));
results.sedimentation_coverage_perc      = (sum(sum((~isnan(Z2(id)-Z1(id)))))/total) * 100; 

% compute results for areas with: erosion
id                                       = Z3 < 0;
results.erosion_volume                   = sum((Z2(id)-Z1(id)) * (cellsize * OPT.thinning * cellsize * OPT.thinning));
results.erosion_area                     = sum(sum(sum(id))    * (cellsize * OPT.thinning * cellsize * OPT.thinning));

total                                    = sum(sum(inpolygon(X1, Y1, OPT.polygon(:,1), OPT.polygon(:,2))));
results.erosion_coverage_perc            = (sum(sum((~isnan(Z2(id)-Z1(id)))))/total) * 100; 

% compute results for areas with: no change
id                                       = Z3 == 0;

results.no_change_area                   = sum(sum(sum(id))    * (cellsize * OPT.thinning * cellsize * OPT.thinning));

total                                    = sum(sum(inpolygon(X1, Y1, OPT.polygon(:,1), OPT.polygon(:,2))));
results.no_change_coverage_perc          = (sum(sum((~isnan(Z2(id)-Z1(id)))))/total) * 100; 

%% PLOT RESULTS --------------------------------------------------------------------------

if OPT.plot_difference_map
    figure(OPT.figure_handle);clf
    
    surf(X1, Y1, Z2-Z1);
    caxis(OPT.caxis)
    
    colormap(OPT.colormap);
    
    colorbar;
    
    shading interp; axis equal; box on; grid off; view(2)
    
    xlabel('x-distance [m]')
    ylabel('y-distance [m]')
    title({'Sedimentation erosion plot'; [datestr(datenum(OPT.time_bathy_ref)) ' minus '  datestr(datenum(OPT.time_bathy))]})
    
    tickmap ('xy','texttype','text','format','%0.1f','dellast',1)

end
