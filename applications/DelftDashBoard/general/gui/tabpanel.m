function handle = tabpanel(fcn, varargin)
%TABPANEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handle tabhandles] = tabpanel(fcn, varargin)
%
%   Input:
%   fcn        =
%   varargin   =
%
%   Output:
%   handle     =
%   tabhandles =
%
%   Example
%   tabpanel
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: tabpanel.m 11761 2015-03-03 10:17:43Z ormondt $
% $Date: 2015-03-03 18:17:43 +0800 (Tue, 03 Mar 2015) $
% $Author: ormondt $
% $Revision: 11761 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/gui/tabpanel.m $
% $Keywords: $

%%

tabnames=[];
inputarguments=[];
strings=[];
tabname=[];
parent=[];
tag=[];
handle=[];
fig=gcf;
clr=[];
activetabnr=1;
callbackopt='withcallback';
element=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'figure'}
                fig=varargin{i+1};
            case{'tag','name'}
                tag=varargin{i+1};
            case{'handle'}
                handle=varargin{i+1};
            case{'position'}
                pos=varargin{i+1};
            case{'strings'}
                strings=varargin{i+1};
            case{'tabname'}
                tabname=varargin{i+1};
            case{'callbacks'}
                callbacks=varargin{i+1};
            case{'inputarguments'}
                inputarguments=varargin{i+1};
            case{'tabnames'}
                tabnames=varargin{i+1};
            case{'parent'}
                parent=varargin{i+1};
            case{'color'}
                color=varargin{i+1};
            case{'activetabnr'}
                activetabnr=varargin{i+1};
            case{'runcallback'}
                if ~varargin{i+1}
                    callbackopt='nocallback';
                end
            case{'element'}
                element=varargin{i+1};
        end
    end
end

if isempty(clr)
    clr=get(fig,'Color');
end
if isempty(tabnames) && ~isempty(strings)
    tabnames=strings;
end

%if verLessThan('matlab', '8.4')
    
    % Use MvO tabpanel
    
    if isempty(handle)
        handle=findobj(fig,'Tag',tag,'Type','uipanel');
    end
    
    switch lower(fcn)
        case{'create'}
            ntabs=length(tabnames);
            [handle,tabhandle]=createTabPanel(fig,tag,clr,pos,parent,ntabs,element);
            changeTabPanel(handle,strings,callbacks,inputarguments,tabnames);
            select(handle,activetabnr,'nocallback');
            %        select(handle,activetabnr,'withcallback');
        case{'change'}
            changeTabPanel(handle,strings,callbacks,inputarguments,tabnames);
            select(handle,activetabnr,'nocallback');
        case{'select'}
            panel=get(handle,'UserData');
            tabnames=panel.tabNames;
            iac=strmatch(lower(tabname),lower(tabnames),'exact');
            select(handle,iac,callbackopt);
        case{'disabletab'}
            panel=get(handle,'UserData');
            tabnames=panel.tabNames;
            iac=strmatch(lower(tabname),lower(tabnames),'exact');
            set(panel.tabTextHandles(iac),'Enable','off');
        case{'enabletab'}
            panel=get(handle,'UserData');
            tabnames=panel.tabNames;
            iac=strmatch(lower(tabname),lower(tabnames),'exact');
            set(panel.tabTextHandles(iac),'Enable','inactive');
        case{'delete'}
            deleteTabPanel(handle);
        case{'resize'}
            resizeTabPanel(handle,pos);
        case{'update'}
            updateTabElements(handle);
    end
    
