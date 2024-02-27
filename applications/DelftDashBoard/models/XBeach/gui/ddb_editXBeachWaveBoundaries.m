function ddb_editXBeachWaveBoundaries

ddb_refreshScreen('Waves','Boundaries');
handles=getHandles;

str={'instat =0','instat = 1','instat = 2','instat = 3','instat = 4','instat = 5','instat = 6'};
handles.GUIHandles.TextWaveForcing = uicontrol(gcf,'Style','text', 'String','Wave Forcing','Position',[60 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditWaveForcing= uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).instat,'Position',[140 120 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.EditWaveHrms = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).Hrms),'Position',[360 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaveHrms = uicontrol(gcf,'Style','text', 'String','Hrms','Position',[280 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditWaveTm01 = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).Trep),'Position',[360 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaveTm01 = uicontrol(gcf,'Style','text', 'String','Trep','Position',[280 86 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditWaveTlong = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).Tlong),'Position',[360 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaveTlong = uicontrol(gcf,'Style','text', 'String','Tlong','Position',[280 56 80 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.PushOpenWaveSpectrum = uicontrol(gcf,'Style','pushbutton','String','Open spectrum file','Position',[280 120 130 20],'Tag','UIControl');
handles.GUIHandles.TextOpenWaveSpectrum = uicontrol(gcf,'Style','text','String',['File : ',handles.model.xbeach.domain(ad).bcfile],'Position',[420 116  400 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.PushOpenWaveTimeSeries = uicontrol(gcf,'Style','pushbutton','String','Open Time Series','Position',[280 60 130 20],'Tag','UIControl');
handles.GUIHandles.TextOpenWaveTimeSeries = uicontrol(gcf,'Style','text','String',['File : ',handles.model.xbeach.domain(ad).tsfile],'Position',[420 56  400 20],'HorizontalAlignment','left','Tag','UIControl');


set(handles.GUIHandles.EditWaveForcing,'CallBack',{@EditWaveForcing_CallBack});
set(handles.GUIHandles.EditWaveHrms,'CallBack',{@EditWaveHrms_CallBack});
set(handles.GUIHandles.EditWaveTm01,'CallBack',{@EditWaveTm01_CallBack});
set(handles.GUIHandles.EditWaveTlong,'CallBack',{@EditWaveTlong_CallBack});
set(handles.GUIHandles.PushOpenWaveSpectrum,'CallBack',{@PushOpenWaveSpectrum_CallBack});
set(handles.GUIHandles.PushOpenWaveTimeSeries,'CallBack',{@PushOpenWaveTimeSeries_CallBack});

handles=Refresh(handles);   

setHandles(handles);

%%
function EditWaveForcing_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).instat=get(hObject,'Value');
handles=Refresh(handles); 
setHandles(handles);

%%
function EditWaveHrms_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).Hrms=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditWaveTm01_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).Trep=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditWaveTlong_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).Tlong=str2num(get(hObject,'String'));
setHandles(handles);

%%
function PushOpenWaveTimeSeries_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.ezs', 'Select Time Series File');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.model.xbeach.domain(ad).tsfile=filename;
set(handles.TextOpenWaveTimeSeries,'String',['File : ' filename]);
setHandles(handles);

%%
function PushOpenWaveSpectrum_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('Select Spectrum File');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.model.xbeach.domain(ad).bcfile=filename;
set(handles.TextOpenWaveSpectrum,'String',['File : ' filename]);
setHandles(handles);

%%
function handles=Refresh(handles)

n1=get(handles.GUIHandles.EditWaveForcing,'Value');
switch n1,
    case 1
        set(handles.GUIHandles.EditWaveForcing,'Visible','on');
        set(handles.GUIHandles.TextWaveForcing,'Visible','on');
        set(handles.GUIHandles.EditWaveHrms,'Visible','on');
        set(handles.GUIHandles.TextWaveHrms,'Visible','on');
        set(handles.GUIHandles.EditWaveTm01,'Visible','on');
        set(handles.GUIHandles.TextWaveTm01,'Visible','on');
        set(handles.GUIHandles.EditWaveTlong,'Visible','off');
        set(handles.GUIHandles.TextWaveTlong,'Visible','off');
        set(handles.GUIHandles.PushOpenWaveSpectrum,'Visible','off');
        set(handles.GUIHandles.TextOpenWaveSpectrum,'Visible','off');
        set(handles.GUIHandles.PushOpenWaveTimeSeries,'Visible','off');
        set(handles.GUIHandles.TextOpenWaveTimeSeries,'Visible','off');
    case 2
        set(handles.GUIHandles.EditWaveForcing,'Visible','on');
        set(handles.GUIHandles.TextWaveForcing,'Visible','on');
        set(handles.GUIHandles.EditWaveHrms,'Visible','on');
        set(handles.GUIHandles.TextWaveHrms,'Visible','on');
        set(handles.GUIHandles.EditWaveTm01,'Visible','on');
        set(handles.GUIHandles.TextWaveTm01,'Visible','on');
        set(handles.GUIHandles.EditWaveTlong,'Visible','on');
        set(handles.GUIHandles.TextWaveTlong,'Visible','on');
        set(handles.GUIHandles.PushOpenWaveSpectrum,'Visible','off');
        set(handles.GUIHandles.TextOpenWaveSpectrum,'Visible','off');
        set(handles.GUIHandles.PushOpenWaveTimeSeries,'Visible','off');
        set(handles.GUIHandles.TextOpenWaveTimeSeries,'Visible','off');
    case {3,4}
        set(handles.GUIHandles.EditWaveForcing,'Visible','on');
        set(handles.GUIHandles.TextWaveForcing,'Visible','on');
        set(handles.GUIHandles.EditWaveHrms,'Visible','on');
        set(handles.GUIHandles.TextWaveHrms,'Visible','on');
        set(handles.GUIHandles.EditWaveTm01,'Visible','on');
        set(handles.GUIHandles.TextWaveTm01,'Visible','on');
        set(handles.GUIHandles.EditWaveTlong,'Visible','off');
        set(handles.GUIHandles.TextWaveTlong,'Visible','off');
        set(handles.GUIHandles.PushOpenWaveSpectrum,'Visible','off');
        set(handles.GUIHandles.TextOpenWaveSpectrum,'Visible','off');
        set(handles.GUIHandles.PushOpenWaveTimeSeries,'Visible','on');
        set(handles.GUIHandles.TextOpenWaveTimeSeries,'Visible','on');
    case {5,6,7}   
        set(handles.GUIHandles.EditWaveForcing,'Visible','on');
        set(handles.GUIHandles.TextWaveForcing,'Visible','on');
        set(handles.GUIHandles.EditWaveHrms,'Visible','off');
        set(handles.GUIHandles.TextWaveHrms,'Visible','off');
        set(handles.GUIHandles.EditWaveTm01,'Visible','off');
        set(handles.GUIHandles.TextWaveTm01,'Visible','off');
        set(handles.GUIHandles.EditWaveTlong,'Visible','off');
        set(handles.GUIHandles.TextWaveTlong,'Visible','off');
        set(handles.GUIHandles.PushOpenWaveSpectrum,'Visible','on');
        set(handles.GUIHandles.TextOpenWaveSpectrum,'Visible','on');
        set(handles.GUIHandles.PushOpenWaveTimeSeries,'Visible','off');
        set(handles.GUIHandles.TextOpenWaveTimeSeries,'Visible','off');
end


