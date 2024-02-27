function muppet_addSubplotText(fig,ifig,isub,leftaxis)

plt=fig.subplots(isub).subplot;

switch lower(plt.type)
    case{'map'}
        xmin=plt.xmin;
        dstx=plt.subplottext.horizontalmargin*(plt.xmax-plt.xmin)/plt.position(3);
        if strcmpi(plt.coordinatesystem.type,'geographic')
            fac=cos(plt.ymax*pi/180);
        else
            fac=1;
        end
        dsty=plt.subplottext.verticalmargin*fac*(plt.ymax-plt.ymin)/plt.position(4);
        switch lower(plt.subplottext.position)
            case {'lower-left'}
                xpos=plt.xmin+dstx;
                ypos=plt.ymin+dsty;
                horal='left';
            case {'lower-right'}
                xpos=plt.xmax-dstx;
                ypos=plt.ymin+dsty;
                horal='right';
            case {'upper-left'}
                xpos=plt.xmin+dstx;
                ypos=plt.ymax-dsty;
                horal='left';
            case {'upper-right'}
                xpos=plt.xmax-dstx;
                ypos=plt.ymax-dsty;
                horal='right';
        end
        if strcmpi(plt.coordinatesystem.type,'geographic')
            switch plt.projection
                case{'mercator'}
                    ypos=merc(ypos);
                case{'albers'}
                    [xpos,ypos]=albers(xpos,ypos,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
            end
        end
    case{'xy'}
        xmin=plt.xmin;
        dstx=plt.subplottext.horizontalmargin*(plt.xmax-plt.xmin)/plt.position(3);
        dsty=plt.subplottext.verticalmargin*(plt.ymax-plt.ymin)/plt.position(4);
        switch lower(plt.subplottext.position)
            case {'lower-left'}
                xpos=plt.xmin+dstx;
                ypos=plt.ymin+dsty;
                horal='left';
            case {'lower-right'}
                xpos=plt.xmax-dstx;
                ypos=plt.ymin+dsty;
                horal='right';
            case {'upper-left'}
                xpos=plt.xmin+dstx;
                ypos=plt.ymax-dsty;
                horal='left';
            case {'upper-right'}
                xpos=plt.xmax-dstx;
                ypos=plt.ymax-dsty;
                horal='right';
        end
    case{'timeseries','timestack'}
        xmin = datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
        xmax = datenum(plt.yearmax,plt.monthmax,plt.daymax,plt.hourmax,plt.minutemax,plt.secondmax);        
        dstx=plt.subplottext.horizontalmargin*(xmax-xmin)/plt.position(3);
        dsty=plt.subplottext.verticalmargin*(plt.ymax-plt.ymin)/plt.position(4);
        switch lower(plt.subplottext.position)
            case {'lower-left'}
                xpos=xmin+dstx;
                ypos=plt.ymin+dsty;
                horal='left';
            case {'lower-right'}
                xpos=xmax-dstx;
                ypos=plt.ymin+dsty;
                horal='right';
            case {'upper-left'}
                xpos=xmin+dstx;
                ypos=plt.ymax-dsty;
                horal='left';
            case {'upper-right'}
                xpos=xmax-dstx;
                ypos=plt.ymax-dsty;
                horal='right';
        end
end

%axes(leftaxis);

if strcmpi(fig.renderer,'opengl')
%     xback=plt.xmin;
%     xmin=plt.xmin-xback;
%     xmax=plt.xmax-xback;
%    x=x-xback;
%xpos=xpos-xmin;
% else
%     xback=0;
end


tx=text(xpos,ypos,plt.subplottext.string);
set(tx,'HorizontalAlignment',horal);
set(tx,'FontName',plt.subplottext.font.name);
set(tx,'FontSize',plt.subplottext.font.size*fig.fontreduction);
set(tx,'FontWeight',plt.subplottext.font.weight);
set(tx,'FontAngle',plt.subplottext.font.angle);
set(tx,'Color',colorlist('getrgb','color',plt.subplottext.font.color));
set(tx,'HitTest','off');
