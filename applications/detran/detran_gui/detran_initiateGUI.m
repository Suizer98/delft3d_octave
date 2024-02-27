function h1 = detran_initiateGUI()
%DETRAN_INITIATEGUI Detran GUI function to generate the GUI window and all objects
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Main figure
h1 = figure('MenuBar','none','Name','DETRAN v1.01','Position',[100 100 1024 768],'Tag','figure1','numberTitle','off');

%% Main axis
h2 = axes('Parent',h1,'Units','normalized','Position',[0.253 0.021 0.675 0.965],'Box','on','DataAspectRatioMode','manual','FontSize',8,'Layer','top','PlotBoxAspectRatioMode','manual','Tag','axes1');

%% Data input/output
h39 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.96 0.19 0.03],'String','Data input/output','Style','text','Tag','text14');
h7 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_loadData','Position',[0.01 0.88 0.10 0.03],'String','Load data','Tag','detran_loadDataBut');
h26 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_export2lint','Position',[0.13 0.88 0.10 0.03],'String','Export to lintfile','Tag','detran_exportBut');
h33 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_saveData','Position',[0.01 0.84 0.10 0.03],'String','Save data','Tag','detran_saveDataBut');
h34 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_importData','Position',[0.01 0.92 0.1 0.03],'String','Import data','Tag','detran_importDataBut');
h43 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_exportFig','Position',[0.13 0.92 0.10 0.03],'String','Export2fig','Tag','detran_exportFigBut');

%% Transport settings
h35 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.79 0.19 0.03],'String','Transport settings','Style','text','Tag','text9');
h9 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_prepareTransPlot;detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.76 0.13 0.03],'String',{  'Total transport'; 'Bed load'; 'Suspended load' },'Style','popupmenu','Value',1,'Tag','detran_transType');
h10 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.71 0.13 0.03],'String',{  'Per second'; 'Per minute'; 'Hourly'; 'Daily'; 'Weekly'; 'Monthly'; 'Yearly'; 'User-defined (sec)' },'Style','popupmenu','Value',1,'Tag','detran_timeWindow');
h11 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','Position',[0.15 0.71 0.08 0.03],'String','1','Style','edit','TooltipString','Specify user-defined period in seconds','Tag','detran_specTimeWindow');
h12 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_prepareTransPlot;detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.66 0.13 0.03],'String','fraction1','Style','popupmenu','Value',1,'Tag','detran_fraction');
h44 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','Position',[0.01 0.64 0.15 0.02],'String','Inlcude a pore volume of:','Style','checkbox','Tag','detran_poreCheck');
h45 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap;detran_plotTransArbCS','HorizontalAlignment','right','Position',[0.17 0.63 0.03 0.03],'String','40','Style','edit','TooltipString','Specify user-defined pore volume in %','Tag','detran_poreWindow');
h46 = uicontrol('Parent',h1,'Units','normalized','Position',[0.21 0.63 0.02 0.02],'String','%','Style','text','Tag','text16');

%% Map plot settings
h36 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.47 0.19 0.03],'String','Map plot settings','Style','text','Tag','text10');
h13 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.18 0.13 0.03],'String','map vector scaling:','Style','text','Tag','text3');
h14 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.25 0.12 0.03],'String','map vector spacing:','Style','text','Tag','text4');
h15 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.25 0.08 0.03],'String','1','Style','edit','TooltipString','Specify vector spacing values per domain, seperated by spaces','Tag','detran_vecSpacing');
h16 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.21 0.08 0.03],'String',{  'Uniform'; 'Distance' },'Style','popupmenu','Value',1,'Tag','detran_spaceMode');
h17 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.18 0.08 0.03],'String','1','Style','edit','TooltipString','Specify vector scaling for map transport vectors','Tag','detran_vecScalingMap');
h19 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.01 0.43 0.14 0.03],'String','Plot map transport field','Style','checkbox','Tag','detran_plotMapBox');
h23 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.35 0.13 0.03],'String','color scale:','Style','text','Tag','text6');
h24 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotMap','Position',[0.15 0.35 0.08 0.03],'String','0 1','Style','edit','TooltipString','Specify color scale of map plot, 2 values seperated by a space-character','Tag','detran_colScale');
h27 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotLdb','Position',[0.01 0.39 0.12 0.03],'String','Plot landboundary','Style','checkbox','Tag','detran_plotLdbBox');
h40 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_loadLandboundary','Position',[0.13 0.39 0.10 0.03],'String','Load landboundary','Tag','detran_loadLdbBut');
h41 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.21 0.12 0.03],'String','spacing mode:','Style','text','Tag','text15');
h42 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_toggleColorbar','Position',[0.01 0.32 0.14 0.03],'String','Plot colorbar','Style','checkbox','Tag','detran_colorbarBox');

