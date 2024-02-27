function h1 = UCIT_makeUCITConsole
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
% 
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.



appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'frame', 7, ...
    'text', 25, ...
    'pushbutton', 9, ...
    'checkbox', 4, ...
    'popupmenu', 21), ...
    'override', [], ...
    'release', 13, ...
    'resize', 'simple', ...
    'accessibility', 'on', ...
    'mfile', 0, ...
    'callbacks', [], ...
    'singleton', [], ...
    'syscolorfig', [], ...
    'blocking', 0, ...
    'template', 'C:\MATLAB701\toolbox\matlab\uitools\guitemplates\guidetemplate0.fig');
appdata.lastValidTag = 'UCIT_mainWin';
appdata.GUIDELayoutEditor = [];

h1 = figure(...
'Units','characters',...
'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'CloseRequestFcn','UCIT_quit;',...
'Color',[0.2 0.6 0.8],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','UCIT - Universal Coastal Intelligence Toolikit',...
'NumberTitle','off',...
'PaperPosition',[0.635 6.345 20.305 15.228],...
'PaperSize',[20.98404194812 29.67743169791],...
'PaperType',get(0,'defaultfigurePaperType'),...
'Position',[46.2 28.308 102 23.769],...
'Renderer','Painters',...
'RendererMode','manual',...
'Tag','UCIT_mainWin',...
'UserData',[],...
'Behavior',get(0,'defaultfigureBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_mainWin_background';

h2 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ForegroundColor',[0.752941176470588 0.752941176470588 0.752941176470588],...
'ListboxTop',0,...
'Position',[0.00588235294117647 0.00970873786407767 0.98627450980392 0.967637540453074],...
'String',{  '' },...
'Style','frame',...
'Tag','UCIT_mainWin_background',...
...%'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'LinesFrame';

h3 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'CData',[],...
'ForegroundColor',[0.501960784313725 0.501960784313725 0.501960784313725],...
'ListboxTop',0,...
'Position',[0.0215686274509804 0.122977346278317 0.474509803921569 0.401294498381877],...
'String',{  '' },...
'Style','frame',...
'Tag','LinesFrame',...
'UserData',[],...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'TransectsFrame';

h4 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'CData',[],...
'ForegroundColor',[0.501960784313725 0.501960784313725 0.501960784313725],...
'ListboxTop',0,...
'Position',[0.0215686274509804 0.550161812297735 0.474509803921569 0.401294498381877],...
'String',{  '' },...
'Style','frame',...
'Tag','TransectsFrame',...
'UserData',[],...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'frame4';

h5 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'CData',[],...
'ForegroundColor',[0.501960784313725 0.501960784313725 0.501960784313725],...
'ListboxTop',0,...
'Position',[0.0215686274509804 0.0226537216828479 0.956862745098037 0.0906148867313916],...
'String',{  '' },...
'Style','frame',...
'Tag','frame4',...
'UserData',[],...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text1';

h6 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.718446601941748 0.133333333333333 0.0614886731391586],...
'String','Transect ID:',...
'Style','text',...
'Tag','text1',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text2';

h7 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.653721682847896 0.133333333333333 0.0614886731391586],...
'String','Date:',...
'Style','text',...
'Tag','text2',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text3';

h8 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.786407766990291 0.133333333333333 0.0614886731391586],...
'String','Area:',...
'Style','text',...
'Tag','text3',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton1';

h9 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_next(-1,''TransectsTransectID'');',...
'ListboxTop',0,...
'Position',[0.405882352941176 0.718446601941748 0.0392156862745098 0.0647249190938511],...
'String','<',...
'Tag','pushbutton1',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton2';

h10 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_next(-1,''TransectsSoundingID'');',...
'ListboxTop',0,...
'Position',[0.405882352941176 0.656957928802589 0.0392156862745098 0.0647249190938511],...
'String','<',...
'Tag','pushbutton2',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton3';

