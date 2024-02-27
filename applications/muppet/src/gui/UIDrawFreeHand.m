function UIDrawFreeHand(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

SetPlotEdit(0);

TypeNr=varargin{3};

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse,TypeNr});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StartTrack(imagefig, varargins,h,TypeNr) 
set(gcf, 'Units', 'normalized');
set(gcf, 'windowbuttonmotionfcn',[]);
set(gcf, 'windowbuttondownfcn', {@FollowTrack,h});

mpt=findobj('Name','Muppet');
data=guidata(mpt);

n=get(h,'UserData');
ifig=n(1);
isub=n(2);

usd.TypeNr=TypeNr;
switch usd.TypeNr,
    case 1
        usd.Type='Polyline';
    case 2
        usd.Type='Spline';
    case 3
        usd.Type='CurvedArrow';
end

hold on
xy = [];
n = 1;
plt=plot([1 2],[1 2],'b');

xlim=get(gca,'XLim');
if data.Figure(ifig).NrAnnotations>0
    nrsub=data.Figure(ifig).NrSubplots-1;
else
    nrsub=data.Figure(ifig).NrSubplots;
end

szx=data.Figure(ifig).Axis(isub).Position(3);
Scale=(xlim(2)-xlim(1))/(0.01*szx);

pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);

xy(:,1)=[xi;yi];
usd.xy=xy;
usd.n=n;
usd.plt=plt;
usd.Scale=Scale;
set(0,'UserData',usd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function FollowTrack(imagefig, varargins, h)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

n=get(h,'UserData');
ifig=n(1);
isub=n(2);

mouseclick=get(gcf,'SelectionType');

if strcmp(mouseclick,'normal')

    usd=get(0,'UserData');

    pos = get(h, 'CurrentPoint');
    xi=pos(1,1);
    yi=pos(1,2);

    usd.n = usd.n+1;
    usd.xy(:,usd.n) = [xi;yi];

    delete(usd.plt);
    
    DataProperties.x=usd.xy(1,:);
    DataProperties.y=usd.xy(2,:);
    SubplotProperties.Scale=usd.Scale;
    opt=0;
    switch usd.Type,
        case{'Polyline'};
            PlotOptions.LineColor='black';
            PlotOptions.FillColor='none';
            PlotOptions.LineWidth=2;
            PlotOptions.LineStyle='-';
            PlotOptions.FillPolygons=0;
            [usd.plt,ptch]=DrawPolyline(DataProperties,PlotOptions,data.DefaultColors,opt);
        case{'Spline'};
            PlotOptions.LineColor='black';
            PlotOptions.FillColor='none';
            PlotOptions.LineWidth=2;
            PlotOptions.LineStyle='-';
            PlotOptions.FillPolygons=0;
            [usd.plt,ptch]=DrawSpline(DataProperties,PlotOptions,data.DefaultColors,opt);
        case{'CurvedArrow'};
            PlotOptions.HeadWidth=4;
            PlotOptions.ArrowWidth=2;
            PlotOptions.LineColor='black';
            PlotOptions.FillColor='red';
            PlotOptions.LineStyle='-';
            PlotOptions.FillPolygons=0;
            usd.plt=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,data.DefaultColors,opt,1);
        case{'CurvedDoubleArrow'};
            PlotOptions.HeadWidth=4;
            PlotOptions.ArrowWidth=2;
            PlotOptions.LineColor='black';
            PlotOptions.FillColor='red';
            PlotOptions.LineStyle='-';
            PlotOptions.FillPolygons=0;
            usd.plt=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,data.DefaultColors,opt,2);
    end

    set(0,'UserData',usd);

