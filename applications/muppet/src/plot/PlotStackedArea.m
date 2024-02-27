function handles=PlotStackedArea(handles,i,j,k,mode)

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

if strcmp(mode,'new') & Plt.AreaNr==1
    if strcmp(lower(Ax.PlotType),'timeseries') & strcmp(lower(Fig.Renderer),'opengl');
        xback = datenum(Ax.YearMin,Ax.MonthMin,Ax.DayMin,Ax.HourMin,Ax.MinuteMin,Ax.SecondMin);
    else
        xback=0;
    end
    x=Data.x-xback;
    ar=area(x,handles.StackedAreaY);hold on;
    set(ar,'Tag','area');
end

x00=[0 1 1];y00=[0 0 1];

ii=handles.Figure(i).Axis(j).Plot(k).AreaNr;
hh=sort(findobj(gca,'Tag','area'));

set(hh(ii),'FaceColor',FindColor(Plt.FillColor),'EdgeColor',FindColor(Plt.EdgeColor));
SetObjectData(hh(ii),i,j,k,'area');

hh=findobj('Tag','Areapatch','UserData',[i,j,k]);
delete(hh);
htmp=patch(x00,y00,'k','Tag','areapatch','UserData',[i,j,k]);
set(htmp,'FaceColor',FindColor(Plt.FillColor));
set(htmp,'EdgeColor',FindColor(Plt.EdgeColor));
set(htmp,'Visible','off');

handles.Figure(i).Axis(j).Plot(k).Handle=htmp;

