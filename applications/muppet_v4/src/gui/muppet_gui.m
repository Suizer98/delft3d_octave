function muppet_gui(varargin)

global figureiconfile

if isempty(varargin)
    newSession('firsttime');
    handles=getHandles;
    figureiconfile=[handles.settingsdir 'icons' filesep 'deltares.gif'];
    gui_newWindow(handles,'xmldir',handles.xmlguidir,'xmlfile','muppetgui.xml','modal',0,'resize',0, ...
        'getfcn',@getHandles,'setfcn',@setHandles,'tag','muppetgui','Color',[0.941176 0.941176 0.941176], ...
        'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
    set(gcf,'CloseRequestFcn','set(0,''ShowHiddenHandles'',''on'');delete(get(0,''Children''))');
    muppet_refreshColorMap(handles);
    muppet_updateGUI;
    delete(handles.splashscreen);
else
    opt=lower(varargin{1});
    switch opt
        case{'newsession'}
            newSession;
        case{'opensession'}
            openSession;
        case{'savesession'}
            saveSession;
        case{'savesessionas'}
            saveSessionAs;
        case{'adddatasetfromurl'}
            addDatasetfromURL;
        case{'exit'}
            close(gcf);
        case{'importlayout'}
            importLayout;
        case{'savelayout'}            
            exportLayout;
        case{'generatelayout'}            
            generateLayout;
        case{'showcolors'}            
            showColors;
        case{'editcolormaps'}            
            editColorMaps;
        case{'saveinteractivetext'}
            saveInteractiveText;
        case{'saveinteractivepolylines'}
            saveInteractivePolylines;
        case{'deltaresonline'}
             web('http://www.deltares.nl/en');
        case{'muppethelp'}
             web('https://publicwiki.deltares.nl/display/OET/Muppet');
        case{'aboutmuppet'}
            aboutMuppet;
        case{'coordinateconversion'}
            coordinateconversion;
        case{'reloadxml'}
            reloadXmlFiles;
        case{'selectdataset'}
            muppet_selectDataset;
        case{'adddataset'}
            addDataset;
        case{'deletedataset'}
            deleteDataset;
        case{'adddatasettosubplot'}
            addDatasetToSubplot;
        case{'combinedatasets'}
            combineDatasets;
        case{'selectsubplot'}
            selectSubplot;
        case{'addsubplot'}
            addSubplot;
        case{'deletesubplot'}
            deleteSubplot;
        case{'moveupsubplot'}
            moveUpSubplot;
        case{'movedownsubplot'}
            moveDownSubplot;
        case{'selectdatasetinsubplot'}
            selectDatasetInSubplot;
        case{'editplotoptions'}
            editPlotOptions;
        case{'removedatasetinsubplot'}
            removeDatasetInSubplot;
        case{'moveupdatasetinsubplot'}
            moveUpDatasetInSubplot;
        case{'movedowndatasetinsubplot'}
            moveDownDatasetInSubplot;
        case{'applytoallaxes'}            
            applyToAllAxes;
        case{'toggleaxesequal'}            
            toggleAxesEqual;
        case{'editxylim'}
            editXYLim(varargin{2});
        case{'pushrightaxis'}
            editRightAxis;
        case{'pushadvancedaxisoptions'}
            editAdvancedAxisOptions;
        case{'push3doptions'}
            options3D;
        case{'selectcoordinatesystem'}
            selectCoordinateSystem;
        case{'selectmap'}
            selectMap;
        case{'select3d'}
            select3D;
        case{'editlegend'}
            editLegend;
        case{'editvectorlegend'}
            editVectorLegend;
        case{'togglecolorbar'}
            toggleColorBar;
        case{'editcolorbar'}
            editColorBar;
        case{'togglevectorlegend'}
            toggleVectorLegend;
        case{'togglenortharrow'}
            toggleNorthArrow;
        case{'editnortharrow'}
            editNorthArrow;
        case{'togglescalebar'}
            toggleScaleBar;
        case{'editscalebar'}
            editScaleBar;
        case{'editclim'}
            editCLim;
        case{'editcustomcontours'}
            muppet_editCustomContours;
        case{'selectframe'}
            selectFrame;
        case{'pushsubplottext'}
            editSubplotText;
        case{'editframetext'}
            editFrameText;
        case{'selectformat'}
            selectFormat;
        case{'selectportrait','selectlandscape'}
            selectOrientation;
        case{'exportfigure'}
            exportFigure;
        case{'plotfigure'}
            plotFigure;
        case{'editanimationsettings'}
            editAnimationSettings;
        case{'makeanimation'}
            makeAnimation;
    end
end

%%
function newSession(varargin)
if isempty(varargin)
    % gui already open
    iopt=1;
else
    % gui has not yet been opened
    iopt=0;
end
handles=getHandles;
filename=[handles.settingsdir 'layouts' filesep 'default.mup'];
handles.sessionfile='';
[handles,ok]=muppet_newSession(handles,filename);
if ok
    handles=muppet_updateDatasetNames(handles);
    handles=muppet_updateFigureNames(handles);
    handles=muppet_updateSubplotNames(handles);
    handles=muppet_updateDatasetInSubplotNames(handles);
    handles=muppet_initializeAnimationSettings(handles);
    setHandles(handles);    
    if iopt
        muppet_refreshColorMap(handles);
        muppet_selectDataset;
        muppet_updateGUI;
    end
end

%%
function openSession
handles=getHandles;
[filename pathname]=uigetfile('*.mup');
if pathname~=0
    handles.sessionfile=filename;
    cd(pathname);

    wb = waitbox('Reading session file ...');
    try
        [handles,ok]=muppet_newSession(handles,[pathname filename]);
        close(wb);
    catch
        close(wb);
        muppet_giveWarning('text','An error occured while reading session file!');
        return
    end
        
    if ok
        handles=muppet_updateDatasetNames(handles);
        handles=muppet_updateFigureNames(handles);
        handles=muppet_updateSubplotNames(handles);
        handles=muppet_updateDatasetInSubplotNames(handles);
        % Compute scale of 2d map plots
        for ifig=1:handles.nrfigures
            for isub=1:handles.figures(ifig).figure.nrsubplots
                switch lower(handles.figures(ifig).figure.subplots(isub).subplot.type)
                    case{'map'}
                        handles.figures(ifig).figure.subplots(isub).subplot=muppet_updateLimits(handles.figures(ifig).figure.subplots(isub).subplot,'computescale');
                end
            end
        end        
        setHandles(handles);
        muppet_selectDataset;
        muppet_updateGUI;
    end
else
    return
end

%%
function saveSession
handles=getHandles;
if isempty(handles.sessionfile)
    [filename pathname]=uiputfile('*.mup');
    if pathname~=0
        handles.sessionfile=[pathname filename];
        setHandles(handles);
    else
      return
    end
end
muppet_saveSessionFile(handles,handles.sessionfile,0);

%%
function saveSessionAs
handles=getHandles;
[filename pathname]=uiputfile('*.mup');
if pathname~=0
  handles.sessionfile=[pathname filename];
  cd(pathname);
  setHandles(handles);
  muppet_saveSessionFile(handles,handles.sessionfile,0);
end

%%
function addDatasetfromURL
handles=getHandles;
muppet_selectDatasetFromURLType(handles);
muppet_selectDataset;
muppet_updateGUI;

% handles=muppet_datasetURL_GUI(handles,[1 1 5 5],0);

%%
function importLayout

handles=getHandles;
[filename pathname]=uigetfile([handles.settingsdir 'layouts' filesep '*.mup']);
if pathname~=0
    handles.nrfigures=0;
    handles.figures=[];
    handles.activefigure=1;
    handles.activesubplot=1;
    handles.activedatasetinsubplot=1;
    [handles,ok]=muppet_readSessionFile(handles,[pathname filename],1);    
    handles=muppet_updateSubplotNames(handles);
    handles=muppet_updateDatasetInSubplotNames(handles);
    setHandles(handles);
    muppet_updateGUI;
else
    return
end

%%
function exportLayout

handles=getHandles;
[filename pathname]=uiputfile([handles.settingsdir 'layouts' filesep '*.mup']);
if pathname~=0
    sessionfile=[pathname filename];
    muppet_saveSessionFile(handles,sessionfile,1);
else
    return
end

%%
function generateLayout

handles=getHandles;

s=handles.newlayout;

[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'generatelayout.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);

if ok
    
    ifig=handles.activefigure;
    
    handles.newlayout=s;
    
    button='Yes';
    
    if handles.figures(ifig).figure.nrsubplots>0
        button = questdlg('Delete existing subplots?','','Cancel','No','Yes','Yes');
    end
    
    if ~strcmp(button,'Cancel')
        
        if strcmp(button,'Yes')
            handles.figures(ifig).figure.nrsubplots=0;
            handles.figures(ifig).figure.subplots=[];
            handles.activesubplot=1;
            handles.activedatasetinsubplot=1;
        end
        
        nplots0=handles.figures(ifig).figure.nrsubplots;

        % Check for annotations
        if handles.figures(ifig).figure.nrsubplots>0
            if strcmpi(handles.figures(ifig).figure.subplots(nplots0).subplot.type,'annotation')
                nplots0=handles.figures(ifig).figure.nrsubplots-1;
                nrnew=s.numbervertical*s.numberhorizontal;
                nran=nplots0+nrnew+1;
                handles.figures(ifig).figure.subplots(nran).subplot=handles.figures(ifig).figure.subplots(nplots0+1).subplot;
            end            
        end
        
        n=0;
        for jj=1:s.numbervertical
            for ii=1:s.numberhorizontal
                n=n+1;
                plt=muppet_setDefaultAxisProperties;
                plt.name=['Subplot ' num2str(n+nplots0)];
                plt.position(1)=s.originhorizontal+(ii-1)*(s.sizehorizontal+s.spacinghorizontal);
                plt.position(2)=s.originvertical+(s.numbervertical-jj)*(s.sizevertical+s.spacingvertical);
                plt.position(3)=s.sizehorizontal;
                plt.position(4)=s.sizevertical;
                handles.figures(ifig).figure.subplots(n+nplots0).subplot=plt;
            end
        end
        
        handles.figures(ifig).figure.nrsubplots=length(handles.figures(ifig).figure.subplots);        
        
        handles=muppet_updateSubplotNames(handles);
        handles=muppet_updateDatasetInSubplotNames(handles);
        muppet_refreshColorMap(handles);
        
        setHandles(handles);

        muppet_updateGUI;
        
    end
    
end

%%
function showColors
muppet_showColors;

%%
function editColorMaps

handles=getHandles;

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;

clmap=plt.colormap;

icl=strmatch(clmap,handles.colormapnames,'exact');

% Open color map GUI
clm.Name=clmap;
clm.Space='RGB';
clm.Index=handles.colormaps(icl).val(:,1);
clm.Colors=handles.colormaps(icl).val(:,2:4)/255;
clm.AlternatingColors=0;
CMStructOut=md_colormap(clm);

plt.colormap=CMStructOut.Name;

% Read new color maps
handles.colormaps=muppet_importColorMaps([handles.settingsdir 'colormaps' filesep]);

% Color map names
for ii=1:length(handles.colormaps)
    handles.colormapnames{ii}=handles.colormaps(ii).name;
end

muppet_refreshColorMap(handles);

setHandles(handles);

%%
function saveInteractiveText
% Saves text for active subplot
handles=getHandles;
iok=0;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
% First check if 
for id=1:plt.nrdatasets
    if strcmpi(plt.datasets(id).dataset.plotroutine,'interactive text')
        iok=1;
    end
end

if ~iok
    muppet_giveWarning('text','There is no interactive text in this subplot!');
    return
end

[filename, pathname] = uiputfile('*.ann');

if pathname~=0
    fid=fopen([pathname filename],'wt');
    for id=1:plt.nrdatasets
        if strcmpi(plt.datasets(id).dataset.plotroutine,'interactive text')
            str=['"' plt.datasets(id).dataset.text '"'];
            str=[str repmat(' ',1,max(1,25-length(str)))];
            fprintf(fid,'%s %14.7e %14.7e %7.2f %7.2f\n',str,plt.datasets(id).dataset.x,plt.datasets(id).dataset.y,0,0);
        end
    end
end
fclose(fid);

%%
function saveInteractivePolylines
% Saves polylines for active subplot
handles=getHandles;
iok=0;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
% First check if there are polylines
for id=1:plt.nrdatasets
    if strcmpi(plt.datasets(id).dataset.plotroutine,'interactive polyline')
        iok=1;
    end
end

if ~iok
    muppet_giveWarning('text','There are no interactive polylines in this subplot!');
    return
end

[filename, pathname] = uiputfile('*.pol');

if pathname~=0
    fid=fopen([pathname filename],'wt');
    for id=1:plt.nrdatasets
        if strcmpi(plt.datasets(id).dataset.plotroutine,'interactive polyline')
            fprintf(fid,'%s\n',plt.datasets(id).dataset.name);
            fprintf(fid,'%i %i\n',length(plt.datasets(id).dataset.x),2);
            for ip=1:length(plt.datasets(id).dataset.x)
                fprintf(fid,'%14.7e %14.7e\n',plt.datasets(id).dataset.x(ip),plt.datasets(id).dataset.y(ip));
            end
        end
    end
end
fclose(fid);

%%
function aboutMuppet
handles=getHandles;
muppet_aboutMuppet(handles);

%%
function reloadXmlFiles
handles=getHandles;
handles=muppet_readXmlFiles(handles);
setHandles(handles);

%%
function addDataset

handles=getHandles;

ilast=strmatch(lower(handles.lastfiletype),lower(handles.filetypes),'exact');
filterspec{1,1}=handles.filetype(ilast).filetype.filterspec;
filterspec{1,2}=handles.filetype(ilast).filetype.title;

filetypes{1}=handles.filetype(ilast).filetype.name;

n=1;
for ii=1:length(handles.filetype)
    if ii~=ilast
        if isfield(handles.filetype(ii).filetype,'filterspec')
            n=n+1;
            filetypes{n}=handles.filetype(ii).filetype.name;
            filterspec{n,1}=handles.filetype(ii).filetype.filterspec;
            filterspec{n,2}=handles.filetype(ii).filetype.title;
        end
    end
end

[filename, pathname, filterindex] = uigetfile(filterspec,'Select file to open',handles.lastfolder);

if pathname~=0
    handles.lastfiletype=filetypes{filterindex};
    handles.lastfolder=pathname;
    setHandles(handles);
    muppet_datasetGUI('makewindow','filename',[pathname filename],'filetype',filetypes{filterindex});
    muppet_selectDataset;
end

%%
function deleteDataset
handles=getHandles;
name=handles.datasets(handles.activedataset).dataset.name;
% Check if dataset is used in any subplot
ok=1;
for ifig=1:handles.nrfigures
    if ok
        for isub=1:handles.figures(ifig).figure.nrsubplots
            if handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets>0
                id=muppet_findIndex(handles.figures(ifig).figure.subplots(isub).subplot.datasets,'dataset','name',name);
                if ~isempty(id)
                    ok=0;
                    muppet_giveWarning('text','Cannot delete this dataset as it is used in a subplot!');
                    break
                end
            end
        end
    else
        break
    end
end
if ok
    [handles.datasets handles.activedataset handles.nrdatasets] = UpDownDeleteStruc(handles.datasets, handles.activedataset, 'delete');
    handles=muppet_updateDatasetNames(handles);
    setHandles(handles);
    muppet_selectDataset;
end

%%
function addDatasetToSubplot
handles=getHandles;
handles=muppet_addDatasetToSubplot(handles);
setHandles(handles);

%%
function combineDatasets
muppet_editCombinedDatasets;
handles=getHandles;
handles.nrdatasets=length(handles.datasets);
handles=muppet_updateDatasetNames(handles);
setHandles(handles);

%%
function selectSubplot
handles=getHandles;
handles=muppet_updateDatasetInSubplotNames(handles);
handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset;
muppet_refreshColorMap(handles);
txt1=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.name;
txt2=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.type;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.coordinatesystem.text=[txt1 ' - ' txt2];
setHandles(handles);

%%
function addSubplot
handles=getHandles;
handles=muppet_addSubplot(handles,[1 1 5 5],0);
setHandles(handles);

%%
function deleteSubplot
handles=getHandles;
iplt=handles.activesubplot;
if strcmpi(handles.figures(handles.activefigure).figure.subplots(iplt).subplot.type,'annotation')
    handles.figures(handles.activefigure).figure.nrannotations=0;
end
[handles.figures(handles.activefigure).figure.subplots iplt nrsub] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots, iplt, 'delete');
handles.figures(handles.activefigure).figure.nrsubplots=nrsub;
handles.figures(handles.activefigure).figure.activesubplot=iplt;
handles.activesubplot=iplt;
handles.activedatasetinsubplot=1;
if nrsub>0
    handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(iplt).subplot.activedataset;
else
    handles.activesubplot=1;
    handles=muppet_initializeSubplot(handles,handles.activefigure,1);
end
handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
muppet_refreshColorMap(handles);
setHandles(handles);

%%
function moveUpSubplot
handles=getHandles;
iplt=handles.activesubplot;
[handles.figures(handles.activefigure).figure.subplots iplt nrsub] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots, iplt, 'up');
handles.figures(handles.activefigure).figure.nrsubplots=nrsub;
handles.figures(handles.activefigure).figure.activesubplot=iplt;
handles.activesubplot=iplt;
handles.activedatasetinsubplot=1;
if nrsub>0
    handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(iplt).subplot.activedataset;
