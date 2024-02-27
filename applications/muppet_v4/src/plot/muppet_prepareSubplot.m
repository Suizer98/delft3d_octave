function muppet_prepareSubplot(handles,ifig,isub,leftaxis)

plt=handles.figures(ifig).figure.subplots(isub).subplot;

switch lower(plt.type)
    case {'timeseries'}
        muppet_setTimeSeriesPlot(handles,ifig,isub);
        if plt.rightaxis
            set(gca,'Color','white');
            rightaxis=axes;
            muppet_setRightAxis(handles,ifig,isub);
            set(rightaxis,'NextPlot','add');
            axes(leftaxis);
        end
    case {'xy'}
        muppet_setXYPlot(handles,ifig,isub);
        if plt.rightaxis
            set(gca,'Color','white');
            rightaxis=axes;
            muppet_setRightAxis(handles,ifig,isub);
            set(rightaxis,'NextPlot','add');
            axes(leftaxis);
        end
    case {'map'}
        muppet_setMapPlot(handles,ifig,isub);
    case {'image'}
        muppet_setImagePlot(handles,ifig,isub);
    case {'unknown'}
        muppet_setUnknownPlot(handles.figures(ifig).figure,isub);
    case {'3d'}
        muppet_set3DPlot(handles,ifig,isub);
    case {'rose'}
        muppet_setRosePlot(handles,ifig,isub);
    case {'timestack'}
        muppet_setTimeStackPlot(handles,ifig,isub);
end

if ~(strcmpi(plt.type,'3d') && plt.drawbox)
    
    xl=xlabel(plt.xlabel.text);
    set(xl,'FontSize',plt.xlabel.font.size*handles.figures(ifig).figure.fontreduction);
    set(xl,'FontName',plt.xlabel.font.name);
    set(xl,'Color',colorlist('getrgb','color',plt.xlabel.font.color));
    set(xl,'FontWeight',plt.xlabel.font.weight);
    set(xl,'FontAngle',plt.xlabel.font.angle);

    yl=ylabel(plt.ylabel.text);
    set(yl,'FontSize',plt.ylabel.font.size*handles.figures(ifig).figure.fontreduction);
    set(yl,'FontName',plt.ylabel.font.name);
    set(yl,'Color',colorlist('getrgb','color',plt.ylabel.font.color));
    set(yl,'FontWeight',plt.ylabel.font.weight);
    set(yl,'FontAngle',plt.ylabel.font.angle);
    
    tit=title(plt.title.text);
    set(tit,'FontSize',plt.title.font.size*handles.figures(ifig).figure.fontreduction);
    set(tit,'FontName',plt.title.font.name);
    set(tit,'Color',colorlist('getrgb','color',plt.title.font.color));
    set(tit,'FontWeight',plt.title.font.weight);
    set(tit,'FontAngle',plt.title.font.angle);

end

set(leftaxis,'NextPlot','add');
