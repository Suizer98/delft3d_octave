function UIAddAnnotation(usd)

h=usd.h;
typ=get(h,'Tag');

mpt=findobj('Name','Muppet');
handles=guidata(mpt);

i=get(gcf,'UserData');
j=handles.Figure(i).NrAnnotations+1;

if handles.Figure(i).NrAnnotations==0
    % New Annotation Layer
    handles.AddSubplotAnnotations=1;
    handles=AddSubplot(handles);
end
isub=handles.Figure(i).NrSubplots;

handles.Figure(i).Axis(isub).Nr=j;
handles.Figure(i).NrAnnotations=j;

figsz=handles.Figure(i).PaperSize;
usd.x=usd.x*figsz(1);
usd.y=usd.y*figsz(2);

switch(typ),
    case{'arrow','doublearrow','line'}
    otherwise
        x1=min(usd.x);
        x2=max(usd.x);
        y1=min(usd.y);
        y2=max(usd.y);
        usd.x=[x1 x2];
        usd.y=[y1 y2];
end

handles.Figure(i).Annotation(j).Position=[0 0 0 0];
handles.Figure(i).Annotation=matchstruct(handles.DefaultAnnotationOptions,handles.Figure(i).Annotation,j);
handles.Figure(i).Annotation(j).Name=[typ ' ' num2str(j)];
handles.Figure(i).Annotation(j).Type=typ;
handles.Figure(i).Annotation(j).Position=[usd.x(1) usd.y(1) usd.x(2)-usd.x(1) usd.y(2)-usd.y(1)];
if strcmp(typ,'textbox')
    handles.Figure(i).Annotation(j).String='Textbox';
    handles.Figure(i).Annotation(j).Box=1;
end
switch(typ),
    case{'arrow','doublearrow'}
        handles.Figure(i).Annotation(j).LineWidth=2;
    otherwise
        handles.Figure(i).Annotation(j).LineWidth=0.5;
end

set(h,'Tag',typ,'UserData',[i,j]);
AddAnnotation(handles,i,j,'change');

handles.Figure(i).Axis(isub).Nr=j;
handles.Figure(i).Axis(isub).Plot(j).Name=handles.Figure(i).Annotation(j).Name;

handles=RefreshSubplots(handles);
handles=RefreshDatasetsInSubplot(handles);
figure(i);
guidata(mpt,handles);

set(0,'userdata',[]);
SetPlotEdit(1);

set(gcf,'CurrentObject',h);
SelectAxis;
