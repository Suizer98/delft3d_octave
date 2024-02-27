function vecleg=muppet_setVectorLegend(fig,ifig,isub)

h=findobj(gcf,'Tag','vectorlegend','UserData',[ifig,isub]);
delete(h);

plt=fig.subplots(isub).subplot;

nodat=plt.nrdatasets;

vecleg=[];

k=0;
for id=1:nodat
    data=plt.datasets(id).dataset;
    if isfield(data,'vectorlegendtext')
        if ~isempty(data.vectorlegendtext)
            k=k+1;
            idat(k)=id;
            txt{k}=data.vectorlegendtext;
            if strcmpi(data.plotroutine,'curved arrows') || strcmpi(data.plotroutine,'colored curved arrows')
                length(k)=data.vectorlegendlength*data.curveclength/plt.scale;
            else
                length(k)=data.vectorlegendlength*data.unitvector/plt.scale;
            end
            col{k}=colorlist('getrgb','color',data.vectorcolor);
        end
    end
end

if k>0

    maxlength=max(length);

    vecleg=axes;

    for i=1:k
        ii=idat(i);
        data=plt.datasets(ii).dataset;
        if strcmpi(data.plotroutine,'curved arrows') || strcmpi(data.plotroutine,'colored curved arrows')
            hdthck=data.headthickness;
            arthck=data.arrowthickness;
            y=0.01*(0.4*k-0.4*i);
            x2=0.0005+length(i)*[0 15 15 20 15 15 0]/20;
            y2=y+2*length(i)*[arthck arthck hdthck 0 -hdthck -arthck -arthck]/2;
            fl=patch(x2,y2,'k');hold on;
            set(fl,'EdgeColor',colorlist('getrgb','color',data.edgecolor));
            set(fl,'FaceColor',colorlist('getrgb','color',data.facecolor));
        else
            x=0.0;
            y=0.01*(0.4*k-0.4*i);
            z=10000;
            u=length(i);
            v=0;
            w=0;
            qv(i)=quiver3(x,y,z,u,v,w,0,'color',col{i});hold on;
            set(qv(i),'MaxHeadSize',0.8);
            set(qv(i),'AutoScaleFactor',1.0);
        end
        legtxt(i)=text(maxlength+0.003,y,txt{i});
        set(legtxt(i),'FontName',plt.vectorlegend.font.name);
        set(legtxt(i),'FontSize',plt.vectorlegend.font.size*fig.fontreduction);
        set(legtxt(i),'FontWeight',plt.vectorlegend.font.weight);
        set(legtxt(i),'FontAngle',plt.vectorlegend.font.angle);
        set(legtxt(i),'Color',colorlist('getrgb','color',plt.vectorlegend.font.color));
    end

    tick(vecleg,'x','none');
    tick(vecleg,'y','none');
    set(vecleg,'color','none');
    set(vecleg,'xlim',[0 0.04],'ylim',[-0.005 0.01*k-0.005]);

    pos=plt.vectorlegend.position;
    pos(3)=4;
    pos(4)=k;
    
    set(vecleg,'Units',fig.units);
    set(vecleg,'Position',pos*fig.cm2pix);
    
    if fig.cm2pix==1
        box off;
        axis off;
    else
        set(vecleg,'XColor',[0.8 0.8 0.8]);
        set(vecleg,'YColor',[0.8 0.8 0.8]);
        box on;
    end
    
    view(2);

    c=get(vecleg,'Children');
    ff=findall(c,'HitTest','on');
    set(ff,'HitTest','off');

    set(vecleg,'Tag','vectorlegend','UserData',[ifig,isub]);

end

