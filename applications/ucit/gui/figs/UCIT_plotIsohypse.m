function UCIT_plotIsohypse(OPT, IsoOverview, polyname)
%UCIT_PLOTISOHYPSE  plots results of sand balance computation
%
%       UCIT_plotSandBalance(OPT, results)
%
%
%
%
%   Output: plots in a selected result directory
%
%
%   Example:
%
%
%
% See also: UCIT_getSandBalance

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

warningstate = warning;
warning off

%% Overview plot of polygon and used datapoints for method 2
nameInfo = ['UCIT - used data points for method 2'];
fh = figure('tag','dpPlot'); clf; ah=axes;
set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);
UCIT_plotLandboundary(OPT.ldb,'none')
hold on;

% get meta(data)
load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep polyname '_' num2str(OPT.inputyears(1),'%04i') '_1231.mat']);
d.id = OPT.id*2;
d.id((OPT.id==0)) = nan;

% plot data
pcolorcorcen(d.X,d.Y,d.id*2);view(2);shading interp;

% plot used polygon
ph = plot(OPT.polygon(:,1), OPT.polygon(:,2),'color','k','tag','polygon','linewidth',1);

% text
title(['Used data points for method 2 ' strrep(polyname,'_',' ') ' (' OPT.datatypeinfo ')'],'fontsize',8);

% set axis
box    on
axis   equal
set   (gca,'fontsize', 8 );
ylabel('Northing [m]');
xlabel('Easting [m]');
% derive x and y limits to be applied to the axes
xlim = [min(d.X(1,[1 end])) max(d.X(1,[1 end]))];
ylim = [min(d.Y([1 end],1)) max(d.Y([1 end],1))];

set(gca,...
    'Xlim', xlim,...
    'Ylim', ylim);
% set   (gca,'Xlim',[d.X(1,1) d.X(1,end)]);
% set   (gca,'Ylim',[d.Y(end,1) d.Y(1,1)]);
tickmap('xy');

% save figure
print(fh,'-dpng',['results' filesep 'timewindow = ' num2str(OPT.timewindow) filesep 'ref=' num2str(OPT.min_coverage) filesep polyname '_used_data_points_method_2']);


%% Isohypse plot

% set up figure
nameInfo=['UCIT - Isohypse plot'];
fh = figure('tag','IsoPlot'); clf; ah=axes;
set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UR', ah);
hold on

%% use color codes of Claire
col     = jet(length(OPT.inputyears)); 
counter = 1;
years     = sort(OPT.inputyears); % old years are blue, recent years are red

for i = 1 : length(OPT.inputyears)
    % plot results method 2 (as line)
    ph = plot(IsoOverview(2,i).area,IsoOverview(2,i).height,'color','b','linewidth',2'); 
    set(ph,'color',col(i,:));
    legendtext{counter}=([num2str(OPT.inputyears(i))]); 
    counter = counter + 1;
end

legend(legendtext);
 
grid;
title (['Isohypse for ' strrep(polyname,'_',' ') ' (' OPT.datatypeinfo ') (Method 2: based on data points covered by all years)'],'fontsize',8)
xlabel('Area (m^2)','fontsize',8);
ylabel('Height (m)','fontsize',8);
set(gca,'fontsize',8);

% save figure
print(fh,'-dpng',['results' filesep 'timewindow = ' num2str(OPT.timewindow) filesep 'ref=' num2str(OPT.min_coverage) filesep polyname '_isohypse' ]);

warning(warningstate)

%% EOF
