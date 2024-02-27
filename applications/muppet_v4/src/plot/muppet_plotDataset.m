function h=muppet_plotDataset(handles,ifig,isub,id)

% Plot dataset and returns plot handle (for use in legend)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;

nr=handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.number;

if ~isempty(nr)
    data=handles.datasets(nr).dataset;
else
    % Must be an annotation, interactive text or interactive polygon
    data=[];
end

% Copy plot options to opt structure
opt=plt.datasets(id).dataset;

% if handles.figures(ifig).figure.cm2pix==1
%     opt2=0;
% else
%     opt2=1;
% end

%% If this is a map plot, try to convert coordinates of datasets if necessary
switch handles.figures(ifig).figure.subplots(isub).subplot.type
    
    case{'map'}
        % Convert data to correct coordinate system
        
        if ~isempty(nr) % In case of interactive polylines and text, nr be empty
            
            if ~strcmpi(plt.coordinatesystem.name,'unspecified') && ~strcmpi(data.coordinatesystem.name,'unspecified')
                if ~strcmpi(plt.coordinatesystem.name,data.coordinatesystem.name) || ...
                        ~strcmpi(plt.coordinatesystem.type,data.coordinatesystem.type)
                if ~strcmpi(data.coordinatesystem.name,'undefined')
                    switch lower(data.type)
                        case{'vector2d2dxy','scalar2dxy','location1dxy','location2dxy'}
                            [data.x,data.y]=convertCoordinates(data.x,data.y,handles.EPSG,'CS1.name',data.coordinatesystem.name,'CS1.type',data.coordinatesystem.type, ...
                                'CS2.name',plt.coordinatesystem.name,'CS2.type',plt.coordinatesystem.type);
                        case{'scalar2duxy','vector2d2duxy'}
                            [data.G.cor.x,data.G.cor.y]=convertCoordinates(data.G.cor.x,data.G.cor.y,handles.EPSG,'CS1.name',data.coordinatesystem.name,'CS1.type',data.coordinatesystem.type, ...
                                'CS2.name',plt.coordinatesystem.name,'CS2.type',plt.coordinatesystem.type);
                            [data.G.peri.x,data.G.peri.y]=convertCoordinates(data.G.peri.x,data.G.peri.y,handles.EPSG,'CS1.name',data.coordinatesystem.name,'CS1.type',data.coordinatesystem.type, ...
                                'CS2.name',plt.coordinatesystem.name,'CS2.type',plt.coordinatesystem.type);
                    end
                end
                end
            end
        end
            
        % Set projection (in case of geographic coordinate systems)
        if strcmpi(handles.figures(ifig).figure.subplots(isub).subplot.coordinatesystem.type,'geographic')
            switch handles.figures(ifig).figure.subplots(isub).subplot.projection
                case{'mercator'}
                    if ~isempty(nr)
                        switch lower(data.type)
                            case{'scalar2duxy','vector2d2duxy'}
                                % Unstructured data
