function UIEditFreeHandObject(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

n=get(gca,'UserData');

ud=get(gco,'userdata');
usd=get(ud.Parent,'userdata');
usd.ifig=n(1);
usd.isub=n(2);
usd.kk=FindDatasetNr(usd.Name,data.DataProperties);
usd.nr=ud.nr;
if data.Figure(usd.ifig).NrAnnotations>0
    nrsub=data.Figure(usd.ifig).NrSubplots-1;
else
    nrsub=data.Figure(usd.ifig).NrSubplots;
end

PltOpt=data.Figure(usd.ifig).Axis(usd.isub).Plot;
usd.n=FindDatasetNr(usd.Name,PltOpt);

SubplotProperties=data.Figure(usd.ifig).Axis(usd.isub);
PlotOptions=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);

if strcmp(get(gcf,'SelectionType'),'open')
    data.ActiveFigure=usd.ifig;
    data.ActiveSubplot=usd.isub;
    data.ActiveDatasetInSubplot=usd.n;
    data=PlotOptionsFreeHandDrawing('data',data);
    PlotOptions=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);
    delete(usd.SelectionHighlights);
    delete(usd.plt);
    if ishandle(usd.ptch)
        delete(usd.ptch);
    end
    opt=1;
    switch lower(PlotOptions.PlotRoutine),
        case{'drawpolyline'};
            DrawPolyline(data.DataProperties(usd.kk),PlotOptions,data.DefaultColors,opt);
        case{'drawspline'};
            DrawSpline(data.DataProperties(usd.kk),PlotOptions,data.DefaultColors,opt);
        case{'drawcurvedarrow'};
            DrawCurvedArrow(data.DataProperties(usd.kk),SubplotProperties,PlotOptions,data.DefaultColors,opt,1);
        case{'drawcurveddoublearrow'};
            DrawCurvedArrow(data.DataProperties(usd.kk),SubplotProperties,PlotOptions,data.DefaultColors,opt,2);
    end
    guidata(mpt,data);
    set(0,'userdata',[]);
else
    if strcmp(get(gco,'Tag'),'SelectionHighlight')
        set(gco,'MarkerFaceColor','y');
        set(gco,'ButtonDownFcn',[]);
        xlim=get(gca,'XLim');
        szx=SubplotProperties.Position(3);
        usd.Scale=(xlim(2)-xlim(1))/(0.01*szx);
        usd.plt1=plot(0,0);
        if strcmp(get(gcf,'SelectionType'),'normal')
            set(gcf, 'windowbuttonmotionfcn', {@changetrack});
        else
            pos = get(gca, 'CurrentPoint');
            usd.x0=pos(1,1);
            usd.y0=pos(1,2);
            usd.xy0=usd.xy;
            set(gcf, 'windowbuttonmotionfcn', {@movetrack});
        end
        set(0,'userdata',usd);
        set(gcf, 'windowbuttonupfcn', {@stoptrack});
    else
        set(0,'userdata',1);
    end

    waitfor(0, 'userdata',[]);
    set(gcf,'Pointer','arrow');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function starttrack(imagefig, varargins) 
set(gcf, 'Units', 'normalized');
usd=get(0,'userdata');
set(0,'userdata',usd);
set(gcf, 'windowbuttonmotionfcn', {@followtrack});
set(gcf, 'windowbuttonupfcn', {@stoptrack});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function changetrack(imagefig, varargins)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.xy(:,usd.nr) = [posx;posy];
delete(usd.plt1);
if ishandle(usd.ptch)
    delete(usd.ptch);
end

