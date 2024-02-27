function handles=PlotHistogram(handles,i,j,k,mode)

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

if strcmp(mode,'new') & Plt.BarNr==1
    if strcmp(lower(Ax.PlotType),'timeseries') & strcmp(lower(Fig.Renderer),'opengl');
        xback = datenum(Ax.YearMin,Ax.MonthMin,Ax.DayMin,Ax.HourMin,Ax.MinuteMin,Ax.SecondMin);
    else
        xback=0;
    end
    x=Data.x-xback;
    h=bar(x,handles.BarY,'group');hold on;
    set(h,'Tag','bar');
end

x00=[0 1 1];y00=[0 0 1];

ii=handles.Figure(i).Axis(j).Plot(k).BarNr;
hh=sort(findobj(gca,'Tag','bar'));
set(hh(ii),'FaceColor',FindColor(Plt.FillColor),'EdgeColor',FindColor(Plt.EdgeColor));
SetObjectData(hh(ii),i,j,k,'bar');

hh=findobj('Tag','barpatch','UserData',[i,j,k]);
delete(hh);
htmp=patch(x00,y00,'k','Tag','barpatch','UserData',[i,j,k]);
set(htmp,'FaceColor',FindColor(Plt.FillColor));
set(htmp,'EdgeColor',FindColor(Plt.EdgeColor));
set(htmp,'Visible','off');

handles.Figure(i).Axis(j).Plot(k).Handle=htmp;

% if strcmp(lower(Data.Type),'bar')
%     Ax.xtcklab=DataProperties(n).XTickLabel;
% else
%     Ax.xtcklab=[];
% end
