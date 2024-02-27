function h1 = detran_selectInputSettingsFigure

h1 = figure('MenuBar','none','Name','Detran Delft3D input settings','NumberTitle','off','Position',[100 100 600 200],'Resize','off','Tag','figure1');

h2 = uibuttongroup('Parent',h1,'Title','Delft3D output file type','Tag','uipanel1','Position',[0.04 0.3 0.28 0.6]);
h3 = uicontrol('Parent',h2,'units','normalized','Position',[0.1 0.8 0.9 0.2],'String','Trim-file(s)','Style','radiobutton','Value',1,'Tag','radiobutton3');
h4 = uicontrol('Parent',h2,'units','normalized','Position',[0.1 0.6 0.9 0.2],'String','Trih-file(s)','Style','radiobutton','Tag','radiobutton4');

h5 = uibuttongroup('Parent',h1,'Title','Delft3D simulation type','Tag','uipanel2','Position',[0.36 0.3 0.28 0.6]);
h6 = uicontrol('Parent',h5,'units','normalized','Position',[0.1 0.8 0.9 0.2],'String','Single file','Style','radiobutton','Value',1,'Tag','radiobutton5');
h7 = uicontrol('Parent',h5,'units','normalized','Position',[0.1 0.6 0.9 0.2],'String','Multiple files','Style','radiobutton','Tag','radiobutton6');
h8 = uicontrol('Parent',h5,'units','normalized','Position',[0.1 0.4 0.9 0.2],'String','Mormerge simulation','Style','radiobutton','Tag','radiobutton7');

h9 = uibuttongroup('Parent',h1,'Title','Transport type','Tag','uipanel3','Position',[0.68 0.3 0.28 0.6]);
h10 = uicontrol('Parent',h9,'units','normalized','Position',[0.1 0.8 0.9 0.2],'String','Mean','Style','radiobutton','Value',1,'Tag','radiobutton14');
h11 = uicontrol('Parent',h9,'units','normalized','Position',[0.1 0.6 0.9 0.2],'String','Instant','Style','radiobutton','Tag','radiobutton15');

h13 = uicontrol('Parent',h1,'units','normalized','Position',[0.8 0.05 0.16 0.1],'String','Next >>','Style','pushbutton','Tag','pushbutton1','callback',{@detran_selectInputSettingsConfirm});
h14 = uicontrol('Parent',h1,'units','normalized','Position',[0.6 0.05 0.16 0.1],'String','Cancel','Style','pushbutton','Tag','pushbutton2','callback',{@detran_selectInputSettingsConfirm});


function detran_selectInputSettingsConfirm(hObject,eventdata)

if strcmp(get(hObject,'String'),'Next >>')
    h1 = get(hObject,'Parent');
    fileType  = get(get(findobj(h1,'tag','uipanel1'),'SelectedObject'),'String');
    simType   = get(get(findobj(h1,'tag','uipanel2'),'SelectedObject'),'String');
    transType = get(get(findobj(h1,'tag','uipanel3'),'SelectedObject'),'String');
    set(h1,'UserData',{fileType,simType,lower(transType)});
    uiresume(h1);
else
    h1 = get(hObject,'Parent');
    set(h1,'UserData',{[],[],[]});
    uiresume(h1);
end