end
handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function moveDownSubplot
handles=getHandles;
iplt=handles.activesubplot;
[handles.figures(handles.activefigure).figure.subplots iplt nrsub] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots, iplt, 'down');
handles.figures(handles.activefigure).figure.nrsubplots=nrsub;
handles.figures(handles.activefigure).figure.activesubplot=iplt;
handles.activesubplot=iplt;
handles.activedatasetinsubplot=1;
if nrsub>0
    handles.activedatasetinsubplot=handles.figures(handles.activefigure).figure.subplots(iplt).subplot.activedataset;
end
handles=muppet_updateSubplotNames(handles);
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function selectDatasetInSubplot
% Select dataset in subplot
handles=getHandles;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=handles.activedatasetinsubplot;
setHandles(handles);

%%
function editPlotOptions
handles=getHandles;
handles=muppet_editPlotOptions(handles);
setHandles(handles);

%%
function removeDatasetInSubplot
% Remove selected dataset from subplot
handles=getHandles;
id=handles.activedatasetinsubplot;
[handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets id nrd] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets, id, 'delete');
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets=nrd;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=id;
handles.activedatasetinsubplot=id;
switch handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type
    case{'annotation'}
        handles.figures(handles.activefigure).figure.nrannotations=handles.figures(handles.activefigure).figure.nrannotations-1;