%                                 data.G.cor.y=merc(data.G.cor.y);
%                                 data.G.peri.y=merc(data.G.peri.y);
                                data.G.node.y=merc(data.G.node.y);
                                data.G.face.FlowElemCont_y=merc(data.G.face.FlowElemCont_y);
                            otherwise
                                data.y=merc(data.y);
                        end
                    else
                        % Interactive polylines and text
                        plt.datasets(id).dataset.y=merc(plt.datasets(id).dataset.y);
                    end
                case{'albers'}
                    if ~isempty(nr)
                        switch lower(data.type)
                            case{'scalar2duxy','vector2d2duxy'}
                                % Unstructured data
                                x=data.G.cor.x;
                                y=data.G.cor.y;
                                [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                                data.G.cor.x=x;
                                data.G.cor.y=y;
                                x=data.G.peri.x;
                                y=data.G.peri.y;
                                [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                                data.G.peri.x=x;
                                data.G.peri.y=y;
                            otherwise
                                x=data.x;
                                y=data.y;
                                [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                                data.x=x;
                                data.y=y;
                        end
                    else
                        % Interactive polylines and text
                        x=plt.datasets(id).dataset.x;
                        y=plt.datasets(id).dataset.y;
                        [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                        plt.datasets(id).dataset.x=x;
                        plt.datasets(id).dataset.y=y;
                    end
            end
        end
        %         end
end

% Normprob scaling
switch lower(plt.xscale)
    case{'normprob'}
        data.x=norminv(0.01*data.x,0,1);
end
switch lower(plt.yscale)
    case{'normprob'}
        data.y=norminv(0.01*data.y,0,1);
end

% Right axis
if plt.datasets(id).dataset.rightaxis && plt.rightaxis
    a=(data.y-plt.yminright)/(plt.ymaxright-plt.yminright);
    data.y=plt.ymin+a*(plt.ymax-plt.ymin);
end

% Copy data structure back to handles structure
if ~isempty(nr)
    handles.datasets(nr).dataset=data;
end

% Copy subplot structure back to handles structure
handles.figures(ifig).figure.subplots(isub).subplot=plt;

%% Plot dataset
switch lower(plt.datasets(id).dataset.plotroutine)
    case {'line','spline','area below line'}
        h=muppet_plotLine(handles,ifig,isub,id);
    case {'histogram'}
        h=muppet_plotHistogram(handles,ifig,isub,id);
    case {'stacked area'}
        h=muppet_plotStackedArea(handles,ifig,isub,id);
    case {'time bars'}
        h=muppet_plotTimeSeriesBars(handles,ifig,isub,id);
    case {'contour map','contour map and lines','patches','contour lines','shades map'}
        muppet_plot2DSurface(handles,ifig,isub,id);
    case {'unstructured patches'}
        muppet_plotUnstructuredPatches(handles,ifig,isub,id);
    case {'unstructured mesh'}
        muppet_plotUnstructuredMesh(handles,ifig,isub,id);
    case {'3d surface','3d surface and lines'}
        muppet_plot3DSurface(handles,ifig,isub,id);
    case {'grid'}
        h=muppet_plotGrid(handles,ifig,isub,id);
    case {'3d grid'}
        h=muppet_plotGrid3D(handles,ifig,isub,id);
    case {'annotation'},
        h=muppet_plotAnnotation(handles,ifig,isub,id);
%     case {'plotcrosssections'}
%         handles=muppet_plotCrossSections(handles,ifig,isub,id);
    case {'samples'}
        h=muppet_plotSamples(handles,ifig,isub,id);
    case {'vectors','colored vectors'}
        % Colored vectors don't work under 2007b!
        h=muppet_plotVectors(handles,ifig,isub,id);
    case {'feather'}
        h=muppet_plotFeather(handles,ifig,isub,id);
    case {'curved arrows','colored curved arrows'}
        % Original mex file work under 2007b!
        h=muppet_plotCurVec(handles,ifig,isub,id);
%     case {'plotvectormagnitude'}
%         handles=PlotVectorMagnitude(handles,ifig,isub,id,mode);
    case {'polyline'}
        h=muppet_plotPolygon(handles,ifig,isub,id);
%        h=muppet_plotScatterBin(handles,ifig,isub,id);
    case {'kubint'}
        h=muppet_plotKub(handles,ifig,isub,id);
    case {'lint'}
        h=muppet_plotLint(handles,ifig,isub,id);
    case {'image'}
        h=muppet_plotImage(handles,ifig,isub,id);
%     case {'plot3dsurface','plot3dsurfacelines'}
%         handles=Plot3DSurface(handles,ifig,isub,id,mode);
%     case {'plotpolygon3d'}
%         handles=PlotPolygon3D(handles,ifig,isub,id,mode);
    case {'rose'}
        h=muppet_plotRose(handles,ifig,isub,id);
%     case {'plottext'}
%         h=muppet_plotText(handles,ifig,isub,id,1);
    case {'interactive text'}
        h=muppet_plotInteractiveText(handles,ifig,isub,id);
    case {'interactive polyline'}
        muppet_plotInteractivePolyline(handles,ifig,isub,id);
%     case {'drawspline'}
%         DrawSpline(Data,Plt,handles.DefaultColors,opt);
%     case {'drawcurvedarrow'}
%         DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt2,1);
%     case {'drawcurveddoublearrow'}
%         DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt2,2);
    case{'text box','rectangle','ellipse','arrow','double arrow','single line'}
        muppet_addAnnotation(handles.figures(ifig).figure,ifig,isub,id);
    case {'tidal ellipse'}
        h=muppet_plotTidalEllipse(handles,ifig,isub,id);
    case {'statstext'}
        h=muppet_plotStatsText(handles,ifig,isub,id);
end

%% Add color bar for dataset (in addition to colorbar for subplot!)
clrbar=[];
if opt.plotcolorbar
    opt.shadesbar=0;
    clrbar=muppet_setColorBar(handles.figures(ifig).figure,ifig,isub,id);
end
opt.colorbarhandle=clrbar;

%% Add datestring
if opt.adddatestring
    dstx=0.5*(plt.xmax-plt.xmin)/plt.position(3);
    if strcmpi(plt.coordinatesystem.type,'geographic')
        fac=cos(plt.ymax*pi/180);
    else
        fac=1;
    end
    dsty=0.5*fac*(plt.ymax-plt.ymin)/plt.position(4);
    switch lower(opt.adddate.position),
        case {'lower-left'},
            xpos=plt.xmin+dstx;
            ypos=plt.ymin+dsty;
            horal='left';
        case {'lower-right'},
            xpos=plt.xmax-dstx;
            ypos=plt.ymin+dsty;
            horal='right';
        case {'upper-left'},
            xpos=plt.xmin+dstx;
            ypos=plt.ymax-dsty;
            horal='left';
        case {'upper-right'},
            xpos=plt.xmax-dstx;
            ypos=plt.ymax-dsty;
            horal='right';
    end
    if strcmpi(plt.coordinatesystem.type,'geographic')
        switch plt.projection
            case{'mercator'}
                ypos=merc(ypos);
            case{'albers'}
                [xpos,ypos]=albers(xpos,ypos,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
        end
    end
    tim=data.time;
    if isempty(tim)
        % Try to see if this dataset is a track
        try
            tim=opt.timemarker.time;
        end
    end
    datestring=[opt.adddate.prefix datestr(tim,opt.adddate.format) opt.adddate.suffix];
    tx=text(xpos,ypos,datestring);
    set(tx,'HorizontalAlignment',horal);
    set(tx,'FontName',opt.adddate.font.name);
    set(tx,'FontSize',opt.adddate.font.size*handles.figures(ifig).figure.fontreduction);
    set(tx,'FontWeight',opt.adddate.font.weight);
    set(tx,'FontAngle',opt.adddate.font.angle);
    set(tx,'Color',colorlist('getrgb','color',opt.adddate.font.color));
end

