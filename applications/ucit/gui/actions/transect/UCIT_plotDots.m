function UCIT_plotDots
%PLOTDOTS   this routine displays LIDAR dot plots on an overview figure
%
% This routine displays LIDAR dot plots on an overview figure.
%
% input:
%    function has no input
%
% output:
%    function has no output
%
% see also ucit, displayTransectOutlines

% afarris@usgs.gov 2010Feb08 takes already selected transects and makes  
% a colored dots plot (prev. version allowed user to select the transects) 
% based on the code UCIT_plotPointsInPolygon.m written by Ben:
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


if ~isempty(get(findobj('Tag','beginTransect'),'value'))

    % get data from userdata mapWindow
    fh = findobj('tag','UCIT_mainWin');
    d=get(fh,'UserData');

    % get begin and endtransect from d
    beginTransect = d.transectID(get(findobj('Tag','beginTransect'),'value'));
    endTransect = d.transectID(get(findobj('Tag','endTransect'),'value'));
    id1 = get(findobj('Tag','beginTransect'),'value');
    id2 = get(findobj('Tag','endTransect'),'value');

    % if the selected end transect is smaller than the begin transect reverse the two
    if str2double(beginTransect) > str2double(endTransect)
        x=findobj('Tag','beginTransect');
        t=get(findobj('Tag','beginTransect'),'value');
        set(x,'value',get(findobj('Tag','endTransect'),'value'));
        y=findobj('Tag','endTransect');
        set(y,'value',t);
        beginTransect = d(get(findobj('Tag','beginTransect'),'value')).transectID;
        endTransect = d(get(findobj('Tag','endTransect'),'value')).transectID;
        id2 = get(findobj('Tag','beginTransect'),'value');
        id1 = get(findobj('Tag','endTransect'),'value');
        id = (id1|id2);
    end
end

% 'id' is a vector of ones and zeros
% first make id to have the same number of rows as there are transects 
% (all values 0)
temp = d.transectID;
id = zeros(size(temp));

% now make the values 1 for transects that were chosen:
id(id1:id2) = 1;

datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
url = url{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};

% get data
crossShoreCoordinate = nc_varget(url, 'cross_shore');
time = nc_varget(url, 'time');
ids = find(id>0);
time_id = find(time == datenum(UCIT_getInfoFromPopup('TransectsSoundingID'))-datenum(1970,1,1));

x = nc_varget(url, 'x',         [time_id-1,ids(1)-1,0], [1,ids(end)-ids(1),length(crossShoreCoordinate)]);
y = nc_varget(url, 'y',         [time_id-1,ids(1)-1,0], [1,ids(end)-ids(1),length(crossShoreCoordinate)]);
z = nc_varget(url, 'altitude',  [time_id-1,ids(1)-1,0], [1,ids(end)-ids(1),length(crossShoreCoordinate)]);
shoreX = nc_varget(url, 'shore_east',[ids(1)-1],[ids(end)-ids(1)]);
shoreY = nc_varget(url,'shore_north',[ids(1)-1],[ids(end)-ids(1)]);

% prepare info for coloring
% this section of code was added by afarris@usgs.gov on 2009oct13
allMHW = d.mean_high_water(ids);
% There is a MHW value for each transect.  Usually all transects will have
% the same MHW value.  Occasionally this will not be true.  Ideally this
% code would handle these cases intellegently. 
m1=allMHW(1);
m2=allMHW(end);
if m1 ~= m2
    % FIXME handle mutlitple MHW zones better
end    
%  Here just I use the first value
MHW = allMHW(1);


dz     = .5/8;
zmin_a = MHW - (19 * dz);
zmax_a = MHW + (44 * dz);

if all(z == z(1))
    warndlg('There is no transect data for the selected date  - please select another date (soundingID)!')
else
    %% prepare figure
    % create figure and axis
    close(findobj('tag','Dotfig'));
    fh=figure('tag','Dotfig');clf;
    set(fh,'visible','off')
    RaaiInformatie = [ 'UCIT - Top view - Area : ' UCIT_getInfoFromPopup('TransectsArea') ' Transects ' d.transectID{find(id==1,1,'first')} '-' d.transectID{find(id==1,1,'last')} ' Time: ' UCIT_getInfoFromPopup('TransectsSoundingID')];
    set(fh,'Name',RaaiInformatie,'NumberTitle','Off','Units','normalized');
    ah=axes;hold on;box on;

    % use prepare UCIT_prepareFigure to give it the UCIT look and feel
    figure(findobj('tag','Dotfig')) % make the figure current is apparently needed to actually make the repositioning statement work
    [fh]=UCIT_prepareFigureN(0, fh, 'UR', ah);set(fh,'visible','off')

    figure(findobj('tag','Dotfig')) % make the figure current is apparently needed to actually make the repositioning statement work
    set(findobj('tag','Dotfig'),'position',UCIT_getPlotPosition('UR'));

    % plot landboundary
    % afarris@usgs.gov left this out (on 2009oct16) becasue it seemed to
    % mess up the labelling of the colorbar 
%     UCIT_plotLandboundary(d.datatypeinfo{1},0);

    % prepare colormap info for cdots_amy function
    load colormapMHWjump20
    
    % plot data (NB: coloring depends on the Mean High Water info)
    UCIT_cdots_amy(x,y,z,zmin_a,zmax_a,cmapMHWjump20)

    %% plot shoreline position
    plot(shoreX,shoreY,'o','linewidth',2,'markerEdgeColor',...
        'k','markerFaceColor','w','markerSize',6);

    %% Set figure properties

    view(2);
    xlabel('Easting (m, UTM)','fontsize',9);
    ylabel('Northing (m, UTM)','fontsize',9);
    axis equal
    dx=100;
    maxx=max(max(x(x~=-9999)));
    minx=min(min(x(x~=-9999)));
    maxy=max(max(y(y~=-9999)));
    miny=min(min(y(y~=-9999)));
    axis([(minx) - dx (maxx)+ dx (miny)- dx (maxy)+ dx] );

    %% make colorbar
    % updated by afarris@usgs.gov on 2009oct16 to fix labels on colobar
    zinc=(zmax_a - zmin_a)/64;
    % the ticks will be at
    yt = [10 20 30 40 50 60];
    % calculate the labels for these ticks
    b=1;
    for a= yt
        tmp = zmin_a + a*zinc; 
        ytl_string(b) = {num2str(tmp,'%3.1f')};
        b=b+1;
    end
    % the second label will always be at MHW, I want users to know this
    ytl_string{2}= 'MHW';
    % now make colorbar
    cb = colorbar('ytick',yt,'yticklabel',ytl_string);
    title(cb,'Height (m)')
    colormap(cmapMHWjump20);

    %% make figure visible only after all is plotted
    set(fh,'visible','on')
    figure(findobj('tag','Dotfig')) % make the figure current is apparently needed to actually make the repositioning statement work
    set(findobj('tag','Dotfig'),'position',UCIT_getPlotPosition('UR'));
end