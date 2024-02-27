function UCIT_plotAlongshore
%UCIT_PLOTALONGSHORE routine that starts GUI to plot parameters alongshore
%
%
%
% syntax:
%
%
% input:
%
% output:
%
% see also
%

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

% 2010Feb04 Amy Farris made many changes to the appearance of the gui

%% check whether overview figure is present
[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make an overview figure (plotTransectOverview)','No map found');
    return
end

fig100=figure(100);clf;
set(fig100,'Units','normalized','visible','off');%,'Position',UCIT_getPlotPosition('UR',1));
set(fig100,'menubar','none','Resize','on','Resizefcn','UCIT_fncResizeUSGS');
set(fig100,'Position',UCIT_getPlotPosition('UR',1))
set(fig100,'Name','UCIT - Plot parameters alongshore','NumberTitle','Off','Units','characters');
set(fig100,'color','w');
set(fig100,'tag','USGSGUI');
figure(fig100);

mapWhandle = findobj('tag','UCIT_mainWin');
if ~isempty(mapWhandle) && strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),...
        'Lidar Data US')
    [d] = UCIT_getLidarMetaData;
end

transects = d.transectID;
USGSParameters={'Significant wave height','Peak wave period',...
    'Wave length (L0)','Shoreline position','Shoreline change',...
    'Beach slope','Bias','Mean High Water Level'};


% Define Top panel
hpTop       = uipanel('Title','Transect Selection','Units','normalized',...
    'FontSize',12,'FontWeight','bold','BackgroundColor','w','Position',...
    [.1 .65 .8 .3],'Bordertype','etchedout','Tag','Toppanel');

% Define Lower panel
hpBottom    = uipanel('Title','Parameter Selection','Units','normalized',...
    'FontSize',12,'FontWeight','bold','BackgroundColor','w','Position',...
    [.1 .1 .4 .4],'Bordertype','etchedout','Tag','Bottompanel');

% Define side panel 
% add a box around the options for the y-axis 
hpSide = uipanel('Title','X axis','Units','normalized','FontSize',10,...
    'FontWeight','bold','BackgroundColor','w','Position',[.54 .2 .36 .29],...
    'Bordertype','etchedout');

% Text headers of top panel
UIControls.Handle(1)      = uicontrol('Parent',hpTop,'Style','text',...
    'units','normalized','String','Begin at transect number:','FontSize',10,...
    'Position',[0.05 0.75 0.3 0.1],'HorizontalAlignment','left',...
    'Tag','text1','BackgroundColor','w');
UIControls.Handle(2)       = uicontrol('Parent',hpTop,'Style','text',...
    'units','normalized','String','End at transect number:','FontSize',10,...
    'Position',[0.05 0.48 0.3 0.1],'HorizontalAlignment','left',...
    'Tag','text2', 'BackgroundColor','w');
UIControls.Handle(3)       = uicontrol('Parent',hpTop,'Style','text',...
    'units','normalized','String','or:','FontSize',12,...
    'Position',[0.05 0.2 0.3 0.1],'HorizontalAlignment','left',...
    'Tag','text3', 'BackgroundColor','w');

% Pulldownbox 1 top panel
UIControls.Handle(4)  = uicontrol('Parent',hpTop,'Style', 'popup',...
    'backgroundcolor','w','units','normalized', 'String', transects,...
    'Tag','beginTransect','Position',[0.4 0.74 0.2 0.12]);

% Pulldownbox 2 top panel
UIControls.Handle(5)  = uicontrol('Parent',hpTop,'Style', 'popup',...
    'backgroundcolor','w','units','normalized', 'String', transects,...
    'Tag','endTransect','Position',[0.4 0.48 0.2 0.12]);%,'Callback', 'clbPlotUSGS'

% Pushbutton of top panel
UIControls.Handle(6)    = uicontrol('Parent',hpTop,'Style','pushbutton',...
    'units','normalized','String','Select transects from overview',...
    'Position',[0.15 .15 .55 .17],'FontSize',10,'Enable','on','Tag','text4',...
    'Callback','UCIT_SelectTransectsUS');

% Pushbutton 
UIControls.Handle(13)    = uicontrol('Style','pushbutton',...
    'units','normalized','String','Show these transects in colored dot plot',...
    'Position',[0.4 .5 .5 .05],'FontSize',10,'Enable','on','Tag','text4',...
    'Callback','UCIT_plotDotsAmy');
%    'Callback','UCIT_plotDots');

% Pushbutton 
UIControls.Handle(14)    = uicontrol('Style','pushbutton',...
    'units','normalized','String','Export these transects to Google Earth',...
    'Position',[0.4 .57 .5 .05],'FontSize',10,'Enable','on','Tag','text4',...
    'Callback','UCIT_exportSelectedTransects2GoogleEarth');

% Listbox lower panel
UIControls.Handle(7)         = uicontrol('Parent',hpBottom,'Style','listbox',...
    'units','normalized','FontSize',10,'Enable','on',...
    'Position',[0.05 0.09 .9 .88],'BackgroundColor',[1 1 1],...
    'HorizontalAlignment','right','String',USGSParameters,'max',2,'Tag','Input');

% text in side panel
UIControls.Handle(10) = uicontrol('Parent',hpSide,'Style','text',...
    'units','normalized','String','Default is transect number',...
    'Position',[0.1 .74 .8 .15], 'FontSize',8,'Enable','on',...
    'BackgroundColor',[1 1 1]);

% Check box 1 side panel
UIControls.Handle(9) = uicontrol('Parent',hpSide,'Style','check',...
    'units','normalized','String',' Lattitude',...
    'Position',[0.2 .57 .5 .15], 'FontSize',8,'Enable','on','Tag','lattitude',...
    'BackgroundColor',[1 1 1],'callback','UCIT_toggleCheckBoxes');

% Check box 2 side panel
UIControls.Handle(9) = uicontrol('Parent',hpSide,'Style','check',...
    'units','normalized','String',' Distance along coast',...
    'Position',[0.2 .4 .8 .15], 'FontSize',8,'Enable','on','Tag','refline',...
    'BackgroundColor',[1 1 1],'callback','UCIT_toggleCheckBoxes');

% Check box 3 side panel
UIControls.Handle(9) = uicontrol('Parent',hpSide,'Style','check',...
    'units','normalized','String','Reverse direction ',...
    'Position',[0.1 .05 .5 .15], 'FontSize',8,'Enable','on','Tag','flipaxis',...
    'BackgroundColor',[1 1 1], 'callback','UCIT_toggleCheckBoxes');

% Pushbutton 1 
UIControls.Handle(8)     = uicontrol('Style','pushbutton',...
    'units','normalized','String','Plot', 'Position',[0.55 .1 .15 .06],...
    'FontSize',8,'FontWeight','bold','Enable','on','Tag','text6',...
    'Callback','UCIT_clbPlotUSGS');

% Pushbutton 2 
UIControls.Handle(8)     = uicontrol('Style','pushbutton',...
    'units','normalized','String','Export', 'Position',[0.74 .1 .15 .06],...
    'FontSize',8,'FontWeight','bold','Enable','on','Tag','text7',...
    'Callback','UCIT_saveDataUS');


set(fig100,'visible','on')

% Workaround wierd bug 
for k = 1:24
    a =  findobj('tag',['text' num2str(k)]);
    set(a,'fontsize',8)
end