h11 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_next(1,''TransectsTransectID'');',...
'ListboxTop',0,...
'Position',[0.443137254901961 0.718446601941748 0.0392156862745098 0.0647249190938511],...
'String','>',...
'Tag','pushbutton3',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton4';

h12 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_next(1,''TransectsSoundingID'');',...
'ListboxTop',0,...
'Position',[0.443137254901961 0.656957928802589 0.0392156862745098 0.0647249190938511],...
'String','>',...
'Tag','pushbutton4',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_holdFigure';

h13 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','%automatic',...
'ListboxTop',0,...
'Position',[0.127450980392157 0.0420711974110032 0.245098039215686 0.058252427184466],...
'String','Hold crosssec. fig.',...
'Style','checkbox',...
'Tag','UCIT_holdFigure',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_holdmapFigure';

h14 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','%automatic',...
'CData',[],...
'ListboxTop',0,...
'Position',[0.645098039215686 0.0388349514563107 0.235294117647059 0.0614886731391586],...
'String','Hold overview figure',...
'Style','checkbox',...
'Tag','UCIT_holdmapFigure',...
'UserData',[],...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text4';

h15 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.0313725490196078 0.915857605177994 0.111764705882353 0.058252427184466],...
'String','Transects',...
'Style','text',...
'Tag','text4',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text5';

h16 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0352941176470588 0.220064724919094 0.133333333333333 0.0614886731391586],...
'String','LineID:',...
'Style','text',...
'Tag','text5',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text6';

h17 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.284789644012945 0.133333333333333 0.0614886731391586],...
'String','Date:',...
'Style','text',...
'Tag','text6',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text7';

h18 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.0313725490196078 0.495145631067961 0.0784313725490196 0.0550161812297735],...
'String','Lines',...
'Style','text',...
'Tag','text7',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_holdtimeFigure';

h19 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','%automatic',...
'ListboxTop',0,...
'Position',[0.388235294117647 0.0485436893203883 0.237254901960784 0.0453074433656958],...
'String','Hold timeseries fig.',...
'Style','checkbox',...
'Tag','UCIT_holdtimeFigure',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'GridsFrame';

h20 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ForegroundColor',[0.501960784313725 0.501960784313725 0.501960784313725],...
'ListboxTop',0,...
'Position',[0.503921568627451 0.550161812297735 0.474509803921569 0.401294498381877],...
'String',{  '' },...
'Style','frame',...
'Tag','GridsFrame',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text8';

h21 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.511764705882353 0.922330097087379 0.0862745098039216 0.0517799352750809],...
'String','Grids',...
'Style','text',...
'Tag','text8',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text9';

h22 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.513725490196078 0.86084142394822 0.150980392156863 0.0550161812297735],...
'String','Data type:',...
'Style','text',...
'Tag','text9',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text10';

h23 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.513725490196078 0.72168284789644 0.13921568627451 0.0550161812297735],...
'String','Search window:',...
'Style','text',...
'Tag','text10',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

   h23annotation = uicontrol(...
   'Parent',h1,...
   'Units','normalized',...
   'BackgroundColor',[1 1 1],...
   'ListboxTop',0,...
   'Position',[0.9 0.72168284789644 0.07 0.0614886731391586],...
   'String','(months)',...
   'Style','text',...
   'Tag','text8',...
   ...'Behavior',get(0,'defaultuicontrolBehavior'),...
   'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text11';

h24 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.513725490196078 0.656957928802589 0.127450980392157 0.0485436893203883],...
'String','Thinning factor:',...
'Style','text',...
'Tag','text11',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'GridsDatatype';

h25 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_loadRelevantInfo2Popup(2,2);',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.851132686084142 0.252941176470588 0.0647249190938511],...
'String','Data type (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','GridsDatatype',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'GridsInterval';

