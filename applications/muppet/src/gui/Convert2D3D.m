function handles=Convert2D3D(handles)

ifig=handles.ActiveFigure;
j=handles.ActiveSubplot;
k=handles.Figure(ifig).Axis(j).Nr;

if strcmp(lower(handles.Figure(ifig).Axis(j).PlotType),'3d')
    handles.Figure(ifig).Axis(j).XGrid=1;
    handles.Figure(ifig).Axis(j).YGrid=1;
    handles.Figure(ifig).Axis(j).ZGrid=1;
    for i=1:k
        switch lower(handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine),
            case {'plotcontourmap','plotcontourlines','plotcontourmaplines','3dcrosssectionscalar'}
                handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine='Plot3DSurface';
            case {'plotpolygon','plotpolygons','plotlandboundary','fillpolygon','fillpolygons','plotpolyline'},
                handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine='PlotPolygon3D';
            case {'addtext','plotsamples'},
                handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine='unknown';
        end
    end
else
    for i=1:k
        switch lower(handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine),
            case {'plot3dsurface'}
                handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine='PlotContourMap';
            case {'plotpolygon3d'},
                handles.Figure(ifig).Axis(j).Plot(i).PlotRoutine='PlotPolygon';
        end
    end
end
