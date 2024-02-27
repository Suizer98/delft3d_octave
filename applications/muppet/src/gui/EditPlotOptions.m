function handles=EditPlotOptions(handles)

i=handles.ActiveFigure;
j=handles.ActiveSubplot;
k=handles.ActiveDatasetInSubplot;

if j>0
    if strcmpi(handles.Figure(i).Axis(j).PlotType,'annotations')
        handles=EditAnnotationOptions('handles',handles,'i',i,'j',k);
    else
        if handles.Figure(i).Axis(j).Nr>0
            m=FindDatasetNr(handles.Figure(i).Axis(j).Plot(k).Name,handles.DataProperties);
            typ=handles.DataProperties(m).Type;
            switch lower(typ),
                case {'2dscalar','3dcrosssectionscalar','timestack'}
                    switch lower(handles.Figure(i).Axis(j).PlotType)
                        case{'2d','timestack'}
                            handles=PlotOptions2DMap('handles',handles);
                        otherwise
                            handles=PlotOptions3DMap('handles',handles);
                    end
                case {'2dvector','3dcrosssectionvector'}
                    handles=PlotOptions2DVector('handles',handles);
                case {'timeseries','xyseries','bar'}
                    handles=PlotOptionsXY('handles',handles);
                case {'polyline'}
                    switch lower(handles.Figure(i).Axis(j).PlotType),
                        case {'2d','xyseries'}
                            handles=PlotOptionsPolyline('handles',handles);
                        case {'3d'}
                            handles=PlotOptionsPolyline3D('handles',handles);
                    end
                case {'grid','3dcrosssectiongrid'}
                    if strcmp(handles.Figure(i).Axis(j).PlotType,'2d')
                        handles=PlotOptionsGrid('handles',handles);
                    end
                case {'annotation'}
                    handles=PlotOptionsAnnotation('handles',handles);
                case {'samples'}
                    handles=PlotOptionsSamples('handles',handles);
                case {'crosssections'}
                    handles=PlotOptionsCrossSections('handles',handles);
                case {'kubint'}
                    handles=PlotOptionsKubint('handles',handles);
                case {'lint'}
                    handles=PlotOptionsLint('handles',handles);
                case {'image','geoimage'}
                    handles=PlotOptionsImage('handles',handles);
                case {'rose'}
                    handles=PlotOptionsRose('handles',handles);
                case {'freetext'}
                    handles=PlotOptionsText('handles',handles);
                case {'freehanddrawing'}
                    handles=PlotOptionsFreeHandDrawing('handles',handles);
            end
        end
    end
end

