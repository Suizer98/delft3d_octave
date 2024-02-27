function [plt,ptch]=DrawSpline(DataProperties,PlotOptions,DefaultColors,opt);

ptch=-1;

LineColor=FindColor(PlotOptions,'LineColor',DefaultColors);
FillColor=FindColor(PlotOptions,'FillColor',DefaultColors);
if PlotOptions.FillPolygons==0
    FillColor='none';
end

plt=plot(DataProperties.x,DataProperties.y);
set(plt,'Color',LineColor,'LineWidth',PlotOptions.LineWidth,'LineStyle',PlotOptions.LineStyle);
set(plt,'HitTest','off');

if PlotOptions.FillPolygons
    set(plt,'Visible','off');
    x=DataProperties.x;
    y=DataProperties.y;
    x(end+1)=x(1);
    y(end+1)=y(1);
    z=zeros(size(x))+1000;
    ptch=patch(x,y,z,'r');
    set(ptch,'EdgeColor',LineColor,'FaceColor',FillColor,'LineWidth',PlotOptions.LineWidth,'LineStyle',PlotOptions.LineStyle);
    set(ptch,'HitTest','off');
end

if opt==1

    n=length(DataProperties.x);

    for k=1:n
        z=zeros(size(DataProperties.x(k)))+1000;
        sh(k)=plot3(DataProperties.x(k),DataProperties.y(k),z,'ko');
        set(sh(k),'Tag','SelectionHighlight','MarkerSize',5);
        set(sh(k),'ButtonDownFcn',{@UIEditFreeHandObject});
        shusd.Parent=plt;
        shusd.nr=k;
        set(sh(k),'UserData',shusd);
    end

    usd.SelectionHighlights=sh;

    usd.plt=plt;
    usd.Name=DataProperties.Name;
    usd.Type='Polyline';
    usd.xy=[DataProperties.x;DataProperties.y];
    usd.n=n;
    usd.ptch=ptch;
    
    set(plt,'Tag','FreeHandPolyline');
    set(plt,'UserData',usd);

end
