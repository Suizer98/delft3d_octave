function handles=AdjustAxes(handles)

ifig=handles.ActiveFigure;

figure(handles.Figure(ifig).Handle);

plotedit off;

if handles.Figure(ifig).NrAnnotations>0
    nrsub=handles.Figure(ifig).NrSubplots-1;
else
    nrsub=handles.Figure(ifig).NrSubplots;
end

for i=1:nrsub
    ii=findobj(gcf,'Tag','axis','UserData',[ifig,i]);
    if isempty(ii)
        handles.ActiveSubplot=i;
        handles=DeleteSubplot(handles);
        figure(handles.Figure(ifig).Handle);
    end
end

if handles.Figure(ifig).NrAnnotations>0
    nrsub=handles.Figure(ifig).NrSubplots-1;
else
    nrsub=handles.Figure(ifig).NrSubplots;
end

for i=1:nrsub
    ax=findobj(gcf,'Tag','axis','UserData',[ifig,i]);
    if handles.Figure(ifig).Axis(i).AxesEqual
        pos0=handles.Figure(ifig).Axis(i).Position;
        posn=get(ax,'Position')/handles.Figure(ifig).cm2pix;
        if posn(4)/posn(3)>pos0(4)/pos0(3)
            pos1(1)=posn(1);
            pos1(3)=posn(3);
            pos1(4)=pos1(3)*pos0(4)/pos0(3);
            pos1(2)=posn(2)+posn(4)/2-pos1(4)/2;
        else
            pos1(2)=posn(2);
            pos1(4)=posn(4);
            pos1(3)=pos1(4)*pos0(3)/pos0(4);
            pos1(1)=posn(1)+posn(3)/2-pos1(3)/2;
        end
        pos1=round(100*pos1)/100;
        handles.Figure(ifig).Axis(i).Position=pos1;
    else
        if ~strcmpi(handles.Figure(ifig).Axis(i).PlotType,'3d')
            pos1=get(ax,'Position') ...
                /handles.Figure(ifig).cm2pix;
            pos1=round(100*pos1)/100;
            handles.Figure(ifig).Axis(i).Position=pos1;
        end
    end
    if ~strcmpi(handles.Figure(ifig).Axis(i).PlotType,'3d')
        set(ax,'Position',pos1*handles.Figure(ifig).cm2pix);
    end
    
    if handles.Figure(ifig).Axis(i).AxesEqual==0 && strcmpi(handles.Figure(ifig).Axis(i).PlotType,'2d')
        VertScale=(handles.Figure(ifig).Axis(i).YMax-handles.Figure(ifig).Axis(i).YMin)/handles.Figure(ifig).Axis(i).Position(4);
        HoriScale=(handles.Figure(ifig).Axis(i).XMax-handles.Figure(ifig).Axis(i).XMin)/handles.Figure(ifig).Axis(i).Position(3);
        MultiY=HoriScale/VertScale;
    else
        MultiY=1.0;
    end
    MultiY=1.0;
    
    if ~strcmpi(handles.Figure(ifig).Axis(i).PlotType,'3d')
        xlim=get(ax,'XLim');
        if strcmpi(handles.Figure(ifig).Axis(i).PlotType,'timeseries') && strcmpi(handles.Figure(ifig).Renderer,'opengl')
            xmin0 = datenum(handles.Figure(ifig).Axis(i).YearMin,handles.Figure(ifig).Axis(i).MonthMin, ...
                handles.Figure(ifig).Axis(i).DayMin,handles.Figure(ifig).Axis(i).HourMin, ...
                handles.Figure(ifig).Axis(i).MinuteMin,handles.Figure(ifig).Axis(i).SecondMin);
            xlim=xlim+xmin0;
        end
        ylim=get(ax,'YLim');
        ylim=ylim/MultiY;
        handles.Figure(ifig).Axis(i).XMin=xlim(1);
        handles.Figure(ifig).Axis(i).XMax=xlim(2);
        handles.Figure(ifig).Axis(i).YMin=ylim(1);
        handles.Figure(ifig).Axis(i).YMax=ylim(2);
        handles.Figure(ifig).Axis(i).Scale=(xlim(2)-xlim(1))/(0.01*handles.Figure(ifig).Axis(i).Position(3));
    end
    
    if strcmpi(handles.Figure(ifig).Axis(i).PlotType,'timeseries')
        xmin=handles.Figure(ifig).Axis(i).XMin;
        xmax=handles.Figure(ifig).Axis(i).XMax;
        handles.Figure(ifig).Axis(i).YearMin=str2num(datestr(xmin,'yyyy'));
        handles.Figure(ifig).Axis(i).YearMax=str2num(datestr(xmax,'yyyy'));
        handles.Figure(ifig).Axis(i).MonthMin=str2num(datestr(xmin,'mm'));
        handles.Figure(ifig).Axis(i).MonthMax=str2num(datestr(xmax,'mm'));
        handles.Figure(ifig).Axis(i).DayMin=str2num(datestr(xmin,'dd'));
        handles.Figure(ifig).Axis(i).DayMax=str2num(datestr(xmax,'dd'));
        handles.Figure(ifig).Axis(i).HourMin=str2num(datestr(xmin,'HH'));
        handles.Figure(ifig).Axis(i).HourMax=str2num(datestr(xmax,'HH'));
        handles.Figure(ifig).Axis(i).MinuteMin=str2num(datestr(xmin,'MM'));
        handles.Figure(ifig).Axis(i).MinuteMax=str2num(datestr(xmax,'MM'));
        handles.Figure(ifig).Axis(i).SecondMin=str2num(datestr(xmin,'SS'));
        handles.Figure(ifig).Axis(i).SecondMax=str2num(datestr(xmax,'SS'));
    end

    if strcmpi(handles.Figure(ifig).Axis(i).PlotType,'3d')
        h=ax;
        [az,el] = view(h);
        CameraTarget=get(h,'CameraTarget');
        CameraViewAngle=get(h,'CameraViewAngle');
        handles.Figure(ifig).Axis(i).CameraAngle(1)=az;
        handles.Figure(ifig).Axis(i).CameraAngle(2)=el;
        handles.Figure(ifig).Axis(i).CameraViewAngle=CameraViewAngle;
        handles.Figure(ifig).Axis(i).CameraTarget=CameraTarget;
    end

    if handles.Figure(ifig).Axis(i).PlotLegend
        hh=findobj(gcf,'Tag','legend');
        for ii=1:length(hh)
            d=getappdata(hh(ii));
            legdat=d.LegendData;
            if d.LegendData.i==ifig && d.LegendData.j==i
                h=hh(ii);
            end
        end
        loc=get(h,'Location');
        if strcmp(loc,'none') || isempty(loc)
            pos=get(h,'Position')/handles.Figure(ifig).cm2pix;
            pos=round(100*pos)/100;
            handles.Figure(ifig).Axis(i).LegendPosition=pos;
        end
    end

    if handles.Figure(ifig).Axis(i).PlotColorBar
        h=findobj(gcf,'Tag','colorbar','UserData',[ifig,i]);
        pos1=get(h,'Position')/handles.Figure(ifig).cm2pix;
        pos1=round(100*pos1)/100;
        handles.Figure(ifig).Axis(i).ColorBarPosition=pos1;
    end

    if handles.Figure(ifig).Axis(i).PlotVectorLegend
        h=findobj(gcf,'Tag','vectorlegend','UserData',[ifig,i]);
        pos1=get(h,'Position')/handles.Figure(ifig).cm2pix;
        pos1=round(100*pos1)/100;
        handles.Figure(ifig).Axis(i).VectorLegendPosition=pos1(1:2);
    end

    if handles.Figure(ifig).Axis(i).PlotScaleBar
        h=findobj(gcf,'Tag','scalebar','UserData',[ifig,i]);
        pos1=get(h,'Position')/handles.Figure(ifig).cm2pix;
        pos1=round(100*pos1)/100;
        handles.Figure(ifig).Axis(i).ScaleBar(1:2)=pos1(1:2);
        len=0.01*pos1(3)*handles.Figure(ifig).Axis(i).Scale;
        if len/handles.Figure(ifig).Axis(i).ScaleBar(3)<0.98 || len/handles.Figure(ifig).Axis(i).ScaleBar(3)>1.02
            handles.Figure(ifig).Axis(i).ScaleBar(3)=len;
            handles.Figure(ifig).Axis(i).ScaleBarText=[num2str(round(len)) ' m'];
        end
    end

    if handles.Figure(ifig).Axis(i).PlotNorthArrow
        h=findobj(gcf,'Tag','northarrow','UserData',[ifig,i]);
        pos0(1)=handles.Figure(ifig).Axis(i).NorthArrow(1);
        pos0(2)=handles.Figure(ifig).Axis(i).NorthArrow(2);
        pos0(3)=handles.Figure(ifig).Axis(i).NorthArrow(3);
        pos0(4)=handles.Figure(ifig).Axis(i).NorthArrow(3);
        posn=get(h,'Position')/handles.Figure(ifig).cm2pix;
        if posn(4)/posn(3)>pos0(4)/pos0(3)
            pos1(1)=posn(1);
            pos1(3)=posn(3);
            pos1(4)=pos1(3)*pos0(4)/pos0(3);
            pos1(2)=posn(2)+posn(4)/2-pos1(4)/2;
        else
            pos1(2)=posn(2);
            pos1(4)=posn(4);
            pos1(3)=pos1(4)*pos0(3)/pos0(4);
            pos1(1)=posn(1)+posn(3)/2-pos1(3)/2;
        end
        pos1=round(100*pos1)/100;
        handles.Figure(ifig).Axis(i).NorthArrow(1)=pos1(1);
        handles.Figure(ifig).Axis(i).NorthArrow(2)=pos1(2);
        handles.Figure(ifig).Axis(i).NorthArrow(3)=pos1(3);
    end

    hh=get(ax,'Title');
    str=get(hh,'String');
    if size(str)>0
        handles.Figure(ifig).Axis(i).Title=str(1,:);
    end
    hh=get(ax,'XLabel');
    str=get(hh,'String');
    if size(str)>0
        handles.Figure(ifig).Axis(i).XLabel=str(1,:);
    end
    hh=get(ax,'YLabel');
    str=get(hh,'String');
    if size(str)>0
        handles.Figure(ifig).Axis(i).YLabel=str(1,:);
    end

    for k=1:handles.Figure(ifig).Axis(i).Nr
        if handles.Figure(ifig).Axis(i).Plot(k).PlotColorBar
            h=findobj(gcf,'Tag','colorbar','UserData',[ifig,i,k]);
            pos1=get(h,'Position')/handles.Figure(ifig).cm2pix;
            pos1=round(100*pos1)/100;
            handles.Figure(ifig).Axis(i).Plot(k).ColorBarPosition=pos1;
        end
    end

end

% Annotations

overl=findall(gcf,'Tag','scribeOverlay');
ch0=get(overl,'Children');
nann=0;
for k=1:length(ch0)
    if ~strcmp(get(ch0(k),'Tag'),'text') && ~isempty(get(ch0(k),'Tag'))
        switch(get(ch0(k),'Tag')),
            case{'line','arrow','doublearrow','rectangle','ellipse','textbox'}            
                nann=nann+1;
                ch(nann)=ch0(k);
        end
    end
end

for kk=1:nann
    usd=get(ch(kk),'UserData');
    k=usd(2);
    cc=ch(kk);
    sz=handles.Figure(ifig).PaperSize;
    pos=get(cc,'Position');
    handles.Figure(ifig).Annotation(k).Position(1)=pos(1)*sz(1);
    handles.Figure(ifig).Annotation(k).Position(2)=pos(2)*sz(2);
    handles.Figure(ifig).Annotation(k).Position(3)=pos(3)*sz(1);
    handles.Figure(ifig).Annotation(k).Position(4)=pos(4)*sz(2);
    pos=handles.Figure(ifig).Annotation(k).Position;
    pos=round(100*pos)/100;
    handles.Figure(ifig).Annotation(k).Position=pos;
end
