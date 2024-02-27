function UCIT_getCrossSection
%UCIT_GETCROSSSECTION   allows use to draw a line over a plotted grid to which the data from that grid is interpolated for multiple years
%
%   syntax:
%       UCIT_getCrossSection()
%
%   input:
%       function has no input
%
%   output:
%       function has no output
%
%   See also UCIT_plotDataInPolygon, grid_2D_orthogonal

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%
%       Ben de Sonneville
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
    fhs = findobj('tag','gridPlot');
    fh = figure(fhs(1)); figure(fh);
end
   
   curdir=pwd;
   colors={'b',[0.2 0.6 0],'k','c','m','r', [0.6 0.4 0],[0.2 0.4 0 ], [0.5 0.5 0.5], [1 0.5 0.5],'y',  [0.25 0.5 0.5],[0.5 0 0.5] ,[1 0.5 0.25],[0.5 1 0.5],[0.2 0 1],[1 0.5 1],[0.5 0.5 0.75],rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]),rand([1,3]) };
   
%% Specify line

   try delete(findobj(fh,'tag','crs_line'));  end

   disp('Please click a line from which to select data ...')
   input= ginput(2);
   lh   = line(input(:,1),input(:,2));
   set(lh,'color','g','linewidth',2,'tag','crs_line');
   xi   = input(:,1);
   yi   = input(:,2);
   xi   = linspace(xi(1),xi(2),1000);
   yi   = linspace(yi(1),yi(2),1000);
   polygon = ([min(xi)-1000 min(yi)-1000;max(xi)+1000 min(yi)-1000;max(xi)+1000 max(yi)+1000; min(xi)-1000 max(yi)+1000;min(xi)-1000 min(yi)-1000]);

%% Get user input

   year1 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')) ...
     - 30*(str2double(                UCIT_getInfoFromPopup('GridsInterval'))),10));
   year2 = str2double(datestr(datenum(UCIT_getInfoFromPopup('GridsName')),10));
   years = [year1 : year2];

%% Set up figure

   fn=findobj('tag', 'crosssectionView');
   if isempty(fn)
       nameInfo = ['UCIT - Crosssection view'];
       fn=figure('tag','crosssectionView','visible','off'); clf; ah=axes;
       set   (fn,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
       UCIT_prepareFigureN(0, fn, 'UR', ah);
   end

%% Find data for selected polygon for selected years

d    = UCIT_getMetaData(2);

teller = 0; teller2 = 0;emptyyears = [];

% show waitbar
% cbh = waitbar(0,'Please wait ...');
% set(cbh, 'tag', 'wb')

for xx = 1:length(years)

    figure(fh);
    [X, Y, Z] = grid_orth_getDataInPolygon(...
    'dataset'       , d.catalog, ...
    'urls'          , d.urls, ...
    'x_ranges'      , d.x_ranges, ...
    'y_ranges'      , d.y_ranges, ...
    'tag'           , datatype, ...
    'starttime'     , datenum(years(xx),12,31), ...
    'searchinterval', -365.25, ... % this call is inside a year-loop
    'datathinning'  , 1,...        % line data do not need thinning
    'cellsize'      , d.cellsize,...
    'plotresult'    , 0,...
    'polygon'       , polygon,...  % this functionality is also inside grid_orth_getDataInPolygon
    'warning'       , 0);          % prevent zillions of warnings for each one year in this loop is empty

    try delete(findobj('tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly

    dx=xi(end)-xi(1);
    dy=yi(end)-yi(1);
    lengthc=sqrt(dx^2+dy^2);
    stepsize=lengthc/size(xi,2);
    xl=[0:stepsize:(size(xi,2)-1)*stepsize];
    zl(:,xx)=interp2(X,Y,Z,xi,yi);
    if all(isnan(zl(:,xx)))
        id(xx) = 0;
    else
        id(xx) = 1;
    end
%      waitbar(xx/length(years), findobj('tag','wb'), 'Extracting data from nc files ...')
end

% close(cbh)

years_with_data = years(id==1);
years_with_data = sort(years_with_data); % old years are blue, recent years are red
col     = jet(length(years_with_data)); % use color codes of Claire

for xx = 1:length(years)
    
    %% plot data or warn that no data is available
    figure(fn);
    if sum(~isnan(zl(:,xx)))>0
        teller=teller+1;
        figure(fn);set(fn,'visible','on');
        plot(xl,zl(:,xx),'color',col(teller,:),'linewidth',2);hold on;
        legendtext{teller}=([num2str(years(xx))]);

    else
        teller2=teller2+1;
        emptyyears{teller2}=num2str(years(xx));
        warning(['Year ', num2str(years(xx)),' has no data for the crosssection']);
    end
end

%% add figure properties

if exist('legendtext')
    figure(fn);
    legend(legendtext,'fontsize',8);grid;
    title ('Bed level of requested crossection','fontsize',8)
    xlabel('Local x direction','fontsize',8);
    ylabel('Bed level (m)','fontsize',8);
    set   (gca,'fontsize',8);

    disp  ([]);
    disp  (['Years without data are: '])
    for yy=1:length(emptyyears)
        disp([emptyyears{yy}]);
    end

else
    warning(['No data was found']);
    close(fn)
end

warning(warningstate)

%% EOF