function output=EditFrameText(h,iii)

handles.output=h;
i=h.ActiveFigure;
handles.Figure=h.Figure(i);
handles.DefaultColors=h.DefaultColors;

MakeNewWindow('Edit Frame Text',[480 500]);

for ii=1:length(h.Frames)
    fr{ii}=lower(h.Frames(ii).Name);
end
ii=strmatch(lower(handles.Figure.Frame),fr,'exact');
handles.NrText=h.Frames(ii).TextNumber;
for ii=1:handles.NrText
    uicontrol(gcf,'Style','text','String',['Frame Text ' num2str(ii)],'Position',[20 480-ii*35-4 65 25],'HorizontalAlignment','right');
    handles.EditFrameText(ii)=uicontrol(gcf,'Style','edit','String',handles.Figure.FrameText(ii).Text,'Position',[90 480-ii*35 320 25],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
    hh=uicontrol(gcf,'Style','pushbutton','String','Font','Position',[420 480-ii*35 40 25]);
    set(hh,'CallBack',{@PushFont,ii});
end

h=uicontrol(gcf,'Style','pushbutton','String','OK','Position',[390 30 60 20]);
set(h,'CallBack',{@PushOK});
h=uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[320 30 60 20]);
set(h,'CallBack',{@PushCancel});

if handles.NrText>0
    uicontrol(handles.EditFrameText(iii));
end

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);
output=handles.output;

close(gcf);

function PushOK(hObject,eventdata)

handles=guidata(gcf);
h=guidata(findobj('Name','Muppet'));
i=h.ActiveFigure;
for ii=1:handles.NrText
    h.Figure(i).FrameText(ii).Text=get(handles.EditFrameText(ii),'String');
    h.Figure(i).FrameText(ii).Font=handles.Figure.FrameText(ii).Font;
    h.Figure(i).FrameText(ii).Size=handles.Figure.FrameText(ii).Size;
    h.Figure(i).FrameText(ii).Angle=handles.Figure.FrameText(ii).Angle;
    h.Figure(i).FrameText(ii).Weight=handles.Figure.FrameText(ii).Weight;
    h.Figure(i).FrameText(ii).Color=handles.Figure.FrameText(ii).Color;
end
handles.output=h;
guidata(gcf,handles);
uiresume;

function PushCancel(hObject,eventdata)

uiresume;


function PushFont(hObject,eventdata,i)

handles=guidata(gcf);
Font.Type=handles.Figure.FrameText(i).Font;
Font.Size=handles.Figure.FrameText(i).Size;
Font.Weight=handles.Figure.FrameText(i).Weight;
Font.Angle=handles.Figure.FrameText(i).Angle;
Font.Color=handles.Figure.FrameText(i).Color;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Figure.FrameText(i).Font=Font.Type;
handles.Figure.FrameText(i).Size=Font.Size;
handles.Figure.FrameText(i).Angle=Font.Angle;
handles.Figure.FrameText(i).Weight=Font.Weight;
handles.Figure.FrameText(i).Color=Font.Color;
guidata(gcf,handles);
