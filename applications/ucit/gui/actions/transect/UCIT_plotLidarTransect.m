function UCIT_plotLidarTransect(d)
%PLOTLIDARTRANSECT   routine plots transect from structure d
%
% input:
%   d = basic UCIT datastructure for transects
%
% output:
%   function has no output
%
%   See also getPlot

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
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

clearvars -global

if nargin==0

    guiH=findobj('tag','UCIT_mainWin');
    d=get(guiH,'userdata');

    datatypes = UCIT_getDatatypes;
    url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
    url = url{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
    d = readLidarDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'),...
        UCIT_getInfoFromPopup('TransectsTransectID'),datenum(UCIT_getInfoFromPopup('TransectsSoundingID'))-datenum(1970,1,1));

    if all(d.xi == d.xi(1))
        warndlg('There is no transect data for the selected date  - please select another date (soundingID)!')
    else
        US_getPlot(d);
    end
end

function US_getPlot(d, axisNew)
%---------------------------------------------------------------------%

%% preprocess input to fit below routines
try
    if isnumeric(d.area)
        d.area=num2str(d.area);
    end
end

%% prepare figure window
try
    guiH=findobj('tag','UCIT_mainWin');
end

if get(findobj(guiH,'tag','UCIT_holdFigure'),'value')==0&&~isempty(findobj('tag','plotWindow_US'))
    fh=findobj('tag','plotWindow_US');
    figure(fh)
    ah=gca;

    if nargin == 1
        axisNew = axis(gca);
        set(fh,'UserData',d);

        hold off;

        %plot entire jarkus profiel
        if ~isempty(d.ze)
           
            ph1=plot(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),'color','b','linestyle','none','marker','diamond','MarkerFaceColor','b','Markersize',4);
            
            z = d.ze(~isnan(d.ze));
%             % make grey patch
%             x = d.xe(~isnan(d.ze));
%             patch([x(1); x; x(end)],[min(z)-1; z; min(z)-1],[0 0 0],'LineStyle','none','FaceAlpha',0.1)
            
            hold on

            xlabel('Distance to profile origin [m]');
            ylabel('Height [m]');
            RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' datestr(str2num(d.year)+datenum(1970,1,1))];
            title(RaaiInformatie);set(fh,'name',RaaiInformatie);
            set(gca, 'xlim',[min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze)))]);
            set(gca, 'ylim',[min(z)-1 20]);

            box on;grid;
            axis(axisNew)
            minmax = axis;
            handles.XMaxRange = [minmax(1) minmax(2)];
            handles.YMaxRange = [minmax(3) minmax(4)];
            guidata(fh,handles);

        end
    end
else
    try
        fh=figure('tag','plotWindow_US');
        figure(fh);
        RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' datestr(str2num(d.year)+datenum(1970,1,1))];
        set(fh,'Name', RaaiInformatie,'NumberTitle','On','Units','normalized');

        ah=axes;

        set(fh,'UserData',d);

        hold on;

        %plot
        if ~isempty(d.ze)
            ph1 = plot(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),'color','b','linestyle','none','marker','diamond','MarkerFaceColor','b','Markersize',4);hold on

            z = d.ze(~isnan(d.ze));
            % make grey patch
%             x = d.xe(~isnan(d.ze));
%             patch([x(1); x; x(end)],[min(z)-1; z; min(z)-1],[0 0 0],'LineStyle','none','FaceAlpha',0.1)
            
            xlabel('Distance to profile origin [m]');
            ylabel('Height [m]');
            RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: '  datestr(str2num(d.year)+datenum(1970,1,1))];
            title(RaaiInformatie);
            set(gca, 'xlim',[min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze)))]);
            set(gca, 'ylim',[min(z)-1 20]);

            box on;grid;
            minmax = axis;
            handles.XMaxRange = [minmax(1) minmax(2)];
            handles.YMaxRange = [minmax(3) minmax(4)];
            guidata(fh,handles);

        end
    end
end

%% add USGS meta information
try
    plot(d.shorePos, d.MHW,'go','markersize',10,...
        'markerEdgeColor', 'g','markerFaceColor','g');
    line([min(d.xe(d.xe~=-9999)) max(d.xe(d.xe~=-9999))],[d.MHW d.MHW],'color','k');
    plot(d.xe(~isnan(d.regression)),d.ze(~isnan(d.regression)),'or');

    % the following will only work when the correct beach slope is used,
    % updateLidarGrid.m was changed and the netcdf files need to be re-made
%     % the next block of code was added by afarris@usgs.gov 2009oct09
%     % I want to add the regression line to the plot.  I use the eqn. 
%     % m= (y1-y2)/(x1-x2)
%     % where (x1,y1) is the shoreline point and x2 is the x pos. of the most
%     % seaward data point, we solve the eqn for y at this x.
%     % Similarly we solve for the height of the regression at the most landward
%     % data point.
%     m = d.slope;
%     x1 = d.shorePos;
%     y1 = d.MHW;
%     junk = d.xe(~isnan(d.regression));
%     % junk is same size as d.xe, pts NOT in regression are = -9999
%     f=find(junk~=-9999);
%     x2 = max(junk(f));
%     x3 = min(junk(f));
%     y2 = y1 - m*(x1-x2);
%     y3 = y1 - m*(x1-x3);
%     plot([x2 x3],[y2 y3],'g')
end

box on

handles = guidata(fh);

fh=findobj('tag','plotWindow_US');
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);

if ~isempty(findobj('tag','mapWindow'))
    UCIT_showTransectOnOverview
end