end
handles=muppet_updateDatasetInSubplotNames(handles);
idelplot=0;
if nrd==0
    handles.activedatasetinsubplot=1;
    switch handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type
        case{'annotation'}
            idelplot=1;
        otherwise
            handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=muppet_setDefaultAxisProperties(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot);
            handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type='unknown';
    end
end
setHandles(handles);
if idelplot
    deleteSubplot;
end

%%
function moveUpDatasetInSubplot
handles=getHandles;
id=handles.activedatasetinsubplot;
[handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets id nrd] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets, id, 'up');
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets=nrd;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=id;
handles.activedatasetinsubplot=id;
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function moveDownDatasetInSubplot
handles=getHandles;
id=handles.activedatasetinsubplot;
[handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets id nrd] = UpDownDeleteStruc(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.datasets, id, 'down');
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.nrdatasets=nrd;
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.activedataset=id;
handles.activedatasetinsubplot=id;
handles=muppet_updateDatasetInSubplotNames(handles);
setHandles(handles);

%%
function applyToAllAxes
handles=getHandles;
handles=muppet_applyToAllAxes(handles);
setHandles(handles);

%%
function toggleAxesEqual
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.axesequal==0
  handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scale=[];
else
  scale=muppet_computeScale([plt.xmin plt.xmax],[plt.ymin plt.ymax],[plt.position(3) plt.position(4)],plt.coordinatesystem.type);
  handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scale=scale;