% else
%     
%     % Use Matlab native tabpanel
%     
%     switch lower(fcn)
%         case{'create'}
%             ntabs=length(tabnames);
%             handle = uitabgroup();
%             for itab=1:ntabs
%                 t = uitab(handle, 'title', strings{itab},'ButtonDownFcn',callbacks{itab});
%             end
%             setappdata(handle,'element',element);
% 
% % %             
% % %             [handle,tabhandle]=createTabPanel(fig,tag,clr,pos,parent,ntabs,element);
% % %             changeTabPanel(handle,strings,callbacks,inputarguments,tabnames);
% % %             select(handle,activetabnr,'nocallback');
% % %             %        select(handle,activetabnr,'withcallback');
% %         case{'change'}
% %             changeTabPanel(handle,strings,callbacks,inputarguments,tabnames);
% %             select(handle,activetabnr,'nocallback');
% %         case{'select'}
% %             panel=get(handle,'UserData');
% %             tabnames=panel.tabNames;
% %             iac=strmatch(lower(tabname),lower(tabnames),'exact');
% %             select(handle,iac,callbackopt);
% %         case{'disabletab'}
% %             panel=get(handle,'UserData');
% %             tabnames=panel.tabNames;
% %             iac=strmatch(lower(tabname),lower(tabnames),'exact');
% %             set(panel.tabTextHandles(iac),'Enable','off');
% %         case{'enabletab'}
% %             panel=get(handle,'UserData');
% %             tabnames=panel.tabNames;
% %             iac=strmatch(lower(tabname),lower(tabnames),'exact');
% %             set(panel.tabTextHandles(iac),'Enable','inactive');
% %         case{'delete'}
% %             deleteTabPanel(handle);
% %         case{'resize'}
% %             resizeTabPanel(handle,pos);
% %         case{'update'}
% %             updateTabElements(handle);
%     end
%     
% end

%%
function [panelHandle,largeTab]=createTabPanel(fig,panelname,clr,panelPosition,parent,ntabs,element)

foregroundColor=clr;
backgroundColor=clr*0.9;

leftpos(1)=3;
vertpos=panelPosition(4)-1;

tabHeight=20;

tabs=zeros(ntabs,1);
tabText=tabs;
blankText=tabs;

pos=[panelPosition(1)-1 panelPosition(2)-1 panelPosition(3)+2 panelPosition(4)+20];

if verLessThan('matlab', '8.4')
    panelHandle = uipanel(fig,'Parent',parent,'Units','pixels','Position',pos,'BorderType','none','BackgroundColor','none','Tag',panelname);
else
    panelHandle = uipanel(fig,'Parent',parent,'Units','pixels','Position',pos,'BorderType','none','BackgroundColor',foregroundColor,'Tag',panelname);
end

