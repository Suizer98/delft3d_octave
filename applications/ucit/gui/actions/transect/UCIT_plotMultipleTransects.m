function plotMultipleTransects(d,years)
%plotMultipleTransects   routine plots transect data of multiple years
%
% input:
%   d = basic McDatabase datastructure for transects
%   years = array of selected years (max 10)
%
% output:
%   plot of crosssections for selected years
%
% syntax:
%           plotMultipleTransects(d,[2001:2005]);
%
%   See also getPlot
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

datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
[d] = UCIT_getLidarMetaData;

fh = findobj('tag','plotWindow_multiple');

if isempty(fh)
    fh = figure('tag','plotWindow_multiple'); set(fh,'visible','off');
else
    figure(fh); 
    years = datenum(get(findobj('tag','plotWindow_multiple'),'userdata')) - datenum(1970,1,1);
    clf;
end

if nargin < 2
    [check]=UCIT_checkPopups(1, 4);
    if check == 0
        return
    end

    if strcmp(UCIT_getInfoFromPopup('TransectsTransectID'),'Transect ID (load first)')
        error('Select datatype, area and transect first');
    end

    if ~exist('years')
        years   =   SelectYears(d);
    end

end

colors={'b',[0.2 0.6 0],'k',[0.5 1 1],'m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5]};


RaaiInformatie=['UCIT - Transect view -  Area: ' UCIT_getInfoFromPopup('TransectsArea') '  Transect: ' UCIT_getInfoFromPopup('TransectsTransectID')];
set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
ah=axes;
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);clf
title(RaaiInformatie);
hold on;

% Add cross-sections of selected years

if length(years)>10
    warning('Maximum number of selected years is 10')
    years=years(1:10);
end

counter = 1;

for i=1:length(years)
    try
        url = url{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
        transect = readLidarDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'), UCIT_getInfoFromPopup('TransectsTransectID'),years(i));
    end
    if exist('transect') & ~all(isnan(transect.zi))
        if ~isempty(transect)
            plotLine(transect);hold on;
            
            a = findobj('tag',['ph' num2str(transect.year)]);
            set(a,'color',colors{counter},'marker','diamond','linestyle','none','Markersize',4,'MarkerFaceColor',colors{counter});
            legendtext{counter} = datestr(str2double(transect.year) + datenum(1970,1,1));
            counter = counter + 1;
            d = transect;clear transect
        end
    else
        warning(['Year ', datestr(years(i) + datenum(1970,1,1)), ' was not found in the database']);
    end
end
legend(legendtext);
grid;
set(fh,'visible','on');
%% add USGS meta information
try
    line([min(d.xe(d.xe~=-9999)) max(d.xe(d.xe~=-9999))],[d.MHW d.MHW],'color','k');
    plot(d.shorePos, d.MHW,'go','markersize',10,'markerEdgeColor',...
        'g','markerFaceColor','g');
end

set(fh,'userdata',legendtext);
set(fh,'visible','on');


function plotLine(d)

if isempty(d)
    error('A selected year was not found in the database')
end

% Prepare figure window
try
    guiH=findobj('tag','UCIT_mainWin');
end

% Plot profile

if ~isempty(d.ze)

    try
        ph=plot(d.xi(~isnan(d.ze)),d.zi(~isnan(d.ze)),'k','linewidth',1.5);
    catch
        ph=plot(d(1).xi(~isnan(d(1).ze)),d(1).zi(~isnan(d(1).ze)),'k','linewidth',1.5);
    end
    set(ph,'tag',['ph' num2str(d.year)]);

end

% Figure properties

xlabel('Distance to profile origin [m]');
ylabel('Height [m]');
try
    set(gca, 'xlim',[min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze)))]);
    set(gca, 'ylim',[-1 20]);
end

% set(gca,'XDir','reverse');
box on
minmax = axis;
handles.XMaxRange = [minmax(1) minmax(2)];
handles.YMaxRange = [minmax(3) minmax(4)];



function years  =   SelectYears(d)

% Get available years from metadata
AvailableYears   =   datestr(d.year+datenum(1970,1,1));

v = listdlg('PromptString','Select dates:',...
    'SelectionMode','multiple',...
    'ListString',AvailableYears);

AvailableYears   = d.year;

years   =   AvailableYears(v);
