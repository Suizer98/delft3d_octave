function muppet_UIEditAnnotationOptions(varargin)

if strcmp(get(gcf,'SelectionType'),'open')
    h=get(gcf,'CurrentObject');
    fig=getappdata(gcf,'figure');
    ifig=fig.number;
    isub=fig.nrsubplots;    
    n=get(h,'UserData');
    id=n(2);
    hh=getHandles;
    hh.activefigure=ifig;
    hh.activesubplot=isub;
    hh.activedatasetinsubplot=id;
    hh.figures(ifig).figure.subplots=fig.subplots;
    hh=muppet_editPlotOptions(hh);
    fig.subplots(isub).subplot.datasets(id).dataset=hh.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset;
    muppet_addAnnotation(fig,ifig,isub,id);
    fig.changed=1;
    fig.annotationschanged=1;
    setappdata(gcf,'figure',fig);
end
