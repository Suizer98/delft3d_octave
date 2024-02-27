function grid_orth_generateProfileDevelopment(varargin)
%GRID_ORTH_GENERATEPROFILEDEVELOPMENT  General profile development tool.
%
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

% $Id: grid_orth_generateProfileDevelopment.m 5075 2011-08-17 10:32:38Z boer_g $
% $Date: 2011-08-17 18:32:38 +0800 (Wed, 17 Aug 2011) $
% $Author: boer_g $
% $Revision: 5075 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_generateProfileDevelopment.m $
% $Keywords: $

clc; warning off %#ok<WNOFF>

%% INITIALIZE ---------------------------------------------------------------------------

%% settings
% identify dataset and landboundary file to use
OPT.dataset                = 'd:\checkouts\vo_nc\projects\151027_maasvlakte_2\elevation_data\gebiedsmodel_2.5x2.5_daily_filled\catalog.nc';
OPT.ldburl                 = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc'; % indicate landboundary file to use in plotting (default holland.nc)
OPT.polygon                = [];

% provide general settings for grid_orth_getDataInPolygon
OPT.inputtimes             = [];                                     % if left empty routine will automatically retrieve times from database
OPT.starttime              = datenum(2010,09,01);                    % indicate starttime for profile extraction
OPT.stoptime               = datenum(2010,09,04);                    % indicate stoptime for profile extraction
OPT.searchinterval         = -7;                                     % acceptable interval to include data from (in days - minus: looking back, plus: looking forward)
OPT.thinning               = 1;                                      % stride to go through the data

% specify plotting details
OPT.plot_profile           = 1;

OPT = setproperty(OPT, varargin{:});

% do this AFTER setproperty
catalog                    = nc2struct(OPT.dataset);
OPT.urls                   = catalog.urlPath;
for i=1:size(catalog.projectionCoverage_x,1)
OPT.x_ranges{i}            = catalog.projectionCoverage_x(i,:);
OPT.y_ranges{i}            = catalog.projectionCoverage_y(i,:);
end

%% GETDATA --------------------------------------------------------------------------

%% create a figure with tagged patches
OPT         = grid_orth_getOverview(OPT);

%% go to the axes with tagged patches and select click a line
% click a line through mouse selection
OPT         = grid_orth_getPolygon(OPT);
xi          = OPT.polygon(1:2,1)';
yi          = OPT.polygon(1:2,2)';

% construct a tight square fitting around the clicked line
cellsize    =  median(diff(catalog.x(1,:)));
margin      = 1 * cellsize;
OPT.polygon = [...
    min(xi)-margin max(xi)+margin max(xi)+margin min(xi)-margin min(xi)-margin;
    min(yi)-margin min(yi)-margin max(yi)+margin max(yi)+margin min(yi)-margin]';

%% get time info for this polygon
OPT = grid_orth_getTimeInfoInPolygon(OPT);

if ~isempty(OPT.starttime)
    OPT.inputtimes = OPT.inputtimes (OPT.inputtimes>= OPT.starttime);
end
if ~isempty(OPT.stoptime)
    OPT.inputtimes = OPT.inputtimes (OPT.inputtimes<= OPT.stoptime);
end

%% extract the profiles from the database
try
    [crossing_x crossing_y  crossing_z crossing_d] = deal([]);
    for i = 1:length(OPT.inputtimes)
        % get X, Y, Z info for one timestep
        disp(' ')
        disp('Getting data ...')
        
        [X1, Y1, Z1, ~] = grid_orth_getDataInPolygon(...
            'dataset',        OPT.dataset, ...
            'starttime',      OPT.inputtimes(i), ...
            'searchinterval', OPT.searchinterval, ...
            'datathinning',   OPT.thinning, ...
            'polygon',        OPT.polygon, ...
            'plotresult',     0);
        
        % get crosssection
        disp(' ')
        disp('Getting cross section ...')
        
        [crossing_x_1, crossing_y_1, crossing_z_1, crossing_d_1] = grid_orth_getDataOnLine(X1,Y1,Z1,xi,yi);
        
        % collect results
        crossing_x = [crossing_x; crossing_x_1']; %#ok<*AGROW>
        crossing_y = [crossing_y; crossing_y_1'];
        crossing_z = [crossing_z; crossing_z_1'];
        crossing_d = [crossing_d; crossing_d_1'];
    end
    
end

disp(' ')
disp('Plotting results ...')

% find max extent of data to cut off useless nans
x     = crossing_d';
z     = crossing_z';
mxid  = [];
for k = 1:size(z,2)
    ids  = ~isnan(z(:,k)); id = find(ids==1,1,'last');
    mxid = max([mxid ,id]);
end

[X2, Y2, Z2] = grid_orth_getBathymetryForBackground(OPT); X2 = X2(:); Y2 = Y2(:); Z2 = Z2(:);

%% PLOT RESULTS ----------------------------------------------------------------------
figure(4);clf;

set(gcf,'renderer','zbuffer')
set(gcf,  'units', 'centimeters');

%% plot transects
sph1 = subplot(1,2,1,'align');

ph = plot(x(1:mxid,:),z(1:mxid,:),'.-');
set(gca,'xdir','reverse')
set(gca,'ylim',[-20 15])
for n = 1:length(OPT.inputtimes)
    set(ph(n), 'displayname', datestr(OPT.inputtimes(n)))
end
lh = legend(ph);
set(lh, 'fontsize', 8, 'box', 'off','location','northwest')
title({'Extracted profiles';['from ' datestr(OPT.inputtimes(1)) ' to ' datestr(OPT.inputtimes(end))]})
xlabel('elevation [m]')
ylabel('crossshore distance from transect origin [m]')
box on

%% plot transect on background
% get background and scatter it (with limitations on the number of points to plot)

sph2 = subplot(1,2,2,'align'); hold on

if sum(~isnan(Z2))<=20000 % when there are less than 10000 datapoints show all ...
    ids = ~isnan(Z2);
    scatter(X2(ids), Y2(ids), 5, Z2(ids), 'filled');
else % ... otherwise randomly draw 10000 datapoints and show them
    ids = find(~isnan(Z2));
    rd_ids = randi(length(ids),20000,1);
    scatter(X2(ids(rd_ids)), Y2(ids(rd_ids)), 5, Z2(ids(rd_ids)), 'filled');
end

% plot XYZ data from which the transect was extracted
mh = mesh(X1,Y1,Z1);

% plot the extracted transect
ph = plot3(crossing_x_1,crossing_y_1,crossing_z_1,'.k'); view(2)

% overlay netcdf tiles for reference
grid_orth_createFixedMapsOnAxes(gca,OPT);

% limit focus to area with data
axis([min(X2(ids)) max(X2(ids)) min(Y2(ids)) max(Y2(ids))])

title({'Overview profile on';['bathymetry ' datestr(OPT.inputtimes(end))]})
xlabel('x-distance [m]')
ylabel('y-distance [m]')
box on
grid off