end
setHandles(handles);

%%
function selectCoordinateSystem

handles=getHandles;

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;

if ~isfield(plt,'oldcoordinatesystem')
    plt.oldcoordinatesystem.name='unspecified';
    plt.oldcoordinatesystem.type='projected';
end

oldname=plt.oldcoordinatesystem.name;
oldtype=plt.oldcoordinatesystem.type;
newname=plt.coordinatesystem.name;
newtype=plt.coordinatesystem.type;

% Check if coordinate system changed
if ~strcmpi(newname,oldname) || ~strcmpi(newtype,oldtype)
    
    % Change projection type
    switch newtype
        case{'geographic'}
            plt.projection='mercator';
        case{'projected'}
            plt.projection='equirectangular';
    end
    
    if ~strcmpi(oldname,'unspecified')
        % Adjust axes
        [plt.xmin,plt.ymin]=convertCoordinates(plt.xmin,plt.ymin,'persistent','CS1.name',oldname, ...
            'CS1.type',oldtype,'CS2.name',newname,'CS2.type',newtype);
        [plt.xmax,plt.ymax]=convertCoordinates(plt.xmax,plt.ymax,'persistent','CS1.name',oldname, ...
            'CS1.type',oldtype,'CS2.name',newname,'CS2.type',newtype);
        plt=muppet_updateLimits(plt,'updateall');
    end
        
    plt.oldcoordinatesystem=plt.coordinatesystem;
    
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
    
    setHandles(handles);
    