h26 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_loadRelevantInfo2Popup(2,4);',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.718446601941748 0.252941176470588 0.0647249190938511],...
'String','Start time (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','GridsInterval',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'GridsSoundingID';

h27 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.637254901960784 0.650485436893204 0.252941176470588 0.0647249190938511],...
'String','Thinning factor:',...
'Style','popupmenu',...
'Value',1,...
'Tag','GridsSoundingID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text12';

h28 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.513725490196078 0.789644012944984 0.150980392156863 0.0550161812297735],...
'String','Start time:',...
'Style','text',...
'Tag','text12',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'GridsName';

h29 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_loadRelevantInfo2Popup(2,3);',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.786407766990291 0.252941176470588 0.0647249190938511],...
'String','Start time (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','GridsName',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text13';

h30 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0313725490196078 0.857605177993528 0.133333333333333 0.0614886731391586],...
'String','Data type:',...
'Style','text',...
'Tag','text13',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'TransectsTransectID';

h31 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_loadRelevantInfo2Popup(1,4);',...
'ListboxTop',0,...
'Position',[0.152941176470588 0.724919093851133 0.252941176470588 0.0647249190938511],...
'String','Transect ID (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','TransectsTransectID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'TransectsSoundingID';

h32 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.152941176470588 0.656957928802589 0.252941176470588 0.0647249190938511],...
'String','Date (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','TransectsSoundingID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'TransectsDatatype';

h33 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_loadRelevantInfo2Popup(1,2);',...
'ListboxTop',0,...
'Position',[0.152941176470588 0.86084142394822 0.252941176470588 0.0647249190938511],...
'String','Data type (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','TransectsDatatype',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'TransectsArea';

h34 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_loadRelevantInfo2Popup(1,3);',...
'ListboxTop',0,...
'Position',[0.152941176470588 0.792880258899676 0.252941176470588 0.0647249190938511],...
'String','Area (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','TransectsArea',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text14';

h35 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.572815533980583 0.133333333333333 0.0614886731391586],...
'String','Actions:',...
'Style','text',...
'Tag','text14',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'TrActions';

h36 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_takeAction(1);',...
'ListboxTop',0,...
'Position',[0.152941176470588 0.572815533980583 0.252941176470588 0.0647249190938511],...
'String','Actions (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','TrActions',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text15';

h37 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.513725490196078 0.56957928802589 0.127450980392157 0.0485436893203883],...
'String','Actions:',...
'Style','text',...
'Tag','text15',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'GrActions';

h38 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_takeAction(2);',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.572815533980583 0.252941176470588 0.0647249190938511],...
'String','Actions (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','GrActions',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'PointsFrame';

h39 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'CData',[],...
'ForegroundColor',[0.501960784313725 0.501960784313725 0.501960784313725],...
'ListboxTop',0,...
'Position',[0.503921568627451 0.122977346278317 0.474509803921569 0.401294498381877],...
'String',{  '' },...
'Style','frame',...
'Tag','PointsFrame',...
'UserData',[],...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text16';

h40 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.515686274509804 0.495145631067961 0.0823529411764706 0.0550161812297735],...
'String','Points',...
'Style','text',...
'Tag','text16',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'LinesLineID';

h41 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Enable','inactive',...
'ListboxTop',0,...
'Position',[0.154901960784314 0.226537216828479 0.252941176470588 0.0647249190938511],...
'String','LineID (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','LinesLineID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'LinesSoundingID';

h42 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_loadRelevantInfo2Popup(3,4);',...
'ListboxTop',0,...
'Position',[0.154901960784314 0.29126213592233 0.252941176470588 0.0647249190938511],...
'String','Date (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','LinesSoundingID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text17';

h43 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0352941176470588 0.352750809061489 0.133333333333333 0.0614886731391586],...
'String','Area:',...
'Style','text',...
'Tag','text17',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text18';