else

    set(gcf, 'Pointer', 'arrow');
    set(gcf, 'Units', 'pixels');
    set(gcf, 'windowbuttonupfcn', []);
    set(gcf, 'windowbuttondownfcn', []);
    set(gcf, 'windowbuttonmotionfcn', []);

    mpt=findobj('Name','Muppet');
    data=guidata(mpt);

    usd=get(0,'userdata');

    delete(usd.plt);

    ifig=data.ActiveFigure;
    if data.Figure(ifig).NrAnnotations>0
        nrsub=data.Figure(ifig).NrSubplots-1;
    else
        nrsub=data.Figure(ifig).NrSubplots;
    end

    data.ActiveSubplot=isub;
    guidata(mpt,data);

    n=data.Figure(ifig).Axis(isub).Nr+1;
    
    data.NrAvailableDatasets=data.NrAvailableDatasets+1;
    kk=data.NrAvailableDatasets;
    data.ActiveAvailableDataset=data.NrAvailableDatasets;

    switch usd.Type,
        case{'Polyline'};
            data.DataProperties(kk).Name=['Polyline ' num2str(data.NrAvailableDatasets)];
        case{'Spline'};
            data.DataProperties(kk).Name=['Spline ' num2str(data.NrAvailableDatasets)];
        case{'CurvedArrow'};
            data.DataProperties(kk).Name=['CurvedArrow ' num2str(data.NrAvailableDatasets)];
    end
    
    data.PlotOptions(ifig,isub,n).Name=data.DataProperties(kk).Name;
    data.DataProperties(kk).FileType='FreeHandDrawing';
    data.DataProperties(kk).FileName='';
    data.DataProperties(kk).PathName='';
    data.DataProperties(kk).Type='FreeHandDrawing';
    data.DataProperties(kk).CombinedDataset=0;

    data.DataProperties(kk).DateTime=0;
    data.DataProperties(kk).Parameter='';
    data.DataProperties(kk).Block=0;
    
    data.DataProperties(kk).x=usd.xy(1,:);
    data.DataProperties(kk).y=usd.xy(2,:);

    data=RefreshAvailableDatasets(data);
    data=RefreshActiveAvailableDatasetText(data);
    data=AddToSubplot(data);
    
    figure(data.Figure(ifig).Handle);
    
    opt=1;
    switch usd.Type,
        case{'Polyline'};
            data.Figure(ifig).Axis(isub).Plot(n).PlotRoutine='DrawPolyline';
            data.Figure(ifig).Axis(isub).Plot(n).LineColor='black';
            data.Figure(ifig).Axis(isub).Plot(n).FillColor='red';
            data.Figure(ifig).Axis(isub).Plot(n).LineWidth=2;
            data.Figure(ifig).Axis(isub).Plot(n).FillPolygons=0;
            data.Figure(ifig).Axis(isub).Plot(n).LineStyle='-';
            DrawPolyline(data.DataProperties(kk),data.Figure(ifig).Axis(isub).Plot(n),data.DefaultColors,opt);
        case{'Spline'};
            data.Figure(ifig).Axis(isub).Plot(n).PlotRoutine='DrawSpline';
            data.Figure(ifig).Axis(isub).Plot(n).LineColor='black';
            data.Figure(ifig).Axis(isub).Plot(n).FillColor='red';
            data.Figure(ifig).Axis(isub).Plot(n).LineWidth=2;
            data.Figure(ifig).Axis(isub).Plot(n).FillPolygons=0;
            data.Figure(ifig).Axis(isub).Plot(n).LineStyle='-';
            DrawSpline(data.DataProperties(kk),data.Figure(ifig).Axis(isub).Plot(n),data.DefaultColors,opt);
        case{'CurvedArrow'};
            data.Figure(ifig).Axis(isub).Plot(n).PlotRoutine='DrawCurvedArrow';
            data.Figure(ifig).Axis(isub).Plot(n).HeadWidth=4;
            data.Figure(ifig).Axis(isub).Plot(n).ArrowWidth=2;
            data.Figure(ifig).Axis(isub).Plot(n).DoubleArrow=0;
            data.Figure(ifig).Axis(isub).Plot(n).LineColor='black';
            data.Figure(ifig).Axis(isub).Plot(n).FillColor='red';
            data.Figure(ifig).Axis(isub).Plot(n).LineStyle='-';
            data.Figure(ifig).Axis(isub).Plot(n).FillPolygons=1;
            DrawCurvedArrow(data.DataProperties(kk),data.Figure(ifig).Axis(isub),data.Figure(ifig).Axis(isub).Plot(n),data.DefaultColors,opt,1);
        case{'CurvedDoubleArrow'};
            data.Figure(ifig).Axis(isub).Plot(n).PlotRoutine='DrawCurvedArrow';
            data.Figure(ifig).Axis(isub).Plot(n).HeadWidth=4;
            data.Figure(ifig).Axis(isub).Plot(n).ArrowWidth=2;
            data.Figure(ifig).Axis(isub).Plot(n).DoubleArrow=0;
            data.Figure(ifig).Axis(isub).Plot(n).LineColor='black';
            data.Figure(ifig).Axis(isub).Plot(n).FillColor='red';
            data.Figure(ifig).Axis(isub).Plot(n).LineStyle='-';
            data.Figure(ifig).Axis(isub).Plot(n).FillPolygons=1;
            DrawCurvedArrow(data.DataProperties(kk),data.Figure(ifig).Axis(isub),data.Figure(ifig).Axis(isub).Plot(n),data.DefaultColors,opt,2);
    end

    guidata(mpt,data);

    set(0,'userdata',[]);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MoveMouse(imagefig, varargins,TypeNr)

handles=guidata(findobj('Name','Muppet'));
ifig=get(gcf,'UserData');

posgcf = get(gcf, 'CurrentPoint')/handles.Figure(ifig).cm2pix;

typ='none';

for j=1:handles.Figure(ifig).NrSubplots
    h0=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    if length(h0)>0
        pos=get(h0,'Position')/handles.Figure(ifig).cm2pix;
        if posgcf(1)>pos(1) & posgcf(1)<pos(1)+pos(3) & posgcf(2)>pos(2) & posgcf(2)<pos(2)+pos(4)
            typ=handles.Figure(ifig).Axis(j).PlotType;
            h=h0;
        end
    end
end

oktypes={'2d'};
ii=strmatch(lower(typ),oktypes,'exact');

if length(ii)==0
    set(gcf,'Pointer','arrow');
    set(gcf,'WindowButtonDownFcn',[]);
    return
else
    set(gcf, 'windowbuttondownfcn', {@StartTrack,h,TypeNr});
    set(gcf, 'Pointer', 'crosshair');
end
