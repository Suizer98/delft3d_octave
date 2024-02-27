function knowledgegraphs(session_filename) %#ok<INUSD>
% KNOWLEDGEGRAPHS OpenEarth utility for the visualisation and analysis of knowledge graphs
%
% KNOWLEDGEGRAPHS is a utility for the visualisation and analysis of knowledge graphs.
%
% Syntax:
%   knowledgegraphs(session)
%
% Input:
%   session = input argument session contains information on the vertices and edges (sparse matrix form)
%
% Output:
%
% See also: kngr_getOntology, kngr_getDefaultSession, kngr_getPosition, kngr_plotGraph
 
%--------------------------------------------------------------------------------
% Copyright(c) Delft University of Technology 2004 - 2011  FOR INTERNAL USE ONLY
% Version:  Version 1.0, December 2007 (Version 1.0, December 2007)
% By:      <Mark van Koningsveld (email:mark.vankoningsveld@deltares.nl)>
%--------------------------------------------------------------------------------

clc
% try warning off; delete('lastsession.mat'); warning on; end

global ontology; 
global session;

%% start always in the path with DelftConStruct
cd(fileparts(which('knowledgegraphs'))); curdir=pwd;

%% add all paths in the DelftConStruct directory
addpath(genpath(curdir));

%% ontology info is global info
ontology = kngr_getOntology;

%% show splash screen
frame=splash([fileparts(which('knowledgegraph')) filesep 'gui' filesep 'DelftConStructsplash.jpg'],15);

%% prepare application figure
try close(figure(10)); end %#ok<TRYNC>

fig=figure(10); clf; warning off
fh = get(fig,'JavaFrame'); % Get Java Frame 
fh.setFigureIcon(javax.swing.ImageIcon('gui/DeltaresLogo.gif'));
warning on

%% set gui properties
set(fig,'Name','Knowledgegraph: Knowledge Graph Analysis Tool','NumberTitle','Off','Units','normalized','position',[0    0.5000    0.5000    0.4388]);
set(fig,'Menubar','none','Toolbar','figure','Units','pixels','Position',kngr_getPosition(0.04, 1, 0.96));
set(fig,'color','w')

%% get default settings for startup (preferably the lastsession info) session info is global info 
if nargin == 0
    kngr_getDefaultSession
else
    load(session_filename);
end

%% delete non-used buttons
tbh = findall(fig,'Type','uitoolbar');
delete(findall(tbh,'TooltipString','New Figure'));
delete(findall(tbh,'TooltipString','Open File'));
delete(findall(tbh,'TooltipString','Save Figure'));
delete(findall(tbh,'TooltipString','Print Figure'));
delete(findall(tbh,'TooltipString','Data Cursor'));
delete(findall(tbh,'TooltipString','Insert Colorbar'));
delete(findall(tbh,'TooltipString','Insert Legend'));
delete(findall(tbh,'TooltipString','Hide Plot Tools'));
delete(findall(tbh,'TooltipString','Show Plot Tools'));
delete(findall(tbh,'TooltipString','Show Plot Tools and Dock Figure'));
% delete(findall(tbh,'TooltipString','Rotate 3D'));
delete(findall(tbh,'TooltipString','Pan'));

%% add customised toolbar buttons
adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','addRelation');
set(adj,'ClickedCallback','kngr_addRelation');
set(adj,'Tag','addRelation');
set(adj,'cdata',kngr_makeIcon('gui\icons\up-32x322.bmp',60));

adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','deleteRelation');
set(adj,'ClickedCallback','kngr_deleteRelation');
set(adj,'Tag','deleteRelation');
set(adj,'cdata',kngr_makeIcon('gui\icons\down-32x322.bmp',60));

adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','deleteVertex');
set(adj,'ClickedCallback','kngr_deleteVertex');
set(adj,'Tag','deleteVertex');
set(adj,'cdata',kngr_makeIcon('gui\icons\down-32x322.bmp',60));

adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Get dictionary info for word');
set(adj,'ClickedCallback','kngr_getdictionaryInfoForWord;');
set(adj,'Tag','getDictionaryInfoForWord');
set(adj,'cdata',kngr_makeIcon('gui\icons\add-32x322.bmp',60));

%% add GUI objects (lowerLeft,partofscreen_Hor,partofscreen_Vrt,scnsize,bdwidth,topbdwidth) 
popuptxt = {'select relation ...', ontology.type};
uicontrol(fig,'Style','text'     ,'Tag','lblfrmtxt','String','From-vertex:'       ,'Position',kngr_getPosition(0.94, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','edit'     ,'Tag','frmtxt'   ,'String','enter from-vertex'  ,'Position',kngr_getPosition(0.92, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','text'     ,'Tag','lbltotxt' ,'String','To-vertex:'         ,'Position',kngr_getPosition(0.88, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','edit'     ,'Tag','totxt'    ,'String','enter to-vertex'    ,'Position',kngr_getPosition(0.86, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','text'     ,'Tag','lbltype'  ,'String','Relation type:'     ,'Position',kngr_getPosition(0.82, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','Popupmenu','Tag','type'     ,'String',popuptxt             ,'Position',kngr_getPosition(0.80, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);

scrsize  = get(gcf,'position');
Position = kngr_getPosition(0.01,  .40, 0.2,  get(gcf,'position'),10,40);
uicontrol(fig,'Style','text'     ,'Tag','lblin' ,'String','Inward relations:'  ,'Position',[Position(1)+.2*scrsize(3)  Position(2)+15 Position(3) Position(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','edit'     ,'Tag','txtin' ,'String',''                   ,'Position',[Position(1)+.2*scrsize(3)  Position(2)    Position(3) Position(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2,'enable','inactive');
uicontrol(fig,'Style','text'     ,'Tag','lblout','String','Outward relations:' ,'Position',[Position(1)+.6*scrsize(3)  Position(2)+15 Position(3) Position(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','edit'     ,'Tag','txtout','String',''                   ,'Position',[Position(1)+.6*scrsize(3)  Position(2)    Position(3) Position(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2,'enable','inactive');
uicontrol(fig,'Style','text'     ,'Tag','lblDic','String','Dictionary result:' ,'Position',kngr_getPosition(0.76, .15, 0.1,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','edit'     ,'Tag','txtDic','String',''                   ,'Position',kngr_getPosition(0.34, .15, 0.5,  get(gcf,'position'),10,40),'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2,'enable','inactive');

%% set callbacks
set(fig,'DeleteFcn','kngr_deleteFcn_DelftConStruct');
set(fig,'ResizeFcn','kngr_resizeFcn_DelftConStruct');

%% plot default graph (preferably last session info)
axes;set(gca,'visible','off')
kngr_plotGraph(fig)
try %#ok<TRYNC>
    maximize(gcf);
end

%% hide splash screen
frame.hide