end

%%
function editXYLim(opt)
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
switch lower(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type)
    case{'map'}
        plt=muppet_updateLimits(plt,opt);
        handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editRightAxis
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'rightaxis.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=s;
    setHandles(handles);
end

%%
function editAdvancedAxisOptions
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'advancedaxisoptions.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=s;
    setHandles(handles);
end

%%
function options3D
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
[plt,ok]=gui_newWindow(plt, 'xmldir', handles.xmlguidir, 'xmlfile', 'options3d.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
    setHandles(handles);
end

%%
function selectMap
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
for id=1:plt.nrdatasets
    switch lower(plt.datasets(id).dataset.plotroutine)
        case {'3d surface'}
            plt.datasets(id).dataset.plotroutine='contour map';
    end
end
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
setHandles(handles);

%%
function select3D
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
for id=1:plt.nrdatasets
    switch lower(plt.datasets(id).dataset.plotroutine)
        case {'contour map','contour map and lines','patches','contour lines','shades map'}
            plt.datasets(id).dataset.plotroutine='3d Surface';
    end
end
handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
setHandles(handles);

%%
function editSubplotText
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'subplottextoptions.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=s;
    setHandles(handles);
end

%%
function editLegend
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.legend;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'legend.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.legend=s;
    setHandles(handles);
end

%%
function editVectorLegend
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.vectorlegend;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'vectorlegend.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.vectorlegend=s;
    setHandles(handles);
end

%%
function toggleColorBar
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.colorbar.position)
    % No colorbar yet
    x0=plt.position(1)+plt.position(3)-2.0;
    y0=plt.position(2)+1.5;
    x1=0.5;
    y1=plt.position(4)-3;
    plt.colorbar.position=[x0 y0 x1 y1];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editColorBar
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.colorbar;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'colorbar.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.colorbar=s;
    setHandles(handles);
