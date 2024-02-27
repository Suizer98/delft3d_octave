function PrepareSubplot(handles,i,j,LeftAxis)

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
PlotOptions=handles.Figure(i).Axis(j).Plot;
DataProperties=handles.DataProperties;

%Ax.xtcklab=[];

switch lower(Ax.PlotType),
    case {'timeseries'},
        SetHisPlot(Fig,Ax);
        if Ax.RightAxis
            set(gca,'Color','white');
            RightAxis=axes;
            SetRightAxis(Fig,Ax,RightAxis);
            set(RightAxis,'NextPlot','add');
            axes(LeftAxis);
        end
    case {'xy'},
        SetXYPlot(Fig,Ax);
        if Ax.RightAxis
            set(gca,'Color','white');
            RightAxis=axes;
            SetRightAxis(Fig,Ax,RightAxis);
            set(RightAxis,'NextPlot','add');
        end
    case {'2d'},
        SetMapPlot(Fig,Ax);
    case {'image'},
        SetImagePlot(Fig,Ax,PlotOptions,DataProperties);
    case {'unknown'},
        SetUnknownPlot(Fig,Ax);
    case {'3d'},
        Set3DPlot(Fig,Ax);
    case {'rose'},
        SetRosePlot(Fig,Ax);
    case {'timestack'},
        SetTimeStackPlot(Fig,Ax);
end

if ~(strcmpi(Ax.PlotType,'3d') && Ax.DrawBox)
    xl=xlabel(Ax.XLabel);
    set(xl,'FontSize',Ax.XLabelFontSize*handles.Figure(i).FontRed);
    set(xl,'FontName',Ax.XLabelFont);
    set(xl,'Color',FindColor(Ax.XLabelFontColor));
    set(xl,'FontWeight',Ax.XLabelFontWeight);
    set(xl,'FontAngle',Ax.XLabelFontAngle);
    yl=ylabel(Ax.YLabel);
    set(yl,'FontSize',Ax.YLabelFontSize*handles.Figure(i).FontRed);
    set(yl,'FontName',Ax.YLabelFont);
    set(yl,'Color',FindColor(Ax.YLabelFontColor));
    set(yl,'FontWeight',Ax.YLabelFontWeight);
    set(yl,'FontAngle',Ax.YLabelFontAngle);
    tit=title(Ax.Title);
    set(tit,'FontSize',Ax.TitleFontSize*handles.Figure(i).FontRed);
    set(tit,'FontName',Ax.TitleFont);
    set(tit,'Color',FindColor(Ax.TitleFontColor));
    set(tit,'FontWeight',Ax.TitleFontWeight);
    set(tit,'FontAngle',Ax.TitleFontAngle);
end

set(LeftAxis,'NextPlot','add');

