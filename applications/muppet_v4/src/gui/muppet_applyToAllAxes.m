function handles=muppet_applyToAllAxes(handles)

fig=handles.figures(handles.activefigure).figure;

if fig.nrsubplots>0
    
    k=handles.activesubplot;
    plt0=fig.subplots(k).subplot;
    plottype=plt0.type;
    
    for ii=1:fig.nrsubplots
        
        if strcmpi(fig.subplots(ii).subplot.type,plottype) && ii~=k
            
            plt1=fig.subplots(ii).subplot;
            
            plt1.xmin=plt0.xmin;
            plt1.xmax=plt0.xmax;
            plt1.ymin=plt0.ymin;
            plt1.ymax=plt0.ymax;
            plt1.scale=plt0.scale;
            plt1.axesequal=plt0.axesequal;
            plt1.coordinatesystem=plt0.coordinatesystem;
            plt1.xtick=plt0.xtick;
            plt1.ytick=plt0.ytick;
            plt1.xgrid=plt0.xgrid;
            plt1.ygrid=plt0.ygrid;
            plt1.xdecimals=plt0.xdecimals;
            plt1.ydecimals=plt0.ydecimals;
            plt1.xscale=plt0.xscale;
            plt1.yscale=plt0.yscale;
            plt1.timegrid=plt0.timegrid;
            plt1.datetickformat=plt0.datetickformat;
            plt1.yearmin=plt0.yearmin;
            plt1.yearmax=plt0.yearmax;
            plt1.xtickmultiply=plt0.xtickmultiply;
            plt1.ytickmultiply=plt0.ytickmultiply;
            plt1.xtickadd=plt0.xtickadd;
            plt1.ytickadd=plt0.ytickadd;
            plt1.monthmin=plt0.monthmin;
            plt1.monthmax=plt0.monthmax;
            plt1.daymin=plt0.daymin;
            plt1.daymax=plt0.daymax;
            plt1.hourmin=plt0.hourmin;
            plt1.hourmax=plt0.hourmax;
            plt1.minutemin=plt0.minutemin;
            plt1.minutemax=plt0.minutemax;
            plt1.secondmin=plt0.secondmin;
            plt1.secondmax=plt0.secondmax;
            plt1.yeartick=plt0.yeartick;
            plt1.monthtick=plt0.monthtick;
            plt1.daytick=plt0.daytick;
            plt1.hourtick=plt0.hourtick;
            plt1.minutetick=plt0.minutetick;
            plt1.secondtick=plt0.secondtick;
            plt1.adddate=plt0.adddate;
%            plt1.datetickformatnumber=plt0.datetickformatnumber;
            plt1.font=plt0.font;
            
            fig.subplots(ii).subplot=plt1;
            
        end
    end

    handles.figures(handles.activefigure).figure=fig;

end
