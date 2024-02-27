function AddModel


fig0=gcf;
fig=MakeNewWindow('Add Model',[210 170],'modal');

bckcol=get(gcf,'Color');

handles.textMDF  = uicontrol(gcf,'Style','text','Position',[30 130 150 30],'String','','HorizontalAlignment','left','BackgroundColor',bckcol,'Tag','UIControl');
handles.textName = uicontrol(gcf,'Style','text','Position',[10 66  45 20],'String','Name','HorizontalAlignment','right','BackgroundColor',bckcol,'Tag','UIControl');
handles.editName = uicontrol(gcf,'Style','edit','Position',[60 70 120 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.selectMDF  = uicontrol(gcf,'Style','pushbutton','Position',[ 30 105 150 20],'String','Select File','Tag','UIControl');
handles.pushOK     = uicontrol(gcf,'Style','pushbutton','Position',[110  30  70 20],'String','OK','Tag','UIControl');
handles.pushCancel = uicontrol(gcf,'Style','pushbutton','Position',[ 30  30  70 20],'String','Cancel','Tag','UIControl');

set(handles.pushOK     ,'CallBack',{@PushOK_CallBack});
set(handles.pushCancel ,'CallBack',{@PushCancel_CallBack});
set(handles.selectMDF  ,'CallBack',{@SelectMDF_CallBack});

handles.mDFFile='';

guidata(gcf,handles);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
name=get(handles.editName,'String');
if isempty(handles.mDFFile)
    GiveWarning('warning','First select mdf file')
elseif isempty(deblank(name))
    GiveWarning('warning','First give a model name')
else
    hm=guidata(findobj('Tag','MainWindow'));
    hm.nrModels=hm.nrModels+1;
    i=hm.nrModels;
    hm=InitializeModel(hm,i);
    hm.models(i).name=name;
    k=hm.ActiveContinent;
    hm.models(i).continent=hm.continentAbbrs{k};
    hm.modelNames{i}=name;
    hm=DetermineModelsInContinent(hm);
    guidata(findobj('Tag','MainWindow'),hm);
    close(gcf);
    RefreshScreen;
end

%%
function PushCancel_CallBack(hObject,eventdata)
close(gcf);

%%
function SelectMDF_CallBack(hObject,eventdata)
handles=guidata(gcf);
[filename, pathname, filterindex] = uigetfile('*.mdf', 'Select mdf file');
if pathname~=0
    handles.mDFFile=filename;
    handles.mDFPath=pathname;
    set(handles.textMDF,'String',[pathname filename]);
    guidata(gcf,handles);
end