for i=1:ntabs
    
    position=[leftpos vertpos 30 tabHeight];
    
    % Add tab
    tabs(i) = uipanel(fig,'Parent',panelHandle,'Units','pixels','Position',position,'Tag','dummy','BorderType','beveledout','BackgroundColor',backgroundColor,'Visible','on');
    
    % Add text, first use bold
    tabText(i) = uicontrol(fig,'Units','pixels','Parent',panelHandle,'Style','text','String','dummy','Position',position,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor',backgroundColor,'Visible','off');
    set(tabText(i),'Enable','inactive');
    
    % Set user data
    usd.nr=i;
    usd.panelHandle=panelHandle;
    set(tabs(i),'UserData',usd);
    set(tabText(i),'UserData',usd);
    
    % Left position for next tab
    leftpos=leftpos+30;
    
end

setappdata(panelHandle,'element',element);

% Create new main panel
visph = uipanel(fig,'Units','pixels','Parent',panelHandle,'Position',[1 1 panelPosition(3) panelPosition(4)],'BorderType','beveledout','BackgroundColor',foregroundColor);

%pos=[1 1 panelPosition(3) panelPosition(4)+20];
pos=[1 1 panelPosition(3) panelPosition(4)];

% Create one large tab to put elements in

if verLessThan('matlab', '8.4')
    largeTab = uipanel(fig,'Parent',panelHandle,'Units','pixels','Position',pos,'Tag','largeTab','BorderType','none','BackgroundColor','none','Visible','on','HitTest','off');
else
    largeTab = uipanel(fig,'Parent',panelHandle,'Units','pixels','Position',pos,'Tag','largeTab','BorderType','beveledout','BackgroundColor',foregroundColor,'Visible','on','HitTest','off');
end

% Add blank texts
leftpos=3;
vertpos=panelPosition(4)-1;
for i=1:ntabs
    position=[leftpos vertpos 30 tabHeight];
    blankText(i) = uicontrol(fig,'Style','text','String','','Position',position,'Visible','off','Parent',panelHandle);
    leftpos=leftpos+30;
end

set(blankText,'BackgroundColor',foregroundColor);
set(blankText,'HandleVisibility','off','HitTest','off');

% Add user data to panel
panel.nrTabs=ntabs;
panel.visiblePanel=visph;
panel.tabHandles=tabs;
panel.largeTabHandle=largeTab;
panel.tabTextHandles=tabText;
panel.blankTextHandles=blankText;
panel.handle=panelHandle;
panel.position=panelPosition;
panel.foregroundColor=foregroundColor;
panel.backgroundColor=backgroundColor;
panel.activeTab=1;

set(panelHandle,'UserData',panel);

%%
function changeTabPanel(panelHandle,strings,callbacks,inputarguments,tabnames)

ntabs=length(strings);

if isempty(inputarguments)
    for i=1:length(strings)
        inputarguments{i}=[];
    end
end

% Set panel tabs invisible
panel=get(panelHandle,'UserData');
tabs=panel.tabHandles;
tabText=panel.tabTextHandles;
blankText=panel.blankTextHandles;

set(tabs(1:ntabs),'Visible','on');
set(tabText(1:ntabs),'Visible','on');
set(blankText(1:ntabs),'Visible','on');

foregroundColor=panel.foregroundColor;
backgroundColor=panel.backgroundColor;

panelPosition=panel.position;

leftpos=3;
vertpos=panelPosition(4)-1;
leftTextMargin=3;
bottomTextMargin=2;
tabHeight=20;
textHeight=15;

for i=1:ntabs
    
    tmppos=get(tabText(i),'Position');
    tmppos(3)=150;
    set(tabText(i),'Position',tmppos);
    set(tabText(i),'String',strings{i},'FontWeight','bold');
    
    % Compute new position
    ext=get(tabText(i),'Extent');
    wdt(i)=ext(3)+2*leftTextMargin;
    position=[leftpos(i) vertpos ext(3)+2*leftTextMargin tabHeight];
    set(tabs(i),'Position',position);
    textPosition=[position(1)+leftTextMargin position(2)+bottomTextMargin ext(3) textHeight];
    set(tabText(i),'Position',textPosition);
    
    position=[leftpos(i)+1 vertpos wdt(i)-3 3];
    set(blankText(i),'Position',position);
    
    % Add callback
    set(tabs(i),'ButtonDownFcn',{@clickTab});
    set(tabText(i),'ButtonDownFcn',{@clickTab});
    
    % Set user data
    usd=get(tabs(i),'UserData');
    set(tabs(i),'UserData',usd);
    set(tabText(i),'UserData',usd);
    
    % Left position for next tab
    leftpos(i+1)=leftpos(i)+wdt(i)+1;
    
end

% Set values for all tabs
set(tabs,'BackgroundColor',backgroundColor);
set(tabText,'BackgroundColor',backgroundColor,'FontWeight','normal');
set(blankText,'Visible','off');

% Give first tab background color and make blank text visible
set(tabs(1),'BackgroundColor',foregroundColor);
set(tabText(1),'BackgroundColor',foregroundColor,'FontWeight','bold');
set(blankText(1),'Visible','on');

% Add user data to panel
panel.nrTabs=ntabs;
panel.strings=strings;
panel.tabNames=tabnames;
panel.callbacks=callbacks;
panel.inputArguments=inputarguments;

set(panelHandle,'UserData',panel);

%%
function clickTab(hObject,eventdata)

usd=get(hObject,'UserData');
h=usd.panelHandle;
nr=usd.nr;
try
    enable=get(hObject,'Enable');    
    switch lower(enable)
        case{'off'}
        otherwise
            select(h,nr,'withcallback');
    end
end

%%
function select(h,iac,opt)

setappdata(gcf,'activetabpanel',h);
setappdata(gcf,'activetab',iac);

panel=get(h,'UserData');

panel.activeTab=iac;
set(h,'UserData',panel);

% Set active tab number in appdata
try
    el=getappdata(h,'element');
end
el.activetabnr=iac;

% All tabs
set(panel.tabHandles,'BackgroundColor',panel.backgroundColor);
set(panel.tabTextHandles,'FontWeight','normal');
set(panel.tabTextHandles,'BackgroundColor',panel.backgroundColor);
set(panel.blankTextHandles,'Visible','off');

% Active tab
set(panel.tabHandles(iac),'BackgroundColor',panel.foregroundColor);
set(panel.tabTextHandles(iac),'BackgroundColor',panel.foregroundColor);
set(panel.tabTextHandles(iac),'FontWeight','bold');
set(panel.blankTextHandles(iac),'Visible','on');

% Delete original elements
p=panel.largeTabHandle;
ch=get(p,'Children');
delete(ch);

% New elements in selected tab
p=panel.largeTabHandle;
newelements=el.tab(iac).tab.element;
newelements=gui_addElements(gcf,newelements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',p);
el.tab(iac).tab.element=newelements;
setappdata(h,'element',el);

% Deal with callbacks
if strcmpi(opt,'withcallback')
    
    % Elements is structure of elements inside selected tab
    element=el.tab(iac).tab.element;
    
    callback=el.tab(iac).tab.callback;

    % Now look for tab panels within this tab, and execute callback associated
    % with active tabs
    for k=1:length(element)
        if strcmpi(element(k).element.style,'tabpanel')
            % Find active tab
            hh=element(k).element.handle;
            el=getappdata(hh,'element');
            iac=el.activetabnr;
            callback=el.tab(iac).tab.callback;
            break
        end
    end
    
    if ~isempty(callback)
        feval(callback);
    end
    
end

% Change element structure of parent (if that is also a tab panel)
if isfield(el,'parenthandle')
    if ~isempty(el.parenthandle)
        tg=get(el.parenthandle,'tag');
        switch lower(tg)
            case{'largetab'}
                pp=get(el.parenthandle,'parent'); % handle of larger tab panel
                pelement=getappdata(pp,'element');                
                itabp=pelement.activetabnr;
                % Assuming only one tab panel
                for iel=1:length(pelement.tab(itabp).tab.element)
                    if strcmpi(pelement.tab(itabp).tab.element(iel).element.style,'tabpanel')
                        pelement.tab(itabp).tab.element(iel).element.activetabnr=iac;
                    end
                end
                setappdata(pp,'element',pelement);                
        end
    end
end


%%
function deleteTabPanel(h)

delete(h);

%%
function resizeTabPanel(h,panelPosition)

panel=get(h,'UserData');

if verLessThan('matlab', '8.4')
    posInvisibleTab=[panelPosition(1)-1 panelPosition(2)-1 panelPosition(3)+2 panelPosition(4)+20];
else
    posInvisibleTab=[panelPosition(1)-1 panelPosition(2)-1 panelPosition(3)+2 panelPosition(4)+20];
end

% Outer (invisible) panel
set(h,'Position',posInvisibleTab);

pvis=panel.visiblePanel;

posVisibleTab=[1 1 panelPosition(3) panelPosition(4)];
% Outer (invisible) panel
set(pvis,'Position',posVisibleTab);

bottomTextMargin=3;
vertPosTabs=panelPosition(4)-1;
vertPosText=vertPosTabs+bottomTextMargin;

if verLessThan('matlab', '8.4')
posLargeTabs=[1 1 panelPosition(3) panelPosition(4)+20];
else
posLargeTabs=[1 1 panelPosition(3) panelPosition(4)];
end

set(panel.largeTabHandle,'Position',posLargeTabs);

for i=1:panel.nrTabs
    
    
    pos=get(panel.tabHandles(i),'Position');
    pos(2)=vertPosTabs;
    set(panel.tabHandles(i),'Position',pos);
    
    pos=get(panel.blankTextHandles(i),'Position');
    pos(2)=vertPosTabs;
    set(panel.blankTextHandles(i),'Position',pos);
    
    pos=get(panel.tabTextHandles(i),'Position');
    pos(2)=vertPosText;
    set(panel.tabTextHandles(i),'Position',pos);
    
end

panel.position=panelPosition;
set(h,'UserData',panel);