DataProperties.x=usd.xy(1,:);
DataProperties.y=usd.xy(2,:);
SubplotProperties.Scale=usd.Scale;
opt=0;
switch usd.Type,
    case{'Polyline'}
        PlotOptions.LineColor='gray70';
        PlotOptions.LineStyle='--';
        PlotOptions.FillColor='none';
        PlotOptions.LineWidth=2;
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawPolyline(DataProperties,PlotOptions,data.DefaultColors,opt);
    case{'Spline'}
        PlotOptions.LineColor='gray70';
        PlotOptions.LineStyle='--';
        PlotOptions.FillColor='none';
        PlotOptions.LineWidth=2;
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawSpline(DataProperties,PlotOptions,data.DefaultColors,opt);
    case{'CurvedArrow'}
        PlotOptions.HeadWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).HeadWidth;
        PlotOptions.ArrowWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).ArrowWidth;
        PlotOptions.LineColor='gray70';
        PlotOptions.FillColor='none';
        PlotOptions.LineStyle='--';
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,data.DefaultColors,opt,1);
    case{'CurvedDoubleArrow'}
        PlotOptions.HeadWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).HeadWidth;
        PlotOptions.ArrowWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).ArrowWidth;
        PlotOptions.LineColor='gray70';
        PlotOptions.FillColor='none';
        PlotOptions.LineStyle='--';
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,data.DefaultColors,opt,2);
end
set(0,'UserData',usd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function movetrack(imagefig, varargins)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.xy(1,:)=usd.xy0(1,:)+posx-usd.x0;
usd.xy(2,:)=usd.xy0(2,:)+posy-usd.y0;
delete(usd.plt1);
if ishandle(usd.ptch)
    delete(usd.ptch);
end

DataProperties.x=usd.xy(1,:);
DataProperties.y=usd.xy(2,:);
SubplotProperties.Scale=usd.Scale;
opt=0;
switch usd.Type,
    case{'Polyline'};
        PlotOptions.LineColor='gray70';
        PlotOptions.LineStyle='--';
        PlotOptions.FillColor='none';
        PlotOptions.LineWidth=2;
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawPolyline(DataProperties,PlotOptions,data.DefaultColors,opt);
    case{'Spline'};
        PlotOptions.LineColor='gray70';
        PlotOptions.LineStyle='--';
        PlotOptions.FillColor='none';
        PlotOptions.LineWidth=2;
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawSpline(DataProperties,PlotOptions,data.DefaultColors,opt);
    case{'CurvedArrow'};
        PlotOptions.HeadWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).HeadWidth;
        PlotOptions.ArrowWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).ArrowWidth;
        PlotOptions.LineColor='gray70';
        PlotOptions.FillColor='red';
        PlotOptions.LineStyle='--';
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,data.DefaultColors,opt,1);
    case{'CurvedDoubleArrow'};
        PlotOptions.HeadWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).HeadWidth;
        PlotOptions.ArrowWidth=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n).ArrowWidth;
        PlotOptions.LineColor='gray70';
        PlotOptions.FillColor='none';
        PlotOptions.LineStyle='--';
        PlotOptions.FillPolygons=0;
        [usd.plt1,usd.ptch]=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,data.DefaultColors,opt,2);
end
set(0,'UserData',usd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stoptrack(imagefig, varargins)
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');

udplt=get(usd.plt,'userdata');
delete(udplt.SelectionHighlights);

delete(usd.plt1);
delete(usd.plt);
if ishandle(usd.ptch)
    delete(usd.ptch);
end

data.DataProperties(usd.kk).x=usd.xy(1,:);
data.DataProperties(usd.kk).y=usd.xy(2,:);
SubplotProperties=data.Figure(usd.ifig).Axis(usd.isub);
PlotOptions=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);

opt=1;
switch usd.Type,
    case{'Polyline'};
        DrawPolyline(data.DataProperties(usd.kk),PlotOptions,data.DefaultColors,opt);
    case{'Spline'};
        DrawSpline(data.DataProperties(usd.kk),PlotOptions,data.DefaultColors,opt);
    case{'CurvedArrow'};
        DrawCurvedArrow(data.DataProperties(usd.kk),SubplotProperties,PlotOptions,data.DefaultColors,opt,1);
    case{'CurvedDoubleArrow'};
        DrawCurvedArrow(data.DataProperties(usd.kk),SubplotProperties,PlotOptions,data.DefaultColors,opt,2);
end

guidata(mpt,data);

set(0,'userdata',[]);