end

%%
function toggleVectorLegend
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.vectorlegend.position)
    % No vector legend yet
    x0=plt.position(1)+1.0;
    y0=plt.position(2)+1.0;
    plt.vectorlegend.position=[x0 y0];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function toggleNorthArrow
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.northarrow.position)
    % No position data available
    x0=1.5;
    y0=plt.position(4)-1.5;
    sz=1.0;
    angle=90;
    plt.northarrow.position=[x0 y0 sz angle];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editNorthArrow
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.northarrow;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'northarrow.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.northarrow=s;
    setHandles(handles);
end


%%
function toggleScaleBar
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
if isempty(plt.scalebar.position)
    % No position data available
    x0=1.5;
    y0=1.5;
    z0=round(0.04*plt.scale);
    plt.scalebar.position=[x0 y0];
    plt.scalebar.length=z0;
    plt.scalebar.text=[num2str(z0) ' m'];
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
setHandles(handles);

%%
function editScaleBar
handles=getHandles;
s=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scalebar;
[s,ok]=gui_newWindow(s, 'xmldir', handles.xmlguidir, 'xmlfile', 'scalebar.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.scalebar=s;
    setHandles(handles);
end

%%
function editCLim
handles=getHandles;
plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
cdif=plt.cmax-plt.cmin;
cmin=plt.cmin;
cmax=plt.cmax;
cstep=plt.cstep;

if cmax<=cmin || cstep>cdif || cstep<0.01*cdif
else
    muppet_refreshColorMap(handles);
end

setHandles(handles);

%%
function selectFrame
handles=getHandles;
fig=handles.figures(handles.activefigure).figure;
k=strmatch(lower(fig.frame),lower(handles.frames.names),'exact');
frame=handles.frames.frame(k).frame;
if isfield(frame,'text')
    for itxt=1:length(frame.text)
        if isfield(frame.text(itxt).text,'defaulttext')
            fig.frametext(itxt).frametext.text=frame.text(itxt).text.defaulttext;
        end
    end
end
handles.figures(handles.activefigure).figure=fig;
setHandles(handles);

%%
function editFrameText
handles=getHandles;
fig=handles.figures(handles.activefigure).figure;
k=strmatch(lower(fig.frame),lower(handles.frames.names),'exact');
frame=handles.frames.frame(k).frame;
[fig,ok]=muppet_selectFrameText(fig,frame);
if ok
    handles.figures(handles.activefigure).figure=fig;
    setHandles(handles);
end

%%
function selectOrientation
handles=getHandles;
fig=handles.figures(handles.activefigure).figure;
width=fig.width;
height=fig.height;
fig.width=height;
fig.height=width;
% Subplots
for isub=1:fig.nrsubplots
    if strcmpi(fig.orientation(1),'l')
        pos(1)=fig.subplots(isub).subplot.position(2);
        pos(2)=fig.height-(fig.subplots(isub).subplot.position(1)+fig.subplots(isub).subplot.position(3));
        pos(3)=fig.subplots(isub).subplot.position(4);
        pos(4)=fig.subplots(isub).subplot.position(3);
    else
        pos(1)=fig.width-(fig.subplots(isub).subplot.position(2)+fig.subplots(isub).subplot.position(4));
        pos(2)=fig.subplots(isub).subplot.position(1);
        pos(3)=fig.subplots(isub).subplot.position(4);
        pos(4)=fig.subplots(isub).subplot.position(3);
    end
    fig.subplots(isub).subplot.position=pos;
end
% Annotations
for j=1:fig.nrannotations
    isub=fig.nrsubplots;
    if strcmpi(fig.orientation(1),'l')
        pos(1)=fig.subplots(isub).subplot.datasets(j).dataset.position(2);
        pos(2)=fig.height-fig.subplots(isub).subplot.datasets(j).dataset.position(1);
        pos(3)=fig.subplots(isub).subplot.datasets(j).dataset.position(4);
        pos(4)=-fig.subplots(isub).subplot.datasets(j).dataset.position(3);
    else
        pos(1)=fig.width-fig.subplots(isub).subplot.datasets(j).dataset.position(2);
        pos(2)=fig.subplots(isub).subplot.datasets(j).dataset.position(1);
        pos(3)=-fig.subplots(isub).subplot.datasets(j).dataset.position(4);
        pos(4)=fig.subplots(isub).subplot.datasets(j).dataset.position(3);
    end
    switch fig.subplots(isub).subplot.datasets(j).dataset.plotroutine
        case{'textbox','rectangle','ellipse'}
            pos(1)=min(pos(1),pos(1)+pos(3));
            pos(2)=min(pos(2),pos(2)+pos(4));
            pos(3)=abs(pos(3));
            pos(4)=abs(pos(4));
    end
    fig.subplots(isub).subplot.datasets(j).dataset.position=pos;
end        
handles.figures(handles.activefigure).figure=fig;
setHandles(handles);

%%
function selectFormat
handles=getHandles;
name=handles.figures(handles.activefigure).figure.outputfile(1:end-4);
switch lower(handles.figures(handles.activefigure).figure.format)
    case {'png'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.png'];
    case {'jpeg'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.jpg'];
    case {'tiff'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.tif'];
    case {'pdf'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.pdf'];
    case {'eps'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.eps'];
    case {'epsc'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.eps'];
    case {'eps2'}
        handles.figures(handles.activefigure).figure.outputfile=[name '.ps2'];
end
setHandles(handles);

%%
function exportFigure
handles=getHandles;
muppet_exportFigure(handles,handles.activefigure,'guiexport');

%%
function plotFigure
muppet_preview;

%%
function editAnimationSettings
muppet_animationSettings;

%%
function makeAnimation

handles=getHandles;

% Check animation size
nhor=floor(handles.figures(handles.activefigure).figure.width*handles.figures(handles.activefigure).figure.resolution/2.54);
nver=floor(handles.figures(handles.activefigure).figure.height*handles.figures(handles.activefigure).figure.resolution/2.54);

switch lower(handles.animationsettings.format)
    case{'mp4'}
        if nhor>1920 || nver>1080
            muppet_giveWarning('text','Figures to large for animation! Please reduce the resolution.');
            return
        end
    case{'avi'}
        if nhor>2000 || nver>2000
            muppet_giveWarning('text','Animation output very large! Consider reducing the resolution.');
        end
end

% aviops=handles.animationsettings.avioptions;
% if isempty(aviops)
%     aviops=writeavi('getoptions',24);
%     handles.animationsettings.avioptions=aviops;
%     setHandles(handles);
% end
muppet_makeAnimation(handles,handles.activefigure);

%%
function coordinateconversion

handles=getHandles;
SuperTrans(handles.EPSG);
