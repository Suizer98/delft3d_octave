function ctd_timeSeriesProfile_plot(P,E,L,titletxt,varargin)
%CTD_TIMESERIESPROFILE_PLOT plot timeseries of profiles at 1 location
%
%  P = ctd_timeSeriesProfile_plot(P,titletext)
%
% where P = ctd_timeSeriesProfile(..)
%
%See also: ctd_struct, ctd_timeSeriesProfile

OPT.colorfield = 'z';
OPT.colorlabel = 'z [cm]';
OPT.clims      = [nan nan];
OPT = setproperty(OPT,varargin);

    if isnan(OPT.clims(1))
        OPT.clims(1) = nanmin(P.(OPT.colorfield)(:))-100*eps;
    end
    if isnan(OPT.clims(2))
        OPT.clims(2) = nanmax(P.(OPT.colorfield)(:))+100*eps;
    end

   %setfig2screensize
   
    AX = subplot_meshgrid(4,2,[.05 .01 .08 .01 .05],[.04 .08 .06],[nan .03 nan .03],nan);
    
    nt = length(P.profile_id);
    nz = max(P.profile_n);

    [tt,zz] = meshgrid(1:nt,1:nz);

    axes(AX(1,1));%subplot(2,2,1)
    plot(P.profile_lon,P.profile_lat,'ko','markerfacecolor','r')
    hold on
    scatter(mean(P.profile_lon),mean(P.profile_lat),50,log10(nt),'filled')    
    hold on
    plot(L.lon,L.lat,'-' ,'color',[0 0 0])
    plot(E.lon,E.lat,'--','color',[0 0 0])        
    title(titletxt)
    grid on
    axis([-2 9 50 57])    
    axislat
    tickmap('ll')
    box on
    delete(AX(2,1))

    axes(AX(1,2));%subplot(2,2,2)
    if nt > 1
    pcolorcorcen(tt,zz,P.(OPT.colorfield));
    hold on
    else
    scatter     (tt(:),zz(:),10,P.(OPT.colorfield)(:),'filled');
    hold on
    end
    set(gca,'Color',[.8 .8 .8])
    plot(tt,zz,'k.','markersize',4); 
    set(gca,'YDir','reverse')
    xlabel('netCDF index of profile [#]')
    ylabel('netCDF ragged array index [#]')
    clim([OPT.clims])
    [ax,~]=colorbarwithvtext(OPT.colorlabel,'position',get(AX(2,2),'position'));
    title('<netCDF matrix space>')
    set(ax,'YDir','reverse')
    grid on
    ttick = get(gca,'xtick');
    box on
    delete(AX(2,2))

    axes(AX(3,2));%subplot(2,2,3)
    colors = clrmap(jet,nt);
    for it=1:nt
    plot(zz(:,it),P.z(:,it),'.-','markersize',5,'color',colors(it,:));   
    hold on
    end
    set(gca,'YDir','reverse')
    ylabel('value of z [cm]')
    xlabel('netCDF ragged array index [#]')
    grid on
    clim([1 max(2,nt)])
    [ax,~]=colorbarwithvtext('netCDF index of profile [#]',ttick,'position',get(AX(4,2),'position'));
    box on
    delete(AX(4,2))    

    axes(AX(3,1));%subplot(2,2,4)
    if nt > 1
    pcolorcorcen(P.datenum,P.z,P.(OPT.colorfield));
    hold on
    else
    scatter     (P.datenum(:),P.z(:),10,P.(OPT.colorfield)(:),'filled');
    hold on
    end
    plot(P.datenum,P.z,'k.','markersize',4); 
    set(gca,'YDir','reverse')
    datetick('x')
    xlabel('time');
    ylabel('z [cm]')
    clim([OPT.clims])
    [ax,~]=colorbarwithvtext(OPT.colorlabel,'position',get(AX(4,1),'position'));
    title('<world space>')
    set(ax,'YDir','reverse')
    grid on
    box on
    delete(AX(4,1))      
    