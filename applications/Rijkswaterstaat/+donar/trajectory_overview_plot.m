function trajectory_overview_plot(S,M,E,L,varargin)
%trajectory_overview_plot plot maps and timeseries of trajectory
%
%  trajectory_overview_plot(S,M,E,L,titletxt,<keyword,value>)
%
%See also: trajectory_struct, trajectory2nc

OPT.clims      = [nan nan];
OPT.scatter    = 0; % SLOW !!
OPT.titletxt   = '';
OPT = setproperty(OPT,varargin);

AX = subplot_meshgrid(2,2,[.07 .01 .06],[.025 .04 .045],[nan .1],[nan .14]);
AX = subplot_meshgrid(2,3,[.07 .01 .06],[.025 .04 .01 .045],[nan .1],[nan .14 .14]);

if isnan(OPT.clims(1))
    OPT.clims(1) = nanmin(S.data(:))-100*eps;
end
if isnan(OPT.clims(2))
    OPT.clims(2) = nanmax(S.data(:))+100*eps;
end
clim([OPT.clims])

%%
axes(AX(1,1))

    if OPT.scatter % SLOW !!
    plot(S.lon,S.lat,'k-','color',[.5 .5 .5])
    hold on
    scatter(S.lon,S.lat,40,S.data,'.')
    else
    plot(S.lon,S.lat,'k-','color',[.5 .5 .5])
    hold on
    plot(S.lon,S.lat,'ko','markerfacecolor','k','markersize',4)
    end
    plot(L.lon,L.lat,'-' ,'color',[0 0 0])
    plot(E.lon,E.lat,'--','color',[0 0 0])
    grid on
    axis([-1.7 9.7 50.7 56])    
   [cb, h]=colorbarwithvtext(mktex({M.data.long_name,[M.data.WNS,':',M.data.aquo_grootheid_code,' [',M.data.units,']']}),...
       'position',get(AX(2,1),'position'));
    delete(AX(2,1))
    ctick      = get(cb,'ytick');
    cticklabel = get(cb,'yticklabel');
    axislat
    set(AX(1,1),'ytick',[51:56])
    tickmap('ll')
    ylabel(OPT.titletxt); % [datestr(min(S.datenum),'yyyy-mmm-dd'),' - ',datestr(max(S.datenum),'yyyy-mmm-dd')]
    box on
    
axes(AX(1,2))
    if OPT.scatter % SLOW !!
    plot(S.datenum,S.data,'k-','color',[.5 .5 .5])
    hold on
    scatter(S.datenum,S.data,40,S.data,'.')
    else
    plot(S.datenum,S.data,'k-','color',[.5 .5 .5])
    hold on
    plot(S.datenum,S.data,'ko','markerfacecolor','k','markersize',4)
    end
    axis tight
    datetick('x')
    set(gca,'xticklabel',{})
    %text(1,0,{[datestr(min(S.datenum(:)),'yyyy-mmm-dd')],[datestr(max(S.datenum(:)),'yyyy-mmm-dd')]},'vert','top','hor','left','rot',90,'units','norm')
    ylim(OPT.clims)
    ylabel([M.data.aquo_grootheid_code,' [',M.data.units,']'])
    %set(AX(2),'ytick'     ,ctick )
    %set(AX(2),'yticklabel',cticklabel)
    grid on
    box on
    
axes(AX(2,2))
   [N,X]=hist(S.data(:),50);
    stairscorcen(X,N,'flip',1,'facecolor',[.5 .5 .5],'edgecolor','k')
    ylim(OPT.clims)    
    grid on
    set(gca,'xticklabel',{})
    set(gca,'yticklabel',{})  
    
%     position = get(AX(1,2),'position');
%     position(3) = .87;
%     set(AX(1,2),'position',position)
%     delete(AX(2,2))
    
axes(AX(1,3))
    if OPT.scatter % SLOW !!
    plot(S.datenum,S.z,'k-','color',[.5 .5 .5])
    hold on
    scatter(S.datenum,S.z,40,S.z,'.')
    else
    plot(S.datenum,S.z,'k-','color',[.5 .5 .5])
    hold on
    plot(S.datenum,S.z,'ko','markerfacecolor','k','markersize',4)
    end
    axis tight
    datetick('x')
    %text(1,0,{['z_{min}=',num2str(min(S.z(:)))],['z_{max}=',num2str(max(S.z(:)))]},'vert','top','hor','left','rot',90,'units','norm')
    ylabel(['depth [',M.z.units,']'])
    set(gca,'ydir','reverse')
    %set(AX(2),'ytick'     ,ctick )
    %set(AX(2),'yticklabel',cticklabel)
    grid on
    box on    
    
%     position = get(AX(1,3),'position');
%     position(3) = .87;
%     set(AX(1,3),'position',position)
%     delete(AX(2,3))    

axes(AX(2,3))
   [N,X]=hist(S.z(:),50);
    stairscorcen(X,N,'flip',1,'facecolor',[.5 .5 .5],'edgecolor','k')
    ylim(OPT.clims)
    grid on
    ylim(get(AX(1,3),'ylim'))    
    set(gca,'ydir','reverse')   
    set(gca,'xticklabel',{})
    set(gca,'yticklabel',{})    