%% Transect options
h38 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.60 0.19 0.03],'String','Transect options','Style','text','Tag','text12');
h18 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_loadTransects','Position',[0.01 0.56 0.10 0.03],'String','Load transects','Tag','detran_loadTransectsBut');
h21 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_saveTransects','Position',[0.13 0.56 0.10 0.03],'String','Save transects','Tag','detran_saveTransectsBut');
h25 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_adjustTransect','Position',[0.01 0.52 0.10 0.03],'String','Adjust transect','Tag','detran_adjustTransectBut');
h28 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_addTransect','Position',[0.13 0.52 0.10 0.03],'String','Add transect','Tag','detran_addTransectBut');

%% Transect vector plot settings
h37 = uicontrol('Parent',h1,'Units','normalized','FontSize',10,'FontWeight','bold','HorizontalAlignment','left','Position',[0.01 0.15 0.19 0.03],'String','Transect vector plot settings','Style','text','Tag','text11');
h20 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.01 0.11 0.17 0.03],'String','Plot transport through transetcs','Style','checkbox','Tag','detran_plotTransectBox');
h22 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.01 0.08 0.17 0.03],'String','Plot gross transports','Style','checkbox','Tag','detran_plotGrossBox');
h29 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.04 0.13 0.03],'String','transect vector scaling:','Style','text','Tag','text7');
h30 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.15 0.04 0.08 0.03],'String','1','Style','edit','TooltipString','Specify vector scaling for transport vectors through transects','Tag','detran_vecScaling');
h31 = uicontrol('Parent',h1,'Units','normalized','HorizontalAlignment','left','Position',[0.01 0.01 0.13 0.03],'String','multiply transport labels by:','Style','text','Tag','text8');
h32 = uicontrol('Parent',h1,'Units','normalized','Callback','detran_plotTransArbCS','Position',[0.15 0.01 0.08 0.03],'String','1','Style','edit','TooltipString','Sepcify factor (e.g. 0.001 to presents transport in thousands m^3)','Tag','detran_transLabelFactor');

%% Possible future options
% h8 = uicontrol('Parent',h1,'Units','normalized','Position',[0.01 0.0065 0.1 0.03],'String','Layer 1','Style','popupmenu','Value',1,'Tag','detran_layerSelector');

%% Menu
h47   = uimenu('Parent',h1,'Label','File','Tag','detran_fileMenu');
h47_1 = uimenu('Parent',h47,'Label','Load data','Callback','detran_loadData');
h47_2 = uimenu('Parent',h47,'Label','Save data','Callback','detran_saveData');
h47_3 = uimenu('Parent',h47,'Label','Import data','Callback','detran_importData');
h47_4 = uimenu('Parent',h47,'Label','Export data to lintfile','Callback','detran_export2lint');
h47_5 = uimenu('Parent',h47,'Label','Exit','Callback','close(gcf);');

rootPath = ShowPath;
if isdeployed
    [a,b]=strtok(fliplr(rootPath),'\');
    rootPath = fliplr(b);
end

manualFile      = [rootPath filesep 'manual\detran_manual.htm'];
tutorialFile    = [rootPath filesep 'tutorial\Detran_videoTutorial.htm'];

h48   = uimenu('Parent',h1,'Label','Help','Tag','detran_helpMenu');
if exist(manualFile,'file');
    h48_1 = uimenu('Parent',h48,'Label','Manual','Callback',['web(''' manualFile ''',''-browser'')']);
else
    h48_1 = uimenu('Parent',h48,'Label','Manual','Callback','warndlg(''Manual not found, please check the online help'')');
end
if exist(tutorialFile,'file')
    h48_2 = uimenu('Parent',h48,'Label','Tutorial','Callback',['web(''' tutorialFile ''',''-browser'')']);
else
    h48_1 = uimenu('Parent',h48,'Label','Tutorial','Callback','warndlg(''Tutorial not found, please check the online help'')');
end
h48_3 = uimenu('Parent',h48,'Label','Online help','Callback','web(''http://public.deltares.nl/display/OET/Detran'',''-browser'')');
h48_3 = uimenu('Parent',h48,'Label','About','Callback','detran_about');

data=detran_createEmptyStructure;
set(h1,'userdata',data);
set(h1,'Toolbar','figure');
set(findall(h1,'type','uipushtool'),'Separator','off');
set(findall(h1,'type','uitoggletool'),'Separator','off');
delete(findall(h1,'type','uipushtool'));
delete(findall(h1,'tag','figToolRotate3D'));
delete(findall(h1,'tag','ScribeToolBtn'));
delete(findall(h1,'tag','ScribeToolBtn'));
delete(findall(h1,'tag','ScribeToolBtn'));
delete(findall(h1,'tag','ScribeSelectToolBtn'));
delete(findall(h1,'tag','Annotation.InsertLegend'));
delete(findall(h1,'tag','Annotation.InsertColorbar'));
delete(findall(h1,'tag','Exploration.DataCursor'));
delete(findall(h1,'tag','Exploration.Rotate'));
delete(findall(h1,'tag','Standard.EditPlot'));

function [thePath] = ShowPath()
% Show EXE path:
if isdeployed % Stand-alone mode.
    [status, result] = system('set PATH');
    thePath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
else % Running from MATLAB.
    [macroFolder, baseFileName, ext] = fileparts(which('detran.m'));
    thePath = macroFolder;
    % thePath = pwd;
end