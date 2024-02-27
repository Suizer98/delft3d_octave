function varargout = ddb_MADToolbox(varargin)
%DDB_MADTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_MADToolbox(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_MADToolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

ddb_plotMAD(handles,'activate');

h=findobj(gca,'Tag','MADModels');

if isempty(handles.Toolbox(tb).Models)
    handles.Toolbox(tb).Models(1).Name=' ';
    handles.Toolbox(tb).Models(1).Description='No models available';
    handles.Toolbox(tb).nrModels=0;
    handles=getMADModels(handles);
    ddb_plotMADModels(handles);
end

hp = uipanel('Title','Model Application Database','Units','pixels','Position',[50 20 960 160],'Tag','UIControl');

handles.PushGoToWiki      = uicontrol(gcf,'Style','pushbutton','String','Go to Wiki Page','Position',   [290 140 140  20],'Tag','UIControl');
handles.PushShowGrid      = uicontrol(gcf,'Style','pushbutton','String','Show Grid',      'Enable','off','Position',   [290 115 140  20],'Tag','UIControl');
handles.PushGrid2KML      = uicontrol(gcf,'Style','pushbutton','String','Grid to KML', 'Position',   [290  90 140  20],'Tag','UIControl');
set(handles.PushGrid2KML,'ToolTipString','This will convert the active FLOW grid into a Google Earth KML file that can be attached to MAD.');
clrs={'Black','Red','Blue','Green'};
handles.SelectKMLColor    = uicontrol(gcf,'Style','popupmenu', 'String',clrs, 'Value',1,'Position',   [440  90 60  20],'BackgroundColor','white','Tag','UIControl');
set(handles.SelectKMLColor,'ToolTipString','Select the color of the KML grid.');
ii=strmatch(lower(handles.Toolbox(tb).KMLColor),lower(clrs),'exact');
set(handles.SelectKMLColor,'Value',ii);
handles.TextDescription   = uicontrol(gcf,'Style','text','String','Description',          'Position',   [290  30 300  50],'HorizontalAlignment','left','Tag','UIControl');

str{1}=' ';
for ii=1:handles.Toolbox(tb).nrModels
    str{ii}=handles.Toolbox(tb).Models(ii).Name;
end

handles.ListMADModels     = uicontrol(gcf,'Style','listbox','String',str,  'Value',1,  'Position',   [ 70  30 200 130],'BackgroundColor','white','Tag','UIControl');

set(handles.PushGoToWiki,      'CallBack',{@PushGoToWiki_CallBack});
set(handles.PushShowGrid,      'CallBack',{@PushShowGrid_CallBack});
set(handles.PushGrid2KML,      'CallBack',{@PushGrid2KML_CallBack});
set(handles.ListMADModels,     'CallBack',{@ListMADModels_CallBack});
set(handles.SelectKMLColor,    'CallBack',{@SelectKMLColor_CallBack});

ii=handles.Toolbox(tb).ActiveMADModel;
set(handles.ListMADModels,'Value',ii);

set(handles.TextDescription,'String',handles.Toolbox(tb).Models(ii).Description);

set(gcf,'WindowButtonDownFcn',{@SelectMADModel});

RefreshDescription(handles);

SetUIBackgroundColors;

setHandles(handles);

if handles.Toolbox(tb).nrModels==0
    set(handles.PushGoToWiki,'Enable','off');
    set(handles.PushShowGrid,'Enable','off');
    set(handles.PushGrid2KML,'Enable','off');
    set(handles.ListMADModels,'Enable','off');
    set(handles.SelectKMLColor,'Enable','off');
end

%%
function PushGoToWiki_CallBack(hObject,eventdata)
handles=getHandles;

wikisite=['http://wiki.deltares.nl/' handles.Toolbox(tb).Models(handles.Toolbox(tb).ActiveMADModel).Link];
web(wikisite,'-browser');

%%
function PushShowGrid_CallBack(hObject,eventdata)
handles=getHandles;
setHandles(handles);

%%
function PushGrid2KML_CallBack(hObject,eventdata)
handles=getHandles;

id=handles.ActiveDomain;
if ~isempty(handles.Model(md).Input(id).GrdFile)
    fname=handles.Model(md).Input(id).GrdFile;
    switch(lower(handles.Toolbox(tb).KMLColor))
        case{'black'}
            clr=[0 0 0];
        case{'red'}
            clr=[255 0 0];
        case{'blue'}
            clr=[0 0 255];
        case{'green'}
            clr=[0 255 0];
    end
    grid2kml(fname,clr);
end
setHandles(handles);

%%
function SelectKMLColor_CallBack(hObject,eventdata)
handles=getHandles;

ii=get(hObject,'Value');
str=get(hObject,'String');
handles.Toolbox(tb).KMLColor=str{ii};
setHandles(handles);

%%
function SelectMADModel(imagefig, varargins)
h=gco;
if strcmp(get(h,'Tag'),'MADModels')
    handles=getHandles;
    xy=handles.Toolbox(tb).xy;
    pos = get(gca, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    dxsq=(xy(:,1)-posx).^2;
    dysq=(xy(:,2)-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [y,n]=min(dist);
    h0=findall(gcf,'Tag','ActiveMADModel');
    delete(h0);
    plt=plot3(xy(n,1),xy(n,2),1000,'p');
    set(plt,'MarkerSize',15,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveMADModel');
    set(handles.ListMADModels,'Value',n);
    handles.Toolbox(tb).ActiveMADModel=n;
    RefreshDescription(handles);
    setHandles(handles);
end

%%
function ListMADModels_CallBack(hObject,eventdata)
handles=getHandles;
if handles.Toolbox(tb).nrModels>0
    ii=get(hObject,'Value');
    h0=findall(gcf,'Tag','ActiveMADModel');
    delete(h0);
    plt=plot3(handles.Toolbox(tb).xy(ii,1),handles.Toolbox(tb).xy(ii,2),1000,'p');
    set(plt,'MarkerSize',15,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveMADModel');
    handles.Toolbox(tb).ActiveMADModel=ii;
    RefreshDescription(handles);
    setHandles(handles);
end

%%
function RefreshDescription(handles)

set(handles.TextDescription,'String',['Description : ' handles.Toolbox(tb).Models(handles.Toolbox(tb).ActiveMADModel).Description] );

%%
function handles=getMADModels(handles)


try
    
    wb = waitbox('Loading Model Application Database ...');
    
    xDoc = xmlread('http://wiki.deltares.nl/download/attachments/4325644/georss.xml');
    
    % Find a deep list of all <listitem> elements.
    allListItems = xDoc.getElementsByTagName('item');
    %Note that the item list index is zero-based.
    for i=0:allListItems.getLength-1
        thisListItem = allListItems.item(i);
        lat(i+1)=str2double(thisListItem.getElementsByTagName('geo:lat').item(0).getFirstChild.getData);
        lon(i+1)=str2double(thisListItem.getElementsByTagName('geo:long').item(0).getFirstChild.getData);
        tit{i+1}=char(thisListItem.getElementsByTagName('title').item(0).getFirstChild.getData);
        link{i+1}=char(thisListItem.getElementsByTagName('link').item(0).getFirstChild.getData);
        try
            descr{i+1}=char(thisListItem.getElementsByTagName('description').item(0).getFirstChild.getData);
        catch
            descr{i+1}='';
        end
    end
    
    close(wb);
    nmod=length(lon);
    for ii=1:nmod
        handles.Toolbox(tb).Models(ii).Longitude=lon(ii);
        handles.Toolbox(tb).Models(ii).Latitude=lat(ii);
        handles.Toolbox(tb).Models(ii).Description=descr{ii};
        handles.Toolbox(tb).Models(ii).Name=tit{ii};
        handles.Toolbox(tb).Models(ii).Link=link{ii};
    end
    
    handles.Toolbox(tb).nrModels=nmod;
    
    x=lon;
    y=lat;
    cs.Name='WGS 84';
    cs.Type='Geographic';
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    for ii=1:nmod
        handles.Toolbox(tb).xy=[x;y]';
    end
    handles.Toolbox(tb).ActiveMADModel=1;
catch
    try
        close(wb);
    end
    ddb_giveWarning('Warning','Sorry, could not connect to server!');
end

%%
function ddb_plotMADModels(handles)

try
    
    h=findall(gca,'Tag','MADModels');
    if ~isempty(h)
        delete(h);
    end
    h=findall(gca,'Tag','ActiveMADModel');
    if ~isempty(h)
        delete(h);
    end
    
    x=handles.Toolbox(tb).xy(:,1);
    y=handles.Toolbox(tb).xy(:,2);
    z=zeros(size(x))+800;
    
    plt=plot3(x,y,z,'rp');
    set(plt,'MarkerFaceColor','y');
    set(plt,'MarkerSize',15,'MarkerEdgeColor','k','MarkerFaceColor','y');
    set(plt,'Tag','MADModels');
    
    n=handles.Toolbox(tb).ActiveMADModel;
    plt=plot3(handles.Toolbox(tb).xy(n,1),handles.Toolbox(tb).xy(n,2),1000,'p');
    set(plt,'MarkerSize',15,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveMADModel');
    
end

