function [plt,ptch]=DrawCurvedArrow(DataProperties,SubplotProperties,PlotOptions,DefaultColors,opt,nrhead);

ptch=-1;

Scale=SubplotProperties.Scale;

xy=[DataProperties.x;DataProperties.y];

n=size(xy,2);

np=20;

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

[xar,yar]=MakeCurvedArrow(xs2,ys2,Scale*0.0005*PlotOptions.ArrowWidth,Scale*0.0005*PlotOptions.HeadWidth,Scale*0.001*PlotOptions.HeadWidth,nrhead);
zar=zeros(size(xar))+1000;
plt=patch(xar,yar,zar,'k');

set(plt,'EdgeColor',LineColor,'LineStyle',PlotOptions.LineStyle,'FaceColor',FillColor);
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
    if nrhead==1
        usd.Type='CurvedArrow';
    else
        usd.Type='CurvedDoubleArrow';
    end
    usd.xy=xy;
    usd.n=n;
    usd.ptch=ptch;

    if nrhead==1
        set(plt,'Tag','FreeHandCurvedArrow');
    else
        set(plt,'Tag','FreeHandCurvedDoubleArrow');
    end
    set(plt,'UserData',usd);

end
