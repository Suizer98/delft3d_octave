function leg=SetLegend(handles,i,j)

leg=[];

h=findobj(gcf,'Tag','legend','UserData',[i,j]);
delete(h);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot;

kk=0;
hnd(1)=0;
for k=1:Ax.Nr
    if length(Plt(k).LegendText)>0 & length(Plt(k).Handle)>0
        kk=kk+1;
        txt{kk}=Plt(k).LegendText;
        hnd(kk)=Plt(k).Handle;
    end
end

if sum(hnd)>0
    leg=legend(hnd,txt);
    if Ax.LegendBorder==0
        if Fig.cm2pix==1
            legend boxoff;
        else
            set(leg,'Color','none');
            set(leg,'XColor',[0.8 0.8 0.8]);
            set(leg,'YColor',[0.8 0.8 0.8]);
        end            
    else
        set(leg,'Color',FindColor(Ax.LegendColor));
    end
    set(leg,'Unit',Fig.Units);
    set(leg,'Orientation',Ax.LegendOrientation);
    set(leg,'FontName',Ax.LegendFont);
    set(leg,'FontSize',Ax.LegendFontSize*Fig.FontRed);
    set(leg,'FontWeight',Ax.LegendFontWeight);
    set(leg,'FontAngle',Ax.LegendFontAngle);
    set(leg,'TextColor',FindColor(Ax.LegendFontColor));
    if ischar(Ax.LegendPosition)
        set(leg,'Location',Ax.LegendPosition);
    else
        pos=Ax.LegendPosition;
        pos(3)=max(pos(3),0.2);
        pos(4)=max(pos(4),0.2);
        set(leg,'Position',pos*Fig.cm2pix);
    end        
    set(leg,'Tag','legend');
    set(findall(leg,'type','text'),'HitTest','off');
    LegendData.i=i;
    LegendData.j=j;
    setappdata(leg,'LegendData',LegendData);
    set(leg,'ButtonDownFcn',{@SelectLegend});
end

