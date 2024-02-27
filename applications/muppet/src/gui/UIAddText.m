function UIAddText(varargin)

h=findall(gcf,'Tag','UIToggleToolEditFigure');
set(h,'State','off');
h=(findall(gcf,'TooltipString','Zoom In'));
set(h,'State','off');
h=(findall(gcf,'TooltipString','Zoom Out'));
set(h,'State','off');
h=(findall(gcf,'TooltipString','Pan'));
set(h,'State','off');

SetPlotEdit(0);

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GetTextPosition(imagefig, varargins,h) 
set(gcf, 'windowbuttonmotionfcn',[]);

if strcmp(get(gcf,'SelectionType'),'normal')

    mpt=findobj('Name','Muppet');
    data=guidata(mpt);

    pos = get(h, 'CurrentPoint');
    xi=pos(1,1);
    yi=pos(1,2);

    plttmp=plot(xi,yi,'k+');
    
    nn=get(h,'UserData');
    ifig=nn(1);
    isub=nn(2);
    data.ActiveFigure=ifig;
    data.ActiveSubplot=isub;
    
    n=data.Figure(ifig).Axis(isub).Nr+1;
    data.Figure(ifig).Axis(isub).Nr=n;
    data.NrAvailableDatasets=data.NrAvailableDatasets+1;
    kk=data.NrAvailableDatasets;
    data.ActiveAvailableDataset=data.NrAvailableDatasets;
    data.ActiveDatasetInSubplot=n;
    
    data.DataProperties(kk).FileType='FreeText';
    data.DataProperties(kk).FileName='';
    data.DataProperties(kk).Type='FreeText';
    data.DataProperties(kk).CombinedDataset=0;
    data.DataProperties(kk).DateTime=0;
    data.DataProperties(kk).Parameter='FreeText';
    data.DataProperties(kk).Block=0;
    data.DataProperties(kk).String='';
    data.DataProperties(kk).Position=[xi yi];
    data.DataProperties(kk).Rotation=0;
    data.DataProperties(kk).Curvature=0;
    data.DataProperties(kk).Name=['Text ' data.DataProperties(kk).String];
    data.Figure(ifig).Axis(isub).Plot(n).Name=data.DataProperties(kk).Name;
    data.Figure(ifig).Axis(isub).Plot(n).PlotRoutine='PlotText';
    data.Figure(ifig).Axis(isub).Plot(n).Font='Helvetica';
    data.Figure(ifig).Axis(isub).Plot(n).FontSize=8;
    data.Figure(ifig).Axis(isub).Plot(n).FontWeight='normal';
    data.Figure(ifig).Axis(isub).Plot(n).FontAngle='normal';
    data.Figure(ifig).Axis(isub).Plot(n).FontColor='black';
    data.Figure(ifig).Axis(isub).Plot(n).HorAl='center';
    data.Figure(ifig).Axis(isub).Plot(n).VerAl='baseline';

    data=PlotOptionsText('data',data);
    delete(plttmp);
    if length(data.DataProperties(kk).String)>0
        data.DataProperties(kk).Name=['Text ' data.DataProperties(kk).String];
        data.Figure(ifig).Axis(isub).Plot(n).Name=data.DataProperties(kk).Name;
        data=RefreshAvailableDatasets(data);
        data=RefreshActiveAvailableDatasetText(data);
        data=RefreshDatasetsInSubplot(data);
        FontRed=data.Figure(ifig).FontRed;
        figure(data.Figure(ifig).Handle);
        [tx,txc]=PlotText(data.DataProperties(kk),data.Figure(ifig).Axis(isub).Plot(n),data.DefaultColors,FontRed,1);
        guidata(mpt,data);
    end
    
end

set(gcf, 'windowbuttondownfcn','');
set(gcf,'Pointer','arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MoveMouse(imagefig, varargins)

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
else
    set(gcf, 'Pointer', 'crosshair');
    set(gcf, 'windowbuttondownfcn', {@GetTextPosition,h});
end