h44 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.420711974110032 0.133333333333333 0.0614886731391586],...
'String',{  'Data type:'; '' },...
'Style','text',...
'Tag','text18',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'LinesArea';

h45 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_loadRelevantInfo2Popup(3,3);',...
'Enable','inactive',...
'ListboxTop',0,...
'Position',[0.154901960784314 0.359223300970874 0.252941176470588 0.0647249190938511],...
'String','Area (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','LinesArea',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'LinesDatatype';

h46 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_loadRelevantInfo2Popup(3,2);',...
'ListboxTop',0,...
'Position',[0.154901960784314 0.427184466019418 0.252941176470588 0.0647249190938511],...
'String','Data type (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','LinesDatatype',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text19';

h47 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.0333333333333333 0.145631067961165 0.133333333333333 0.0614886731391586],...
'String','Actions:',...
'Style','text',...
'Tag','text19',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'LnActions';

h48 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_takeAction(3);',...
'ListboxTop',0,...
'Position',[0.154901960784314 0.145631067961165 0.252941176470588 0.0647249190938511],...
'String','Actions (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','LnActions',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text20';

h49 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.515686274509804 0.288025889967638 0.133333333333333 0.0614886731391586],...
'String','Date:',...
'Style','text',...
'Tag','text20',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text21';

h50 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.515686274509804 0.216828478964401 0.133333333333333 0.0614886731391586],...
'String','DataID:',...
'Style','text',...
'Tag','text21',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'PointsSoundingID';

h51 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_loadRelevantInfo2Popup(4,4);',...
'Enable','inactive',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.29126213592233 0.252941176470588 0.0647249190938511],...
'String','Date (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','PointsSoundingID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'PointsDataID';

h52 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.223300970873786 0.252941176470588 0.0647249190938511],...
'String','DataID (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','PointsDataID',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text22';

h53 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.515686274509804 0.355987055016181 0.133333333333333 0.0614886731391586],...
'String','Station:',...
'Style','text',...
'Tag','text22',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text23';

h54 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.515686274509804 0.420711974110032 0.133333333333333 0.0614886731391586],...
'String',{  'Data type:'; '' },...
'Style','text',...
'Tag','text23',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'PointsStation';

h55 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_loadRelevantInfo2Popup(4,3);',...
'Enable','inactive',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.362459546925566 0.252941176470588 0.0647249190938511],...
'String','Point (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','PointsStation',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'PointsDatatype';

h56 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','UCIT_loadRelevantInfo2Popup(4,2);',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.43042071197411 0.252941176470588 0.0647249190938511],...
'String','Data type (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','PointsDatatype',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'text24';

h57 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.515686274509804 0.145631067961165 0.133333333333333 0.0614886731391586],...
'String','Actions:',...
'Style','text',...
'Tag','text24',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'PtActions';

h58 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','UCIT_takeAction(4);',...
'ListboxTop',0,...
'Position',[0.637254901960784 0.145631067961165 0.252941176470588 0.0647249190938511],...
'String','Actions (load first)',...
'Style','popupmenu',...
'Value',1,...
'Tag','PtActions',...
...'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton5';

% h59 = uicontrol(...
% 'Parent',h1,...
% 'Units','normalized',...
% 'Callback','UCIT_next(-1,''GridsInterval'');',...
% 'ListboxTop',0,...
% 'Position',[0.890196078431373 0.711974110032362 0.0392156862745098 0.0647249190938511],...
% 'String','<',...
% 'Tag','pushbutton5',...
% ...'Behavior',get(0,'defaultuicontrolBehavior'),...
% 'CreateFcn', {@local_CreateFcn, '', appdata} );
% 
% appdata = [];
% appdata.lastValidTag = 'pushbutton6';

