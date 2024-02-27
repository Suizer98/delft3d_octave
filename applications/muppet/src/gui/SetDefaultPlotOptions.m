function handles=SetDefaultPlotOptions(handles)

ifig=handles.ActiveFigure;
i=handles.ActiveAvailableDataset;
j=handles.ActiveSubplot;
k=handles.ActiveDatasetInSubplot;
typ=handles.DataProperties(i).Type;

handles.Figure(ifig).Axis(j).Plot=matchstruct(handles.DefaultPlotOptions,handles.Figure(ifig).Axis(j).Plot,k);

switch lower(typ),
    case {'2dscalar','timestack'}
        if strcmp(handles.Figure(ifig).Axis(j).PlotType,'3d')
            handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='Plot3DSurface';
        else
            handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotContourMap';
        end            
        cmin=floor(min(min(handles.DataProperties(i).z)));
        cmax=ceil(max(max(handles.DataProperties(i).z)));
        cstep=0.01*round(100*(cmax-cmin)/20);
        handles.Figure(ifig).Axis(j).Plot(k).CMin=cmin;
        handles.Figure(ifig).Axis(j).Plot(k).CMax=cmax;
        handles.Figure(ifig).Axis(j).Plot(k).CStep=cstep;
        handles.Figure(ifig).Axis(j).Plot(k).Contours=[cmin:cstep:cmax];
        handles.Figure(ifig).Axis(j).Plot(k).FontSize=6;
    case {'3dcrosssectionscalar'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotContourMap';
        cmin=floor(min(min(handles.DataProperties(i).z)));
        cmax=ceil(max(max(handles.DataProperties(i).z)));
        cstep=round((cmax-cmin)/20);
        handles.Figure(ifig).Axis(j).Plot(k).CMin=cmin;
        handles.Figure(ifig).Axis(j).Plot(k).CMax=cmax;
        handles.Figure(ifig).Axis(j).Plot(k).CStep=cstep;
        handles.Figure(ifig).Axis(j).Plot(k).Contours=[cmin cstep cmax];
    case {'samples'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotSamples';
        handles.Figure(ifig).Axis(j).Plot(k).AddText=0;
        handles.Figure(ifig).Axis(j).Plot(k).Marker='o';
        handles.Figure(ifig).Axis(j).Plot(k).MarkerFaceColor='auto';
        handles.Figure(ifig).Axis(j).Plot(k).MarkerEdgeColor='black';
        handles.Figure(ifig).Axis(j).Plot(k).TextPosition='middle';
    case {'annotation'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotAnnotation';
    case {'freetext'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotText';
    case {'freehanddrawing'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='DrawPolyline';
    case {'crosssections'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotCrossSections';
    case {'2dvector'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotVectors';
        umag=sqrt(handles.DataProperties(i).u.^2 + handles.DataProperties(i).v.^2);
        umax=max(max(umag));
        unitvec=handles.Figure(ifig).Axis(j).Scale*0.005/umax;
        handles.Figure(ifig).Axis(j).Plot(k).UnitVector=unitvec;
        handles.Figure(ifig).Axis(j).Plot(k).VectorLegendLength=umax;
        handles.Figure(ifig).Axis(j).Plot(k).VectorLegendText=num2str(umax);
        cmin=0;
        cmax=umax;
        cstep=(cmax-cmin)/20;
        handles.Figure(ifig).Axis(j).Plot(k).Contours=[cmin cstep cmax];
        handles.Figure(ifig).Axis(j).Plot(k).FillColor='red';
        handles.Figure(ifig).Axis(j).Plot(k).DxCurVec=handles.Figure(ifig).Axis(j).Scale*0.005;
        axpos=handles.Figure(ifig).Axis(j).Position;
        handles.Figure(ifig).Axis(j).Plot(k).ColorBarPosition=[axpos(1)+1 axpos(2)+1 0.5 axpos(4)-2];
    case {'3dcrosssectionvector'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotVectors';
        if handles.Figure(ifig).Axis(j).AxesEqual==0
            VertScale=(handles.Figure(ifig).Axis(j).YMax-handles.Figure(ifig).Axis(j).YMin)/handles.Figure(ifig).Axis(j).Position(4);
            HoriScale=(handles.Figure(ifig).Axis(j).XMax-handles.Figure(ifig).Axis(j).XMin)/handles.Figure(ifig).Axis(j).Position(3);
            MultiV=HoriScale/VertScale;
        else
            MultiV=1.0;
        end
        handles.Figure(ifig).Axis(j).Plot(k).VerticalVectorScaling=MultiV;
        umag=sqrt(handles.DataProperties(i).u.^2 + handles.DataProperties(i).v.^2);
        umax=max(max(umag));
        unitvec=handles.Figure(ifig).Axis(j).Scale*0.005/umax;
        handles.Figure(ifig).Axis(j).Plot(k).UnitVector=unitvec;
        handles.Figure(ifig).Axis(j).Plot(k).VectorLegendLength=umax;
        handles.Figure(ifig).Axis(j).Plot(k).VectorLegendText=num2str(umax);
    case {'timeseries','xyseries','3dprofile'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotLine';
        handles.Figure(ifig).Axis(j).Plot(k).LegendText=handles.Figure(ifig).Axis(j).Plot(k).Name;
        if handles.Figure(ifig).Axis(j).Nr<=8
            nr=num2str(handles.Figure(ifig).Axis(j).Nr);
            handles.Figure(ifig).Axis(j).Plot(k).LineStyle=getfield(handles.DefaultPlotOptions,['LineStyle' nr]);
            handles.Figure(ifig).Axis(j).Plot(k).LineColor=getfield(handles.DefaultPlotOptions,['LineColor' nr]);
            handles.Figure(ifig).Axis(j).Plot(k).LineWidhth=getfield(handles.DefaultPlotOptions,['LineWidth' nr]);
            handles.Figure(ifig).Axis(j).Plot(k).Marker=getfield(handles.DefaultPlotOptions,['Marker' nr]);
            handles.Figure(ifig).Axis(j).Plot(k).FillColor=getfield(handles.DefaultPlotOptions,['FillColor' nr]);
        end           
    case {'bar'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotHistogram';
        handles.Figure(ifig).Axis(j).Plot(k).LegendText=handles.Figure(ifig).Axis(j).Plot(k).Name;
    case {'polyline'}
        if strcmp(handles.Figure(ifig).Axis(j).PlotType,'3d')
            handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotPolygon3D';
        else
            handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotPolyline';
        end            
    case {'grid','3dcrosssectiongrid'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotGrid';
    case {'curvedvectors'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotCurvedVectors';
        handles.Figure(ifig).Axis(j).Plot(k).FillPolygons=1;
        handles.Figure(ifig).Axis(j).Plot(k).FillColor=[1.0 0.0 0.0];
    case {'image'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotImage';
    case {'geoimage'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotGeoImage';
        handles.Figure(ifig).Axis(j).Plot(k).WhiteVal=1.0;
    case {'kubint'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotKub';
    case {'lint'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotLint';
        handles.Figure(ifig).Axis(j).Plot(k).FillPolygons=1;
        handles.Figure(ifig).Axis(j).Plot(k).AddText=1;
        handles.Figure(ifig).Axis(j).Plot(k).ArrowColor='red';
        handles.Figure(ifig).Axis(j).Plot(k).Font='Helvetica';
        handles.Figure(ifig).Axis(j).Plot(k).FontSize=6;
    case {'rose'}
        handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine='PlotRose';
        dat=handles.DataProperties(i).z;
        sm=sum(dat,2);
        smmax=max(sm);
        if smmax<4
            handles.Figure(ifig).Axis(j).Plot(k).RadiusStep=1;
            handles.Figure(ifig).Axis(j).Plot(k).MaxRadius=4;
        elseif smmax<8
            handles.Figure(ifig).Axis(j).Plot(k).RadiusStep=2;
            handles.Figure(ifig).Axis(j).Plot(k).MaxRadius=8;
        elseif smmax<16
            handles.Figure(ifig).Axis(j).Plot(k).RadiusStep=4;
            handles.Figure(ifig).Axis(j).Plot(k).MaxRadius=16;
        else
            handles.Figure(ifig).Axis(j).Plot(k).RadiusStep=10;
            handles.Figure(ifig).Axis(j).Plot(k).MaxRadius=40;
        end
end


