function XB_Result_Viewer
%XB_RESULT_VIEWER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   XB_Result_Viewer
%
%
%   Example
%   XB_Result_Viewer
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@Deltares.nl	
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: XB_Result_Viewer.m 3519 2010-12-03 13:37:25Z geer $
% $Date: 2010-12-03 21:37:25 +0800 (Fri, 03 Dec 2010) $
% $Author: geer $
% $Revision: 3519 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBRV/XB_Result_Viewer.m $
% $Keywords: $

%%
if isempty(which('XBRV_CB_Close.m'))
    addpath(genpath(fileparts(mfilename('fullpath'))));
end

h = XBRV_initiate_h;

%% Figure

h.fig = figure('Units','pixels',...
    'Name','XBeach result viewer',...
    'MenuBar','none',...
    'WindowButtonDownFcn',@XBRV_CB_Select,...
    'CloseRequestFcn',@XBRV_CB_Close,...
    'Position',[200 200 1300 600]); 

fh = get(h.fig,'JavaFrame'); % Get Java Frame 
fh.setFigureIcon(javax.swing.ImageIcon(which('DeltaresLogo_transp.gif')));

%% Menus
h.menu.File.Main = uimenu(h.fig,...
    'Label','&File');
h.menu.File.NewProject = uimenu(h.menu.File.Main,...
    'Label','&New Project',...
    'Callback',@notfin);
h.menu.File.LoadProject = uimenu(h.menu.File.Main,...
    'Label','&Load Project',...
    'Callback',@notfin);
h.menu.File.SaveProject = uimenu(h.menu.File.Main,...
    'Label','&Save Project',...
    'Callback',@notfin);
h.menu.File.Prefs = uimenu(h.menu.File.Main,...
    'Label','&Preferences',...
    'Separator','on',...
    'Callback',@XBRB_set_preferences);
h.menu.File.Close = uimenu(h.menu.File.Main,...
    'Label','&Close',...
    'Separator','on',...
    'Callback',@XBRV_CB_Close);

h.menu.Datasets.Main = uimenu(h.fig,...
    'Label','&Datasets');
h.menu.Datasets.LoadSet = uimenu(h.menu.Datasets.Main,...
    'Label','&Load Dataset',...
    'Callback',@notfin);
h.menu.Datasets.SaveSet = uimenu(h.menu.Datasets.Main,...
    'Label','&Save Dataset',...
    'Callback',@notfin);
h.menu.Datasets.RemoveSet = uimenu(h.menu.Datasets.Main,...
    'Label','&Remove Dataset',...
    'Callback',@notfin);
h.menu.Datasets.Sets.main = uimenu(h.menu.Datasets.Main,...
    'Label','&Select Dataset',...
    'Enable','off');

h.menu.Help.Main = uimenu(h.fig,...
    'Label','&Help');
h.menu.Help.About = uimenu(h.menu.Help.Main,...
    'Label','&About',...
    'Callback',@notfin);

%% dir selection
h.dirbutton = uicontrol(h.fig,...
    'Style','pushbutton',...
    'String','browse output dir...',...
    'Callback',@XBRV_Load,...
    'Position',[10 570 180 20]);

h.dirfield = uicontrol(h.fig,...
    'Style','edit',...
    'Enable','inactive',...
    'String','browse output dir...',...
    'Position',[200 570 790 20]);

%% instellingen
h.instpanel = uipanel(h.fig,...
    'Units','pixels',...
    'Position',[10 10 180 550]);