% h60 = uicontrol(...
% 'Parent',h1,...
% 'Units','normalized',...
% 'Callback','UCIT_next(-1,''GridsSoundingID'');',...
% 'ListboxTop',0,...
% 'Position',[0.890196078431373 0.650485436893204 0.0392156862745098 0.0647249190938511],...
% 'String','<',...
% 'Tag','pushbutton6',...
% ...'Behavior',get(0,'defaultuicontrolBehavior'),...
% 'CreateFcn', {@local_CreateFcn, '', appdata} );
% 
% appdata = [];
% appdata.lastValidTag = 'pushbutton7';

% h61 = uicontrol(...
% 'Parent',h1,...
% 'Units','normalized',...
% 'Callback','UCIT_next(1,''GridsInterval'');',...
% 'ListboxTop',0,...
% 'Position',[0.927450980392157 0.711974110032362 0.0392156862745098 0.0647249190938511],...
% 'String','>',...
% 'Tag','pushbutton7',...
% ...'Behavior',get(0,'defaultuicontrolBehavior'),...
% 'CreateFcn', {@local_CreateFcn, '', appdata} );
% 
% appdata = [];
% appdata.lastValidTag = 'pushbutton8';

% h62 = uicontrol(...
% 'Parent',h1,...
% 'Units','normalized',...
% 'Callback','UCIT_next(1,''GridsSoundingID'');',...
% 'ListboxTop',0,...
% 'Position',[0.927450980392157 0.650485436893204 0.0392156862745098 0.0647249190938511],...
% 'String','>',...
% 'Tag','pushbutton8',...
% ...'Behavior',get(0,'defaultuicontrolBehavior'),...
% 'CreateFcn', {@local_CreateFcn, '', appdata} );
% 
% appdata = [];
% appdata.lastValidTag = 'UCIT_fileMenu';

h63 = uimenu(...
'Parent',h1,...
'Callback','%automatic',...
'Label','File',...
'Tag','UCIT_fileMenu',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_Process_Data';

h64 = uimenu(...
'Parent',h63,...
'Label','Process data',...
'Tag','UCIT_Process_Data',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_printMenu';

h65 = uimenu(...
'Parent',h63,...
'Callback','UCIT_print;',...
'Label','Print',...
'Tag','UCIT_printMenu',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_2';

h66 = uimenu(...
'Parent',h63,...
'Callback','UCIT_quit',...
'Label','Quit',...
'Tag','Untitled_2',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_batchMenu';

h67 = uimenu(...
'Parent',h1,...
'Label','Batch',...
'Tag','UCIT_batchMenu',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_batchCommand';

h68 = uimenu(...
'Parent',h67,...
'Callback','UCIT_batchCommand;',...
'Label','Batch command',...
'Tag','UCIT_batchCommand',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_plotMenu';

h69 = uimenu(...
'Parent',h1,...
'Label','Plot',...
'Tag','UCIT_plotMenu',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_prepareMenu';

h70 = uimenu(...
'Parent',h69,...
'Callback','UCIT_preparePlot(''plotWindow'');',...
'Label','Prepare plot',...
'Tag','UCIT_prepareMenu',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'Options';

h71 = uimenu(...
'Parent',h1,...
'Callback','UCIT_Options',...
'Label','Options',...
'Tag','Options',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_Help';

h72 = uimenu(...
'Parent',h1,...
'Label','Help',...
'Tag','UCIT_Help',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'McTools_pages';

h73 = uimenu(...
'Parent',h72,...
'Callback','UCIT_Help(1)',...
'Label','McTools pages',...
'Tag','McTools_pages',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'UCIT_user_guide';

h74 = uimenu(...
'Parent',h72,...
'Callback','UCIT_Help(2)',...
'Label','UCIT user guide',...
'Tag','UCIT_user_guide',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.lastValidTag = 'Tips_and_tricks';

h75 = uimenu(...
'Parent',h72,...
'Callback','UCIT_Help(3)',...
'Label','Tips & Tricks',...
'Tag','Tips_and_tricks',...
'Behavior',get(0,'defaultuimenuBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );



% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   eval(createfcn);
end
