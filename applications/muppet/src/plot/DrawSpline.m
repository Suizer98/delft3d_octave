function [plt,ptch]=DrawSpline(DataProperties,PlotOptions,DefaultColors,opt);

ptch=-1;

xy=[DataProperties.x;DataProperties.y];

np=20;

n=size(xy,2);

t = 1:n;
ts = 1:(1/np):n;
xys = spline(t,xy,ts);

xs=xys(1,:);
ys=xys(2,:);

pd0=pathdistance(xs,ys);
pd=0:(pd0(end)/(np*n)):pd0(end);

xs2=interp1(pd0,xs,pd);
ys2=interp1(pd0,ys,pd);

LineColor=FindColor(PlotOptions,'LineColor',DefaultColors);
FillColor=FindColor(PlotOptions,'FillColor',DefaultColors);
if PlotOptions.FillPolygons==0
    FillColor='none';
end

plt=plot(xs2,ys2);
set(plt,'Color',LineColor,'LineWidth',PlotOptions.LineWidth,'LineStyle',PlotOptions.LineStyle);

if PlotOptions.FillPolygons
    set(plt,'Visible','off');
    xs2(end+1)=xs2(1);
    ys2(end+1)=ys2(1);
    zs2=zeros(size(xs2))+1000;
    ptch=patch(xs2,ys2,zs2,'r');
    set(ptch,'EdgeColor',LineColor,'FaceColor',FillColor,'LineWidth',PlotOptions.LineWidth,'LineStyle',PlotOptions.LineStyle);
    set(ptch,'HitTest','off');
end

set(plt,'HitTest','off');

if opt==1

    for k=1:n
        sh(k)=plot3(xy(1,k),xy(2,k),1000,'ko');
        set(sh(k),'Tag','SelectionHighlight','MarkerSize',5);
        set(sh(k),'ButtonDownFcn',{@UIEditFreeHandObject});
        shusd.Parent=plt;
        shusd.nr=k;
        set(sh(k),'UserData',shusd);
    end

    usd.SelectionHighlights=sh;

    usd.plt=plt;
    usd.Name=DataProperties.Name;
    usd.Type='Spline';
    usd.xy=xy;
    usd.n=n;
    usd.ptch=ptch;
    
    set(plt,'Tag','FreeHandSpline');
    set(plt,'UserData',usd);

end
