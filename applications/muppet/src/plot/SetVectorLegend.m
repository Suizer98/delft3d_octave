function VecLeg=SetVectorLegend(handles,i,j)

h=findobj(gcf,'Tag','vectorlegend','UserData',[i,j]);
delete(h);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=Ax.Plot;
nodat=Ax.Nr;

VecLeg=0;

k=0;
for i=1:nodat
    if isfield(Plt(i),'VectorLegendText')
        if size(Plt(i).VectorLegendText,2)>0
            k=k+1;
            idat(k)=i;
            txt{k}=Plt(i).VectorLegendText;
            if strcmpi(Plt(i).PlotRoutine,'plotcurvedarrows') || strcmpi(Plt(i).PlotRoutine,'plotcoloredcurvedarrows')
                length(k)=Plt(i).VectorLegendLength*Plt(i).DtCurVec/Ax.Scale;
            else
                length(k)=Plt(i).VectorLegendLength*Plt(i).UnitVector/Ax.Scale;
            end
            col{k}=FindColor(Plt(i).VectorColor);
        end
    end
end

if k>0

    maxlength=max(length);

    VecLeg=axes;

    for i=1:k
        ii=idat(i);
        if strcmpi(Plt(ii).PlotRoutine,'plotcurvedarrows') || strcmpi(Plt(ii).PlotRoutine,'plotcoloredcurvedarrows')
            hdthck=Plt(ii).HeadThickness;
            arthck=Plt(ii).ArrowThickness;
            y=0.01*(0.4*k-0.4*i);
            x2=0.0005+length(i)*[0 15 15 20 15 15 0]/20;
            y2=y+2*length(i)*[arthck arthck hdthck 0 -hdthck -arthck -arthck]/25;
            z2=zeros(size(x2));
            fl=patch(x2,y2,z2,'k');hold on;
            set(fl,'EdgeColor',FindColor(Plt(ii).LineColor));
            set(fl,'FaceColor',FindColor(Plt(ii).FillColor));
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
        set(legtxt(i),'FontName',Ax.VectorLegendFont);
        set(legtxt(i),'FontSize',Ax.VectorLegendFontSize*Fig.FontRed);
        set(legtxt(i),'FontWeight',Ax.VectorLegendFontWeight);
        set(legtxt(i),'FontAngle',Ax.VectorLegendFontAngle);
        set(legtxt(i),'Color',FindColor(Ax.VectorLegendFontColor));
    end

    tick(VecLeg,'x','none');
    tick(VecLeg,'y','none');
    set(VecLeg,'color','none');
    set(VecLeg,'xlim',[0 0.04],'ylim',[-0.005 0.01*k-0.005]);

    pos=Ax.VectorLegendPosition;
    pos(3)=4;
    pos(4)=k;
    
    set(VecLeg,'Units',Fig.Units);
    set(VecLeg,'Position',pos*Fig.cm2pix);
    
    if Fig.cm2pix==1
        box off;
        axis off;
    else
        set(VecLeg,'XColor',[0.8 0.8 0.8]);
        set(VecLeg,'YColor',[0.8 0.8 0.8]);
        box on;
    end
    
    view(2);

    c=get(VecLeg,'Children');
    ff=findall(c,'HitTest','on');
    set(ff,'HitTest','off');

    set(VecLeg,'Tag','vectorlegend','UserData',[i,j]);
    set(VecLeg,'ButtonDownFcn',{@SelectVectorLegend});

end

