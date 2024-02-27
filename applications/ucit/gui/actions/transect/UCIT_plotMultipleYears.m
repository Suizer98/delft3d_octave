function plotMultipleYears(d,years)
%plotMultipleYears   routine plots multiple years of structure d
%
% input:
%   d = basic McDatabase datastructure for transects
%   years = array of selected years (max 10)
%
% output:
%   plot of crosssections for selected years
%
% syntax:
%           plotMultipleYears(d,[2001:2005]);
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

datatypes         = UCIT_getDatatypes;
ind               = strmatch(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names);
TransectsDatatype = datatypes.transect.datatype{ind};
url               = datatypes.transect.urls{ind};
[d] = UCIT_getMetaData(1); % 1 means transect

if nargin<2
    [check]=UCIT_checkPopups(1, 4);
    if check == 0
        return
    end

    if strcmp(UCIT_getInfoFromPopup('TransectsTransectID'),'Transect ID (load first)')
        error('Select datatype, area and transect first');
    end

    %     d       =   readTransectData(UCIT_DC_getInfoFromPopup('TransectsDatatype'),UCIT_DC_getInfoFromPopup('TransectsArea'),UCIT_DC_getInfoFromPopup('TransectsTransectID'));
    
    years   =   SelectYears(d);
    

end


% Create empty base figure

fh=figure('tag','plotWindow');
RaaiInformatie=['UCIT - Transect view -  Area: ' UCIT_getInfoFromPopup('TransectsArea') '  Transect: ' UCIT_getInfoFromPopup('TransectsTransectID') ];
set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
ah=axes;
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);clf
title(RaaiInformatie);
hold on;

% Add cross-sections of selected years

col     = jet(length(years)); % use color codes of Claire
counter = 1;
years     = sort(years); % old years are blue, recent years are red

for i=1:length(years)

    try
        transect = jarkus_readTransectDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'),UCIT_getInfoFromPopup('TransectsTransectID'),years(i));
        transect.zi = squeeze(transect.zi);
        transect.ze = squeeze(transect.ze);
    end

    if exist('transect')
        if ~isempty(transect)
            plotLine(transect);hold on;
            a=findobj('tag',['ph' num2str(transect.year)]);
            b=findobj('tag',['ph' num2str(transect.year)]);
%             set(a,'color',colors{counter});
%             set(b,'color',colors{counter}); 
            set(a,'color',col(counter,:));
            set(b,'color',col(counter,:));
            clear a b;
            legendtext{counter} = num2str(transect.year);
            counter = counter + 1;
            clear transect
        end
    else
        warning(['Year ', num2str(years(i)), ' was not found in the database']);
    end
end
legend(legendtext);
grid;


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

xlabel('Cross shore distance [m]');
ylabel('Elevation [m to datum]');
try
axis([min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze))) -35 35]);
end
set(gca,'XDir','reverse');
box on
minmax = axis;
handles.XMaxRange = [minmax(1) minmax(2)];
handles.YMaxRange = [minmax(3) minmax(4)];


function years  =   SelectYears(d)

% Get available years from metadata
AvailableYears   =   round(d.year/365+1970);
AvailableYears   = num2str(sort(AvailableYears,'descend'));
 
% tmp=DBGetTableEntryRaw('transect','datatypeinfo',UCIT_DC_getInfoFromPopup('TransectsDatatype'),'area',UCIT_DC_getInfoFromPopup('TransectsArea'),'transectID',UCIT_DC_getInfoFromPopup('TransectsTransectID'));

v = listdlg('PromptString','Select years:',...
           'SelectionMode','multiple',...
              'ListString',AvailableYears);

AvailableYears   = str2num(AvailableYears);
years            =         AvailableYears(v);