h.plothan.plotspec.currentdataset = uicontrol(h.instpanel,...
    'Style','popupmenu',...
    'String','browse output dir...',...
    'Value',h.plotspec.currentdataset,...
    'Units','pixels',...
    'BackGroundColor','w',...
    'Tag','XBselect',...
    'Callback',{@XBRV_CB_Set,'XBselect'},...
    'Position',[10 520 160 20]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','Choose visualization:',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 490 115 15]);
val = 1;
if h.plotspec.ddd
    val = 2;
end
h.plothan.plotspec.ddd = uicontrol(h.instpanel,...
    'Style','popupmenu',...
    'String',{'2D','3D'},...
    'Value',val,...
    'Units','pixels',...
    'BackGroundColor','w',...
    'Tag','ddd',...
    'Callback',{@XBRV_CB_Set,'ddd'},...
    'Position',[130 490 40 20]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','dframes :',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 460 115 15]);
h.plothan.plotspec.dframes = uicontrol(h.instpanel,...
    'Style','edit',...
    'String',num2str(h.plotspec.dframes),...
    'Units','pixels',...
    'BackGroundColor','w',...
    'Tag','dframes',...
    'Callback',{@XBRV_CB_Set,'dframes'},...
    'Position',[130 460 40 20]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','dt :',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 430 115 15]);
h.plothan.plotspec.dt = uicontrol(h.instpanel,...
    'Style','edit',...
    'String',num2str(h.plotspec.dt),...
    'Units','pixels',...
    'BackGroundColor','w',...
    'Tag','dt',...
    'Callback',{@XBRV_CB_Set,'dt'},...
    'Position',[130 430 40 20]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','y - coordinate :',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 400 115 15]);
h.plothan.plotspec.nyid = uicontrol(h.instpanel,...
    'Style','edit',...
    'String',num2str(h.plotspec.nyid),...
    'Units','pixels',...
    'BackGroundColor','w',...
    'Tag','nyid',...
    'Callback',{@XBRV_CB_Set,'nyid'},...
    'Position',[130 400 40 20]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','plot Hrms :',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 370 115 15]);
h.plothan.plotspec.hrmson = uicontrol(h.instpanel,...
    'Style','checkbox',...
    'Value',h.plotspec.hrmson,...
    'Units','pixels',...
    'Tag','hrmson',...
    'Callback',{@XBRV_CB_Set,'hrmson'},...
    'Position',[130 370 15 15]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','Hrms thinning :',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 340 115 15]);
h.plothan.plotspec.nthin = uicontrol(h.instpanel,...
    'Style','edit',...
    'String',num2str(h.plotspec.nthin),...
    'Units','pixels',...
    'Tag','nthin',...
    'BackGroundColor','w',...
    'Callback',{@XBRV_CB_Set,'nthin'},...
    'Position',[130 340 40 20]);

uicontrol(h.instpanel,...
    'style','Text',...
    'String','Choose Hrms Marker :',...
    'HorizontalAlignment','right',...
    'Units','pixels',...
    'Position',[10 310 115 15]);
str = {'o','+','*','d','h','s','<','>','^','v','p','.'};
val = find(strcmp(str,h.plotspec.HrmsMarker));
h.plothan.plotspec.HrmsMarker = uicontrol(h.instpanel,...
    'Style','popupmenu',...
    'String',str,...
    'Value',val,...
    'Units','pixels',...
    'Tag','hrmsmarker',...
    'BackGroundColor','w',...
    'Callback',{@XBRV_CB_Set,'hrmsmarker'},...
    'Position',[130 310 40 20]);

if ~isempty(which('TODO.m'))
	TODO('all kinds of color settings');
end

%% video control panel
h.contrpanel = uipanel(h.fig,...
    'Units','pixels',...
    'Position',[200 10 790 60]);

h.control.rew = uicontrol(h.contrpanel,...
    'Style','pushbutton',...
    'String','rewind',...
    'Callback',@XBRV_CB_Contr,...
    'Tag','rew',...
    'Enable','on',...
    'Position',[145 10 50 20]);

h.control.stop = uicontrol(h.contrpanel,...
    'Style','pushbutton',...
    'String','stop',...
    'Callback',@XBRV_CB_Contr,...
    'Tag','stop',...
    'Enable','on',...
    'Position',[295 10 50 20]);

h.control.startpause = uicontrol(h.contrpanel,...
    'Style','togglebutton',...
    'String','start',...
    'Callback',@XBRV_CB_Contr,...
    'Tag','start',...
    'Enable','on',...
    'Position',[445 10 50 20]);
 
h.control.forw = uicontrol(h.contrpanel,...
    'Style','pushbutton',...
    'String','to end',...
    'Callback',@XBRV_CB_Contr,...
    'Tag','forw',...
    'Enable','on',...
    'Position',[595 10 50 20]);

h.control.slider = uicontrol(h.contrpanel,...
    'Style','slider',...
    'Callback',@XBRV_CB_Contr,...
    'Tag','slider',...
    'Position',[50 40 690 10]);

%% plot ax
h.plotax = axes('Parent',h.fig,...
    'Units','pixels',...
    'Position',[240 120 700 320]);
xlabel('x [m]');
ylabel('y [m]');
title('test');
hold on
box on

%% info ax
h.infoax = axes('Parent',h.fig,...
    'Units','pixels',...
    'Position',[240 500 700 60]);
hold on
axis off

%% Property grid

com.mathworks.mwswing.MJUtilities.initJIDE;
h.JideList = java.util.ArrayList();
h.JideModel = com.jidesoft.grid.PropertyTableModel(h.JideList);
h.JideModel.expandAll();
h.JideGrid = com.jidesoft.grid.PropertyTable(h.JideModel);
h.JidePane = com.jidesoft.grid.PropertyPane(h.JideGrid);
[h.JSplitPanelMain h.HSplitPanel] = javacomponent(h.JidePane,[1000,10, 290, 580],h.fig);

%% set figure toolbar and buttons
set(h.fig,'Toolbar','Figure');

obj = findall(h.fig,'Type','uitoggletool');
obj = [obj; findall(h.fig,'Type','uipushtool')];

toolname = {...
    'Data Cursor','','';...
    'Rotate 3D','','';...
    'Pan','','';...
    'Zoom Out','','';...
    'Zoom In','',''};

try
    c=load('XBRVicons.mat');
    toolname{3,2} = c.icons.pan;
    toolname{5,2} = c.icons.zoomin16  ;
    toolname{4,2} = c.icons.zoomout16;
catch
    guidisp('No icons could be found');
end
tooltips = get(obj,'ToolTipString');

for itools = 1:length(tooltips)
    if any(strcmp(toolname(:,1),tooltips{itools}))
        tipid = strcmp(toolname,tooltips{itools});
        if ~isempty(toolname{tipid,2})
            set(obj(itools),'Cdata',toolname{tipid,2});
        end
    else
        delete(obj(itools));
    end
end

%% set figure colormap
% navch2 = [0.0706,0.3098,0.7529;0.1183,0.3496,0.7668;0.1659,0.3894,0.7807;0.2136,0.4293,0.7946;0.2612,0.4691,0.8084;0.3089,0.5089,0.8223;0.3566,0.5487,0.8362;0.4042,0.5886,0.8501;0.4519,0.6284,0.8639;0.4996,0.6682,0.8778;0.5472,0.708,0.8917;0.5949,0.7479,0.9056;0.6425,0.7877,0.9194;0.6902,0.8275,0.9333;0.6821,0.8267,0.8978;0.674,0.8259,0.8622;0.6659,0.8251,0.8267;0.6578,0.8243,0.7911;0.6497,0.8235,0.7556;0.6416,0.8227,0.72;0.6335,0.822,0.6844;0.6254,0.8212,0.6489;0.6173,0.8204,0.6133;0.6092,0.8196,0.5778;0.601,0.8188,0.5422;0.5929,0.818,0.5067;0.5848,0.8173,0.4711;0.5767,0.8165,0.4356;0.5686,0.8157,0.4;0.5785,0.8166,0.4054;0.5883,0.8175,0.4108;0.5982,0.8184,0.4161;0.6081,0.8193,0.4215;0.6179,0.8202,0.4269;0.6278,0.8211,0.4323;0.6376,0.822,0.4376;0.6475,0.8229,0.443;0.6574,0.8238,0.4484;0.6672,0.8246,0.4538;0.6771,0.8255,0.4592;0.6869,0.8264,0.4645;0.6968,0.8273,0.4699;0.7067,0.8282,0.4753;0.7165,0.8291,0.4807;0.7264,0.83,0.4861;0.7362,0.8309,0.4914;0.7461,0.8318,0.4968;0.756,0.8327,0.5022;0.7658,0.8336,0.5076;0.7757,0.8345,0.5129;0.7855,0.8354,0.5183;0.7954,0.8363,0.5237;0.8053,0.8372,0.5291;0.8151,0.8381,0.5345;0.825,0.839,0.5398;0.8348,0.8399,0.5452;0.8447,0.8408,0.5506;0.8546,0.8417,0.556;0.8644,0.8426,0.5613;0.8743,0.8435,0.5667;0.8841,0.8444,0.5721;0.894,0.8453,0.5775;0.9039,0.8462,0.5829;0.9137,0.8471,0.5882;];
% wavemap = [0.1569,0.5804,1;0.1683,0.5859,0.9999;0.1798,0.5913,0.9999;0.1912,0.5968,0.9998;0.2027,0.6023,0.9998;0.2141,0.6078,0.9997;0.2256,0.6133,0.9996;0.237,0.6187,0.9996;0.2485,0.6242,0.9995;0.2599,0.6297,0.9994;0.2714,0.6352,0.9994;0.2829,0.6406,0.9993;0.2943,0.6461,0.9993;0.3058,0.6516,0.9992;0.3172,0.6571,0.9991;0.3287,0.6626,0.9991;0.3401,0.668,0.999;0.3516,0.6735,0.9989;0.363,0.679,0.9989;0.3745,0.6845,0.9988;0.3859,0.6899,0.9988;0.3974,0.6954,0.9987;0.4088,0.7009,0.9986;0.4203,0.7064,0.9986;0.4317,0.7119,0.9985;0.4432,0.7173,0.9984;0.4547,0.7228,0.9984;0.4661,0.7283,0.9983;0.4776,0.7338,0.9983;0.489,0.7392,0.9982;0.5005,0.7447,0.9981;0.5119,0.7502,0.9981;0.5234,0.7557,0.998;0.5348,0.7612,0.9979;0.5463,0.7666,0.9979;0.5577,0.7721,0.9978;0.5692,0.7776,0.9978;0.5806,0.7831,0.9977;0.5921,0.7885,0.9976;0.6035,0.794,0.9976;0.615,0.7995,0.9975;0.6265,0.805,0.9974;0.6379,0.8105,0.9974;0.6494,0.8159,0.9973;0.6608,0.8214,0.9973;0.6723,0.8269,0.9972;0.6837,0.8324,0.9971;0.6952,0.8378,0.9971;0.7066,0.8433,0.997;0.7181,0.8488,0.9969;0.7295,0.8543,0.9969;0.741,0.8598,0.9968;0.7524,0.8652,0.9968;0.7639,0.8707,0.9967;0.7754,0.8762,0.9966;0.7868,0.8817,0.9966;0.7983,0.8871,0.9965;0.8097,0.8926,0.9965;0.8212,0.8981,0.9964;0.8326,0.9036,0.9963;0.8441,0.9091,0.9963;0.8555,0.9145,0.9962;0.867,0.92,0.9961;0.8784,0.9255,0.9961;];
% colormap([navch2;wavemap]);
% caxis(h.plotax1,[0 0.5]);
% caxis(h.plotax2,[0.5 1]);

%% save handle information
guidata(h.fig,h);