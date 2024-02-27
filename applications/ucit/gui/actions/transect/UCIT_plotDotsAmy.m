function UCIT_plotDotsAmy
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

% afarris@usgs.gov 2010Feb08: Takes already selected transects and makes  
% a colored dots plot (prev. version allowed user to select the transects) 
% afarris wrote quite a bit of this program and the gui is set up
% differently than the UCIT gui, this is b/c this is how I know how to do it.  
% Maybe someday I'll go back and use their method.
%
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
%         beginTransect = d(get(findobj('Tag','beginTransect'),'value')).transectID;
%         endTransect = d(get(findobj('Tag','endTransect'),'value')).transectID;
        id2 = get(findobj('Tag','beginTransect'),'value');
        id1 = get(findobj('Tag','endTransect'),'value');
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
shoreNums = nc_varget(url,'id',[ids(1)-1],[ids(end)-ids(1)]);

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
    
    % start setting up handles structure that is needed for the gui.
    handles.shoreX = shoreX;
    handles.shoreY = shoreY;
    handles.shoreNums = shoreNums;
    
    %% prepare figure
 
    
    % create figure and axis
    close(findobj('tag','Dotfig2'));
    fhandle=figure('tag','Dotfig2');clf;
    % afarris@usgs.gov 2010Feb16 I got a little confused about what fh is.
    % I still am not sure whether it is a tag or handle.  I think up to
    % this point it was the handle of the main figure.  After the following
    % line it is the handle of the current figure and a little later it I
    % think becomes the tag of the current figure.  I am not sure. I set
    % fhandle to be the handle of the figure (since that is what I needed)
    % but then the code crashed, so I put in the following line.  The code
    % now works.
    fh=fhandle;
    set(fhandle,'visible','off')
    RaaiInformatie = [ 'UCIT - Top view - Area : ' UCIT_getInfoFromPopup('TransectsArea') ' Transects ' d.transectID{find(id==1,1,'first')} '-' d.transectID{find(id==1,1,'last')} ' Time: ' UCIT_getInfoFromPopup('TransectsSoundingID')];
    set(fh,'Name',RaaiInformatie,'NumberTitle','Off','Units','normalized');

    % prepare axes:
    ahandle = axes('parent',fhandle,'position',[0.13 0.25 0.775 0.67]);
    
    % use prepare UCIT_prepareFigure to give it the UCIT look and feel
    fh=figure(findobj('tag','Dotfig2')) 
    % make the figure current is apparently needed to actually make the repositioning statement work
    [fh,ah] = UCIT_prepareFigureN(2, fh, 'UL', ahandle);
    % fh is the 'tag' of the figure, which is what Ben uses, I am more used
    % to handles, the handle of the figure is fhandle
    
    set(fhandle,'visible','off')
    set(findobj('tag','Dotfig2'),'position',UCIT_getPlotPosition('UL'));

    % prepare colormap info for cdots_amy function
    load colormapMHWjump20
       
    % plot data (NB: coloring depends on the Mean High Water info)
    UCIT_cdots_amy(x,y,z,zmin_a,zmax_a,cmapMHWjump20,ahandle)

    %% plot shoreline position
    hold on
    box on
    plot(shoreX,shoreY,'o','linewidth',2,'markerEdgeColor',...
        'k','markerFaceColor','w','markerSize',6);
    handles.axes = ahandle;

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
    
    %% add text and buttons
    handles.figure = fhandle;
    set(fhandle,'units','normalized')
    % add explanatory text:
    htext = uicontrol(fhandle,'Style','text','units','normalized',...
        'String','Colored dots are the height of transect data.  White circles with blcak outlines are the shoreline positions. They should occur at the color contrast yellow/blue.',...
          'Position',[.01 .01 .3 .15],'backgroundcolor',[1 1 1]) ;
      
    % add text explaining button
    htext = uicontrol('Style','text','units','normalized',...
        'String','Click on a circle then click on this button to find its transect number.',...
          'Position',[.37 .06 .25 .1],'backgroundcolor',[1 1 1]);
    % add button 
    handles.buttonGetPrNum = uicontrol('style','pushbutton','units','normalized',...
        'string','Find #',...
        'position',[.37 .01 .1 .05],'parent',handles.figure,'fontSize',8);
    % add box to disply profile number
    handles.textBoxShowPrNum = uicontrol('Style','text','units','normalized',...
        'position',[.49 .01 .1 .05],'tag','profileNum');
    
    % add text explaining next box
    htext = uicontrol('Style','text','units','normalized',...
        'String','Or enter a transect number in ths box and that circle will turn green.',...
      'Position',[.67 .06 .3 .1],'backgroundcolor',[1 1 1]);
    % add box to allow user to enter a profile number
    handles.buttonGivenPrNum = uicontrol('style','edit','units','normalized',...
        'position',[.75 .01 .12 .05]);


    % make figure visible only after all is plotted
    set(fhandle,'visible','on')
   
    
    %% add callbacks
    % this has to be done seperately from the button's creating so that I
    % can do a function call and pass in the structure handles.
    % this is differenr from how UCIT does it, but this is how I afarris
    % understand how to program guis, maybe someday I'll go back and use
    % their method.
    set(handles.buttonGetPrNum, 'callback',{@buttonGetPrNum_callback, handles});
    set(handles.buttonGivenPrNum, 'callback',{@buttonGivenPrNum_callback, handles});

    guidata(handles.figure,handles)
end 

end% UCIT_plotDotsAmy.m


%% callbacks

% ------------callback for button to find profile number-------------
function buttonGetPrNum_callback(hObject,event_data,handles)

handles = guidata(hObject);

% get the profile number from the user's last click on the plot 
p = get(handles.axes,'currentPoint');
d=sqrt((handles.shoreX - p(1,1)).^2 + (handles.shoreY-p(2,2)).^2);
[i,j] = min(d);
% the use of curley braces below converts from cell to char:
chosenProfileNum = handles.shoreNums(j);
set(handles.textBoxShowPrNum,'String',num2str(chosenProfileNum));

end % buttonGetPrNum_callback


% ------------callback when given profile number-------------
function buttonGivenPrNum_callback(hObject, eventdata, handles)

handles = guidata(hObject);

% get the profile number the user typed in:
givenPrNum = str2double(get(hObject,'string'));
if isnan(givenPrNum)
    errordlg('You must enter a numeric value','Bad Input','modal')
    return
end

% now find the index of this profile number
i = find(handles.shoreNums == givenPrNum);
if isempty(i) || isnan(handles.shoreX(i))
    errordlg('This profile number is not shown on this plot')
    set(handles.buttonGivenPrNum,'String','  ');
    return
end
    

%now make that profile circle green
line(handles.shoreX(i),handles.shoreY(i),'marker','o','linewidth',2,...
    'markerEdgeColor','g','Parent',handles.axes,'markerFaceColor','g','markerSize',6);

end %buttonGivenPrNum_callback
