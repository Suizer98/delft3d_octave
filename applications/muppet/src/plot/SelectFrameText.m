function SelectFrameText(varargin)

h=get(gcf,'CurrentObject');
n=get(h,'UserData');
i=n(1);
j=n(2);
hh=get(gcf,'SelectionType');
handles=guidata(findobj('Name','Muppet'));
i0=handles.ActiveFigure;
if strcmp(hh,'open')
    handles.ActiveFigure=i;
    handles=EditFrameText(handles,j);
    h=findobj(i,'tag','frametext');
    for ii=1:length(h)
        n=get(h(ii),'UserData');
        j=n(2);
        if length(handles.Figure(i).FrameText(j).Text)>0
            set(h(ii),'String',handles.Figure(i).FrameText(j).Text);
            set(h(ii),'Color',FindColor(handles.Figure(i).FrameText(j).Color));
        end
        set(h(ii),'FontName',handles.Figure(i).FrameText(j).Font);
        set(h(ii),'FontSize',handles.Figure(i).FrameText(j).Size*handles.Figure(i).FontRed);
        set(h(ii),'FontAngle',handles.Figure(i).FrameText(j).Angle);
    end
    handles.ActiveFigure=i0;
    guidata(handles.Muppet,handles);
end
