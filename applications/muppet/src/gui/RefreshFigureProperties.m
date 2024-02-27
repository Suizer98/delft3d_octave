function handles=RefreshFigureProperties(handles)

ifig=handles.ActiveFigure;

for i=1:handles.NrFigures
    str{i}=handles.Figure(i).Name;
end
str{i+1}='Edit Figures ...';

set(handles.SelectFigure,'String',str);
set(handles.SelectFigure,'Value',ifig);

set(handles.EditOutputFile, 'String', handles.Figure(ifig).FileName);
 
switch lower(handles.Figure(ifig).Format),
    case {'png'}
        i=1;
    case {'jpeg','jpg'}
        i=2;
    case {'tiff','tff','tif'}
        i=3;
    case {'pdf'}
        i=4;
    case {'eps','ps'}
        i=5;
    case {'eps2','ps2'}
        i=6;
end
set(handles.SelectOutputFormat, 'Value', i);
 
switch lower(handles.Figure(ifig).Renderer),
    case {'zbuffer'}
        i=1;
    case {'painters'}
        i=2;
    case {'opengl'}
        i=3;
end
set(handles.SelectRenderer, 'Value', i);
 
switch lower(handles.Figure(ifig).Resolution),
    case {50}
        i=1;
    case {100}
        i=2;
    case {150}
        i=3;
    case {200}
        i=4;
    case {300}
        i=5;
    case {450}
        i=6;
    case {600}
        i=7;
end
set(handles.SelectResolution, 'Value', i);
 
i=1;
for j=1:size(handles.Frames,2)
    if strcmp(lower(handles.Figure(ifig).Frame),lower(handles.Frames(j).Name))
        i=j;
    end
end
set(handles.SelectFrame,'Value',i);
 
switch lower(handles.Figure(ifig).Orientation),
    case {'p'}
        i1=1;
        i2=0;
    case {'l'}
        i1=0;
        i2=1;
end
set(handles.TogglePortrait,'Value',i1);
set(handles.ToggleLandscape,'Value',i2);
 
set(handles.EditPaperWidth,'String',num2str(handles.Figure(ifig).PaperSize(1)));
set(handles.EditPaperHeight,'String',num2str(handles.Figure(ifig).PaperSize(2)));
 
nrcol=length(handles.DefaultColors);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end
handles.Colors{nrcol+1}='none';
set(handles.SelectFigureColor,'String',handles.Colors);
i=strmatch(lower(handles.Figure(ifig).BackgroundColor),lower(handles.Colors),'exact');

set(handles.SelectFigureColor,'Value',i);

