function UCIT_plotDifferenceMap(datatype1,year1,targetmonth1,datatype2,year2,targetmonth2,monthsmargin,thinning,polygon)
% UCIT_PLOTDIFFERENCEMAP  This script makes a difference plot for a polygon and two selected years
%
%
%   Syntax:     UCIT_makeDifferencePlot
%
%   Input:      in UCIT GUI
%
%
%
%   Output:
%
%
%
%
%   See also grid_orth_getDataInPolygon

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

warningstate = warning;
warning off

OPT.polygon         = [];

datatype = UCIT_getInfoFromPopup('GridsDatatype');

%% Select in either grid plot or grid overview plot
mapW = findobj('tag','gridPlot');
if isempty(mapW)
    if isempty(findobj('tag','gridOverview')) %|| ~any(ismember(get(axes, 'tag'), {datatype}))
        fh = UCIT_plotGridOverview(datatype,'refreshonly',0);
    else
        fh = UCIT_plotGridOverview(datatype,'refreshonly',1);
    end
else
    fh = figure(findobj('tag','gridPlot')); figure(fh);
end

d    = UCIT_getMetaData(2);

%% select or load polygon
try delete(findobj(ah,'tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly
try delete(findobj(fh,'tag','isohypse_polygon'));  end

% if no polygon is available yet draw one
if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    jjj = menu({'Zoom to your place of interest first.',...
        'Next select one of the following options.',...
        'Finish clicking of a polygon with the <right mouse> button.'},...
        '1. click a polygon',...
        '2. click a polygon and save to file',...
        '3. load a polygon from file');
    
    if jjj<3
        % draw a polygon using polydraw making sure it is tagged properly
        disp('Please click a polygon from which to select data ...')
        [x,y] = polydraw('g','linewidth',2,'tag','selectionpoly');
        
    elseif jjj==3
        % load and plot a polygon
        [fileName, filePath] = uigetfile({'*.ldb','Delft3D landboundary file (*.ldb)'},'Pick a landboundary file');
        [x,y]=landboundary('read',fullfile(filePath,fileName));
        x = x';
        y = y';
    end
    
    % save polygon
    if jjj==2
        [fileName, filePath] = uiputfile({'*.ldb','Delft3D landboundary file (*.ldb)'},'Specifiy a landboundary file',...
            ['polygon_',datestr(now)]);
        landboundary('write',fullfile(filePath,fileName),x,y);
    end
    
    % combine x and y in the variable polygon and close it
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
    
else
    
    x = OPT.polygon(:,1);
    y = OPT.polygon(:,2);
    
end


%% select years
years = [1926:str2double(datestr(now,10))];
years = sort(years,'descend');
for i = 1:length(years)
    str{i} = num2str(years(i));
end
v = listdlg('PromptString','Select two years:',...
           'SelectionMode','multiple',...
              'ListString',str);
if length(v) > 2
    errordlg('Please select only two years');
end
year1 = years(v(1));
year2 = years(v(2));

% show waitbar
% cbh = waitbar(0,'Please wait ...');
% set(cbh, 'tag', 'wb')


%% get data of first year
[d.X, d.Y, d1.Z, d1.Ztime] = grid_orth_getDataInPolygon(...
    'dataset'       , d.catalog, ...
    'urls'          , d.urls, ...
    'x_ranges'      , d.x_ranges, ...
    'y_ranges'      , d.y_ranges, ...
    'tag'           , datatype, ...
    'starttime'     , datenum([year1 12 31]), ...
    'searchinterval', -365/12*str2double(UCIT_getInfoFromPopup('GridsInterval')), ...
    'datathinning'  , str2double(UCIT_getInfoFromPopup('GridsSoundingID')),...
    'cellsize'      , d.cellsize,...
    'plotresult'    , 0,...
    'polygon'       , OPT.polygon);  % this functionality is also inside grid_orth_getDataInPolygon


% waitbar(0.4, findobj('tag','wb'), 'Extracting data from nc files ...')

%% get data of second year
[d.X, d.Y, d2.Z, d1.Ztime] = grid_orth_getDataInPolygon(...
    'dataset'       , d.catalog, ...
    'urls'          , d.urls, ...
    'x_ranges'      , d.x_ranges, ...
    'y_ranges'      , d.y_ranges, ...
    'tag'           , datatype, ...
    'starttime'     , datenum([year2 12 31]), ...
    'searchinterval', -365/12*str2double(UCIT_getInfoFromPopup('GridsInterval')), ...
    'cellsize'      , d.cellsize,...
    'datathinning'  , str2double(UCIT_getInfoFromPopup('GridsSoundingID')),...
    'plotresult'    , 0,...
    'polygon'       , OPT.polygon);  % this functionality is also inside grid_orth_getDataInPolygon

% waitbar(0.8, findobj('tag','wb'), 'Extracting data from nc files ...')

%% Subtract years
dd.Z = (d1.Z - d2.Z);

% close(cbh)
%% Plot results
fh = figure('tag','gridPlot');clf;
ah = axes;
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);
UCIT_plotLandboundary(d.ldb,'none'); % plot land boundary

surf(d.X,d.Y,dd.Z);shading interp;view(2);hold on;
cm = colormap(['erosed']);
caxis([-3 3]);
c  = colorbar('vert');
axis   equal;
box    on
% thr=-20:0.5:20; 
thr = [-50 -40 -30 -20 -10 -5 0 5];
[c,h]=contour(d.X,d.Y,d1.Z,[thr],'k');
set   (fh,'Units','normalized');
set   (fh,'Position',UCIT_getPlotPosition('UR',1))
set   (fh,'Name','UCIT - Difference Map','NumberTitle','Off','Units','characters','visible','on');
title([num2str(year1) '-' num2str(year2)]);
% derive x and y limits to be applied to the axes
xlim = [min(d.X(1,[1 end])) max(d.X(1,[1 end]))];
ylim = [min(d.Y([1 end],1)) max(d.Y([1 end],1))];
 set(gca,...
        'Xlim', xlim,...
        'Ylim', ylim);
%set(gca,'Xlim',[d.X(1,1) d.X(1,end)]);
%set(gca,'Ylim',[d.Y(end,1) d.Y(1,1)]);
set(gca,'fontsize',8);
tickmap('xy');
warning(warningstate)

%% EOF   