function UIEditAnnotationOptions(varargin)

if strcmp(get(gcf,'SelectionType'),'open')
    mpt=findobj('Name','Muppet');
    handles=guidata(mpt);
    h=get(gcf,'CurrentObject');
    n=get(h,'UserData');
    i=n(1);
    j=n(2);
    pos=get(h,'Position');
    sz=handles.Figure(i).PaperSize;
    handles.Figure(i).Annotation(j).Position(1)=pos(1)*sz(1);
    handles.Figure(i).Annotation(j).Position(2)=pos(2)*sz(2);
    handles.Figure(i).Annotation(j).Position(3)=pos(3)*sz(1);
    handles.Figure(i).Annotation(j).Position(4)=pos(4)*sz(2);
    handles=EditAnnotationOptions('handles',handles,'i',i,'j',j);
    AddAnnotation(handles,i,j,'change');
    guidata(mpt,handles);
end
