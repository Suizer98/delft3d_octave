function muppet_initializegui

% Initialization of GUI settings

global figureiconfile

handles=getHandles;

% Output options
handles.outputformats={'png','jpeg','tiff','pdf','eps','epsc','eps2'};
handles.outputresolutiontexts={'50','100','150','200','300','450','600'};
handles.outputresolutions=[50 100 150 200 300 450 600];
if verLessThan('matlab', '8.4')
    handles.renderers={'ZBuffer','Painters','OpenGL'};
else
    handles.renderers={'Painters','OpenGL'};
end


% Color map names
for ii=1:length(handles.colormaps)
    handles.colormapnames{ii}=handles.colormaps(ii).name;
end

% Date formats
dat=datenum(2005,04,28,14,38,25);
for ii=1:length(handles.dateformats)
    switch lower(handles.dateformats{ii})
        case{'none'}
            handles.dateformattexts{ii}='None';
        otherwise
            handles.dateformattexts{ii}=datestr(dat,handles.dateformats{ii});
    end
end

handles.datasettext1='';
handles.datasettext2='';
handles.datasettext3='';
handles.datasettext4='';
handles.datasettext5='';

handles.lastfiletype='delft3d';
handles.lastfolder='';

handles.newlayout.numberhorizontal=3;
handles.newlayout.sizehorizontal=4;
handles.newlayout.spacinghorizontal=1.2;
handles.newlayout.originhorizontal=3.5;
handles.newlayout.numbervertical=4;
handles.newlayout.sizevertical=4.5;
handles.newlayout.spacingvertical=1.2;
handles.newlayout.originvertical=5;

figureiconfile=[handles.settingsdir 'icons' filesep 'deltares.gif'];

setHandles(handles);
