function grid_orth_plotSandbalance(OPT, results, Volumes, n)
%GRID_ORTH_PLOTSANDBALANCE  Plots results of sandbalance computation.
%
%       grid_orth_plotSandbalance(OPT, results, Volumes)
%
%
%   Output: plots in a selected result directory
%
%
%   Example:
%
% See also: UCIT_getSandBalance

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: grid_orth_plotSandbalance.m 4356 2011-03-26 13:59:39Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-26 21:59:39 +0800 (Sat, 26 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4356 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_plotSandbalance.m $
% $Keywords: $

warningstate = warning;
warning off

%% Polygon overview plot
% initialise figure
fh = figure('tag','sbPlot'); clf; 

nameInfo = 'OpenEarth - Overview fixed maps, used data and polygon';
set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
set(fh,'renderer','zbuffer');

% get and plot landboundary
OPT.x = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
OPT.y = nc_varget(OPT.ldburl, nc_varfind(OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
plot(OPT.x, OPT.y, 'k', 'linewidth', 2);

hold on;

% plot used polygon
if ~all(OPT.polygon(1,:)==OPT.polygon(end,:))
    OPT.polygon = [OPT.polygon;OPT.polygon(1,:)];
end
plot(OPT.polygon(:,1), OPT.polygon(:,2),'color','g','tag','polygon','linewidth',1);

% plot fixed maps
grid_orth_createFixedMapsOnAxes(gca, OPT);

% text
title({['Overview fixed maps, used data and polygon for: ' strrep(results.polyname,'_',' ')]; strrep(OPT.dataset,'_','\_')});

% set axis
set(gca, 'Xlim',[min(OPT.polygon(:,1))- 10000 max(OPT.polygon(:,1)) + 10000]);
set(gca, 'Ylim',[min(OPT.polygon(:,2))- 10000 max(OPT.polygon(:,2)) + 10000]);
set(gca,'fontsize',8);
box on

% save figure
print(fh,'-dpng',[OPT.workdir filesep 'results' filesep 'timewindow = ' num2str(OPT.searchinterval) filesep 'ref=' num2str(OPT.min_coverage(n)) filesep strrep(results.polyname,'_',' ') '_sandbalanceplot']);
close(fh)

%% Volume development plot
fh = figure('tag','VolPlot'); clf;

nameInfo='OpenEarth - Volume development plot';
set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
hold on

% plot results method 1 (as line)
plot(Volumes{1}(:,1), Volumes{1}(:,2) - Volumes{1}(1,2),'color','b','linewidth',2,'marker','o','MarkerFaceColor','b');

% plot results method 2 (as  stippelline)
plot(Volumes{2}(:,1), Volumes{2}(:,2) - Volumes{2}(1,2),'color','b','linewidth',2,'marker','o','MarkerFaceColor','w','linestyle','--');

datetick
grid
box on

% set text
title({['Volume development for ' strrep(results.polyname,'_',' ')]; strrep(OPT.dataset,'_','\_')},'fontsize',8);
legend(['Method 1: based on data points covered by target year and reference year (' datestr(OPT.reference_year) ')'],'Method 2: based on data points covered in all years','location','SouthOutside');

% set axis
xlabel('Time [years]','fontsize',8);ylabel('Volume [m^3]','fontsize',8);
set(gca,'fontsize',8);

% save figure
print(fh,'-dpng',[OPT.workdir filesep 'results' filesep 'timewindow = ' num2str(OPT.searchinterval) filesep 'ref=' num2str(OPT.min_coverage(n)) filesep strrep(results.polyname,'_',' ')]);
close(fh)

warning(warningstate)

%% EOF