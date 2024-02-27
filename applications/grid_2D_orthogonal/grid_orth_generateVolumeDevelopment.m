function grid_orth_generateVolumeDevelopment(varargin)
%GRID_ORTH_GENERATEVOLUMEDEVELOPMENT  General volume development tool.
% 
% This routine helps to generate information on volume development within a 
% given polygon.
%
% With default settings the routine starts with an emptied polygon dir
% which allows the user to select a new polygon by mouseclick. NB: you need
% to select the option save as .mat file when clicking the polygon. When
% you disable the 'remove_cached_results' option the routine will calculate
% volume development for each polygon in the polygon directory.
%
% For specific applications it is recommended to run this
% grid_orth_generateVolumeDevelopment script with keyword value pairs as
% demonstrated in the following example:
%
%{

dataset = 'd:\checkouts\vo_nc\projects\151027_maasvlakte_2\elevation_data\gebiedsmodel_2.5x2.5_weekly_filled\catalog.nc'
grid_orth_generateVolumeDevelopment( ...
   'dataset',                dataset, ...             % select a dataset, must be a catalog.nc
   'remove_cached_results',  1, ...                   % 1 will trigger removal of cached results, default 1 is to never use cached results
   'remove_cached_polygons', 1, ...                   % 1 will delete previously used polygons, default 1 is to allways start with an empty polygon dir which allows the user to select a new polygon by mouseclick
   'starttime',              datenum(2010,10,10), ... % indicate desired start time of volume development (otherwise routine will start from first time available in database)
   'stoptime',               datenum(2010,11,10), ... % indicate desired stop time of volume development (otherwise routine will continue untill last time available in database)
   'searchinterval',         0, ...                   % acceptable interval to include data from (in days - minus: looking back, plus: looking forward)
   'mincoverage',            80);                     % coverage percentage (can be several, e.g. [50 75 90]), for the 'filled' datasets it suffices to select 1 coverage percentage (e.g. 90 %)

%}
%
% See also grid_orth_getSandbalance, grid_orth_findCoverage,
% grid_orth_getDataInPolygon

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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: grid_orth_generateVolumeDevelopment.m 4414 2011-04-07 08:24:07Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-04-07 16:24:07 +0800 (Thu, 07 Apr 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4414 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_generateVolumeDevelopment.m $
% $Keywords: $

clc; warning off

%% INITIALIZE ---------------------------------------------------------------------------

%% settings
% identify dataset and landboundary file to use
OPT.dataset                = 'd:\checkouts\vo_nc\projects\151027_maasvlakte_2\elevation_data\gebiedsmodel_2.5x2.5_filled_weekly\catalog.nc';
OPT.ldburl                 = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc'; % indicate landboundary file to use in plotting (default holland.nc)

OPT.script_path            = fileparts(mfilename('fullpath'));       % returns the path of this processing script (without filesep at the end)

OPT.workdir                = fullfile(OPT.script_path, 'sedbudget'); % this is the directory where the script will look for polygons and where it will write results  
OPT.remove_cached_results  = 1;                                      % 1 will trigger removal of cached results, default 0 is to always use cached results

OPT.polygondir             = fullfile(OPT.script_path, 'sedbudget', 'polygons');
OPT.remove_cached_polygons = 1;                                      % this will clear the polygon dir

OPT.starttime              = datenum(2010,10,10);
OPT.stoptime               = datenum(2010,11,10);
OPT.searchinterval         = 0;                                      % acceptable interval to include data from (in days - minus: looking back, plus: looking forward)
OPT.mincoverage            = 80;                                     % coverage percentage (can be several, e.g. [50 75 90]), for the 'filled' datasets it suffices to select 1 coverage percentage (e.g. 90 %)

OPT.dredgingdumping        = '';                                     % recent feature to include dredging and dumping data (under construction)
    dredgingdumping.intervals = [];
    dredgingdumping.polynames = [];
    dredgingdumping.data      = [];

OPT = setproperty(OPT, varargin{:});
    
%% clear cached polygons
if OPT.remove_cached_polygons
    try rmdir(fullfile(OPT.polygondir),  's');          end
end

%% clear cached sedbudget results
if OPT.remove_cached_results
    try rmdir(fullfile(OPT.workdir, 'coverage'),  's'); end
    try rmdir(fullfile(OPT.workdir, 'datafiles'), 's'); end
    try rmdir(fullfile(OPT.workdir, 'results'),   's'); end
end

%% initialise waitbars
multiWaitbar('Gathering coverage info (per polygon) ...',       0, 'Color', [1.0 0.4 0.0])
multiWaitbar('Collecting data (each timestep per polygon) ...', 0, 'Color', [0.1 0.5 0.8])
multiWaitbar('Processing end results (per polygon) ...',        0, 'Color', [0.2 0.9 0.3])

%% START PROCESSING ---------------------------------------------------------------------

%% generate sediment budget
grid_orth_getSandBalance( ...
    'dataset'          , OPT.dataset, ...                           % dataset name (should be a catalog.nc)
    'ldburl'           , OPT.ldburl, ...                            % ldb to use in the overview figure
    'workdir'          , OPT.workdir, ...                           % location to place data processing results
    'polygondir'       , OPT.polygondir, ...                        % location to look for polygons (relative to this script)
    'starttime'        , OPT.starttime, ...                         % indicate starttime for sediment budget
    'stoptime'         , OPT.stoptime, ...                          % indicate stoptime for sediment budget
    'searchinterval'   , OPT.searchinterval, ...                    % acceptable interval to include data from (in days)
    'min_coverage'     , OPT.mincoverage, ...                       % coverage percentage (can be several, e.g. [50 75 90]), for the 'filled' datasets it suffices to select 1 coverage percentage (e.g. 90 %)
    'intervals'        , dredgingdumping.intervals, ...             % under construction (temporarily left empty)
    'polynames'        , dredgingdumping.polynames, ...             % under construction (temporarily left empty)
    'data'             , dredgingdumping.data, ...                  % under construction (temporarily left empty)
    'postProcessingFcn', @(OPT, results, Volumes, n) grid_orth_plotSandbalance(OPT, results, Volumes, n)); % post processing fcn (grid_orth_plotSandbalance is the default one)
