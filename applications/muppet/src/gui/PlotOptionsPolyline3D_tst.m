function PlotOptionsPolyline3D_tst(varargin)

h=guidata(findobj('Name','Muppet'));

handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;

PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
 
PutInCentre(hObject);
 
set(handles.EditLineWidth,'String',num2str(PlotOptions.LineWidth));

selectLineStyle('create','selectLineStyle');
selectLineStyle('setvalue','selectLineStyle',PlotOptions.LineStyle);

nrcol=size(h.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=h.DefaultColors(i).Name;
end

set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectColor,'Value',i);
 
set(handles.ToggleFillPolygons,'Value',PlotOptions.FillPolygons);

if ~ischar(lower(PlotOptions.FillColor))
    PlotOptions.FillColor='black';
end
set(handles.SelectFillColor,'String',handles.Colors);
i=strmatch(lower(PlotOptions.FillColor),lower(handles.Colors),'exact');
set(handles.SelectFillColor,'Value',i);

if PlotOptions.FillPolygons==0
    set(handles.SelectFillColor,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.SelectFillColor,'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
end

set(handles.EditLegendText,'String',PlotOptions.LegendText);
 
set(handles.EditElevationLower,'String',num2str(PlotOptions.Elevations(1)));
set(handles.EditElevationUpper,'String',num2str(PlotOptions.Elevations(2)));

setValue('editElevationLower',num2str(PlotOptions.Elevations(1)));

% Update handles structure
guidata(gcf, handles);
 
 
%%
function pushOK

handles=guidata(gcf);

h=guidata(findobj('Name','Muppet'));

i=handles.i;
j=handles.j;
k=handles.k;
 
h.Figure(i).Axis(j).Plot(k).LineWidth=str2double(get(handles.EditLineWidth,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LineStyle=selectLineStyle('getvalue','selectLineStyle');
h.Figure(i).Axis(j).Plot(k).LegendText=get(handles.EditLegendText,'String');
h.Figure(i).Axis(j).Plot(k).FillPolygons=get(handles.ToggleFillPolygons,'Value');
h.Figure(i).Axis(j).Plot(k).FillColor=handles.Colors{get(handles.SelectFillColor,'Value')};
h.Figure(i).Axis(j).Plot(k).Elevations(1)=str2double(get(handles.EditElevationLower,'String'));
h.Figure(i).Axis(j).Plot(k).Elevations(2)=str2double(get(handles.EditElevationUpper,'String'));

guidata(findobj('Name','Muppet'),h);

close(gcf);

%%
function pushCancel
 
close(gcf);

%%
function out=selectLineStyle(opt,tag,varargin)

h=findobj(gcf,'Tag',tag);

switch lower(opt)
    case{'create'}
        str={'-','--','-.',':','none'};
        set(h,'String',str);
    case{'setvalue'}
        value=varargin{1};
        switch lower(value)
            case {'-'}
                i=1;
            case {'--'}
                i=2;
            case {'-.'}
                i=3;
            case {':'}
                i=4;
            case {''}
                i=5;
        end
        set(h,'Value',i);
    case{'getvalue'}
        ii=get(h,'Value');
        lineStyles={'-','--','-.',':',''};
        out=lineStyles{ii};
    case{'enable'}
        set(h,'Enable','on');
    case{'disable'}
        set(h,'Enable','off');
    case{'visible'}
        set(h,'Visible','on');
    case{'invisible'}
        set(h,'Visible','off');
end
