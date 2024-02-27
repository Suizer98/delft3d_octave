function handles=PlotDataset(handles,i,j,k,mode)

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

handles.Figure(i).Axis(j).Plot(k).Handle=[];

if Fig.cm2pix==1
    opt=0;
else
    opt=1;
end

% Convert data to correct coordinate system
if ~strcmpi(Ax.coordinateSystem.name,'unknown') && ~strcmpi(Data.coordinateSystem.name,'unknown')
    if ~strcmpi(Ax.coordinateSystem.name,Data.coordinateSystem.name) && ...
            ~strcmpi(Ax.coordinateSystem.type,Data.coordinateSystem.type)
        switch lower(Data.Type)
            case{'2dvector','2dscalar','polyline','grid'}
                if ~isfield(handles,'EPSG')
                    wb = waitbox('Reading coordinate conversion libraries ...');
                    curdir=[handles.MuppetPath 'settings' filesep 'SuperTrans'];
                    handles.EPSG=load([curdir filesep 'data' filesep 'EPSG.mat']);
                    close(wb);
                end
                [Data.x,Data.y]=convertCoordinates(Data.x,Data.y,handles.EPSG,'CS1.name',Data.coordinateSystem.name,'CS1.type',Data.coordinateSystem.type, ...
                    'CS2.name',Ax.coordinateSystem.name,'CS2.type',Ax.coordinateSystem.type);
        end
    end
end

switch lower(handles.Figure(i).Axis(j).Plot(k).PlotRoutine),
    case {'plottimeseries','plotxy','plotxyseries','plotline','plotspline'},
        handles=PlotLine(handles,i,j,k,mode);
    case {'plothistogram'},
        handles=PlotHistogram(handles,i,j,k,mode);
    case {'plotstackedarea'},
        handles=PlotStackedArea(handles,i,j,k,mode);
    case {'plotcontourmap','plotcontourmaplines','plotpatches','plotcontourlines','plotshadesmap'},
%         handles=Plot2DSurface(handles,i,j,k,mode);
        mp_plot2DSurface(handles,Data,Plt,Ax);
    case {'plotgrid'}
%        handles=PlotGrid(handles,i,j,k,mode);
        mp_plotGrid(Data,Plt);
    case {'plotannotation'},
        handles=PlotAnnotation(handles,i,j,k,mode);
    case {'plotcrosssections'},
        handles=PlotCrossSections(handles,i,j,k,mode);
    case {'plotsamples'},
        handles=PlotSamples(handles,i,j,k,mode);
    case {'plotvectors','plotcoloredvectors'},
        % Colored vectors don't work under 2007b!
        handles=PlotVectors(handles,i,j,k,mode);
    case {'plotcurvedarrows','plotcoloredcurvedarrows'},
        % Original mex file work under 2007b!
        handles=PlotCurVec(handles,i,j,k,mode);
    case {'plotvectormagnitude'},
        handles=PlotVectorMagnitude(handles,i,j,k,mode);
    case {'plotpolyline','plotpolygon'},
        handles=PlotPolygon(handles,i,j,k,mode);
    case {'plotkub'},
        handles=PlotKub(handles,i,j,k,mode);
    case {'plotlint'},
        handles=PlotLint(handles,i,j,k,mode);
    case {'plotimage','plotgeoimage'},
        handles=PlotImage(handles,i,j,k,mode);
    case {'plot3dsurface','plot3dsurfacelines'},
        handles=Plot3DSurface(handles,i,j,k,mode);
    case {'plotpolygon3d'},
        handles=PlotPolygon3D(handles,i,j,k,mode);
    case {'plotrose'},
        handles=PlotRose(handles,i,j,k,mode);
    case {'plottext'},
        PlotText(Data,Plt,handles.DefaultColors,Fig.FontRed,opt);
    case {'drawpolyline'},
        DrawPolyline(Data,Plt,handles.DefaultColors,opt);
    case {'drawspline'},
        DrawSpline(Data,Plt,handles.DefaultColors,opt);
    case {'drawcurvedarrow'},
        DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt,1);
    case {'drawcurveddoublearrow'},
        DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt,2);
end

ColBar=[];
if Plt.PlotColorBar
    handles.Figure(i).Axis(j).Plot(k).ShadesBar=0;
    ColBar=SetColorBar(handles,i,j,k);
end
handles.Figure(i).Axis(j).Plot(k).ColorBarHandle=ColBar;

if Plt.AddDate
    dstx=0.5*(Ax.XMax-Ax.XMin)/Ax.Position(3);
    dsty=0.5*(Ax.YMax-Ax.YMin)/Ax.Position(4);
    switch lower(Plt.AddDatePosition),
        case {'lower-left'},
            xpos=Ax.XMin+dstx;
            ypos=Ax.YMin+dsty;
            HorAl='left';
        case {'lower-right'},
            xpos=Ax.XMax-dstx;
            ypos=Ax.YMin+dsty;
            HorAl='right';
        case {'upper-left'},
            xpos=Ax.XMin+dstx;
            ypos=Ax.YMax-dsty;
            HorAl='left';
        case {'upper-right'},
            xpos=Ax.XMax-dstx;
            ypos=Ax.YMax-dsty;
            HorAl='right';
    end
    datestring=[Plt.AddDatePrefix datestr(Data.DateTime,Plt.AddDateFormat) Plt.AddDateSuffix];
    tx=text(xpos,ypos,10,datestring);
    set(tx,'HorizontalAlignment',HorAl);
    set(tx,'FontName',Plt.AddDateFont);
    set(tx,'FontSize',Plt.AddDateFontSize);
    set(tx,'FontWeight',Plt.AddDateFontWeight);
    set(tx,'FontAngle',Plt.AddDateFontAngle);
    set(tx,'Color',FindColor(Plt.AddDateFontColor));
end
