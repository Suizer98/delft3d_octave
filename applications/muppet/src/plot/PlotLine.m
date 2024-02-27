function handles=PlotLine(handles,i,j,k,mode)

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
ColorMaps=handles.ColorMaps;
DefaultColors=handles.DefaultColors;

switch lower(Ax.XScale),
    case{'linear','logarithmic'}
        x=Data.x;
    case{'normprob'}
        x=norminv(0.01*Data.x,0,1);
end

if strcmpi(Ax.PlotType,'timeseries')
    xmin = datenum(Ax.YearMin,Ax.MonthMin,Ax.DayMin,Ax.HourMin,Ax.MinuteMin,Ax.SecondMin);
    xmax = datenum(Ax.YearMax,Ax.MonthMax,Ax.DayMax,Ax.HourMax,Ax.MinuteMax,Ax.SecondMax);
    if strcmpi(Fig.Renderer,'opengl');
        xback=xmin;
        xmin=xmin-xback;
        xmax=xmax-xback;
        x=x-xback;
    else
        xback=0;
    end
else
    xmin=Ax.XMin;
    xmax=Ax.XMax;
    xback=0;
end

switch lower(Ax.YScale),
    case{'linear','logarithmic'}
        y=Data.y;
    case{'normprob'}
        y=norminv(0.01*Data.y,0,1);
end

if Plt.RightAxis
    a=(Data.y-Ax.YMinRight)/(Ax.YMaxRight-Ax.YMinRight);
    y=Ax.YMin+a*(Ax.YMax-Ax.YMin);
end

if strcmp(mode,'new')

    if strcmpi(Plt.PlotRoutine,'plotspline')

        dx=(xmax-xmin)/1000;
        xx=xmin:dx:xmax;
        tmp0(:,1)=x;
        tmp0(:,2)=y;
        [dum,ord]=sort(x,1);
        for ii=1:size(x,1);
            x(ii)=tmp0(ord(ii),1);
            y(ii)=tmp0(ord(ii),2);
        end

        kk=1;
        x1(1)=x(1);
        y1(1)=y(1);
        for ii=2:size(x,1)
            if x(ii)>x1(kk)
                kk=kk+1;
                x1(kk)=x(ii);
                y1(kk)=y(ii);
            end
        end

        yy = interp1(x1,y1,xx,'pchip');

        h1=plot(xx,yy);
        SetObjectData(h1,i,j,k,'line');
        if strcmpi(Plt.Marker,'none')==0
            h2=plot(x,y);
            SetObjectData(h2,i,j,k,'marker');
        end
        hold on;
    else
        h1=plot(x,y);
        SetObjectData(h1,i,j,k,'xyline');
        hold on;
    end
end
    
if strcmpi(Plt.PlotRoutine,'plotspline')
    h1=findobj(gcf,'Tag','line','UserData',[i,j,k]);
    h2=findobj(gcf,'Tag','marker','UserData',[i,j,k]);
    if ~isempty(h1)>0
        set(h1,'Color',FindColor(Plt.LineColor));
        set(h1,'LineStyle',Plt.LineStyle);
        set(h1,'LineWidth',Plt.LineWidth);
    end
    if ~isempty(h2)>0
        set(h2,'Color',FindColor(Plt.LineColor));
        set(h2,'LineStyle','none');
        set(h2,'Marker',Plt.Marker);
    end
else
    h1=findobj(gcf,'Tag','xyline','UserData',[i,j,k]);
    set(h1,'Color',FindColor(Plt.LineColor));
    set(h1,'LineStyle',Plt.LineStyle);
    set(h1,'LineWidth',Plt.LineWidth);
    set(h1,'Marker',Plt.Marker);
end

h3=findobj('Tag','timebar','UserData',[i,j,k]);
delete(h3);
if Plt.TimeBar(1)>0
    mattim=MatTime(Plt.TimeBar(1),Plt.TimeBar(2));

    xt(1)=mattim-xback;
    xt(2)=mattim-xback;
    yt(1)=Ax.YMin;
    yt(2)=Ax.YMax;
    h3=plot(xt,yt,'r','LineWidth',3);

%     xt(1)=xmin;
%     xt(2)=mattim-xback;
%     yt(1)=0.5*(Ax.YMin+Ax.YMax);
%     yt(2)=yt(1);
%     h3=plot(xt,yt,'r','LineWidth',50);

    
    SetObjectData(h3,i,j,k,'timebar');
end

handles.Figure(i).Axis(j).Plot(k).Handle=h1;

clear x1 y1 xx yy x y xmin xmax
