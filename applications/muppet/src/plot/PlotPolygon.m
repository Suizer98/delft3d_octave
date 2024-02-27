function handles=PlotPolygon(handles,i,j,k,mode)

Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

x=Data.x;
y=Data.y;

if strcmp(mode,'new')
    if Plt.FillPolygons==1
%        h2=PlotPatches(x,y,Plt.PolygonElevation,Plt.MaxDistance);
        ldb=[x y];
        h2=filledLDB(ldb,[0 0 0],[0 1 0],Plt.MaxDistance,Plt.PolygonElevation);
        if ~isempty(h2)
            SetObjectData(h2,i,j,k,'patch');
        end
    end
    z=zeros(size(x));
    z=z+Plt.PolygonElevation;
    h1=line(x,y,z);
    SetObjectData(h1,i,j,k,'line');
end

h1=findobj(gcf,'Tag','line','UserData',[i,j,k]);

if ~isempty(h1)
    set(h1,'LineWidth',Plt.LineWidth,'Color',FindColor(Plt.LineColor));hold on;
    z=zeros(size(get(h1,'ZData')))+Plt.PolygonElevation;
    set(h1,'ZData',z);
    if ~isempty(Plt.LineStyle)
        set(h1,'LineStyle',Plt.LineStyle);
    else
        set(h1,'LineStyle','none');
    end        
end

h2=findobj('Tag','patch','UserData',[i,j,k]);
if Plt.FillPolygons==1
%     if ~isempty(h2)
%         h2=PlotPatches(x,y,Plt.PolygonElevation,Plt.MaxDistance);
%         if ~isempty(h2)
%             SetObjectData(h2,i,j,k,'patch');
%         end
%     end        
    if ~isempty(h2)
%         a = makehatch('/');
%         applyhatch(h2,a,[1 0 0]);
%        hatch(h2,45,'r','-',[8],[2]);
%        hatch(h2,'cross');
%        set(h2,'FaceColor','none');

        set(h2,'EdgeColor',FindColor(Plt.LineColor));
        set(h2,'FaceColor',FindColor(Plt.FillColor));
    end
    z=zeros(size(get(h1,'ZData')))+Plt.PolygonElevation;
    set(h1,'ZData',z);
else
    delete(h2);
end

if Plt.FillPolygons==1 && ~isempty(h2)
    hh=findobj(gcf,'Tag','barpatch','UserData',[i,j,k]);
    delete(hh);
    x00=[0 1 1];y00=[0 0 1];
    htmp=patch(x00,y00,'k','Tag','barpatch','UserData',[i,j,k]);
    set(htmp,'FaceColor',FindColor(Plt.FillColor));
    set(htmp,'EdgeColor',FindColor(Plt.LineColor));
    set(htmp,'LineWidth',Plt.LineWidth);
    if ~isempty(Plt.LineStyle)
        set(htmp,'LineStyle',Plt.LineStyle);
    else
        set(htmp,'LineStyle','none');
    end        
    set(htmp,'Visible','off');
    handles.Figure(i).Axis(j).Plot(k).Handle=htmp;
else
    handles.Figure(i).Axis(j).Plot(k).Handle=h1;
end

clear x y z ldb



function h2=PlotPatches(x,y,elev,dmax)

h2=[];

polno=1;
j=1;
for i=1:size(x,1);
    if (isnan(x(i)))
        polno=polno+1;
        j=1;
    else
        ldbx{polno}(j)=x(i);
        ldby{polno}(j)=y(i);
        ldbz{polno}(j)=elev;
        j=j+1;
    end
end

if isnan(x(end))
    polno=polno-1;
end

k=0;
for i=1:polno
    if ~isempty(ldbx{i})
        if abs(ldbx{i}(1)-ldbx{i}(end))<=dmax && abs(ldby{i}(1)-ldby{i}(end))<=dmax
            k=k+1;
            h2(k)=patch(ldbx{i},ldby{i},ldbz{i},'r','LineStyle','none');hold on;
%            h2(k)=patch(ldbx{i},ldby{i},'r','LineStyle','none');hold on;
        end
    end
end


