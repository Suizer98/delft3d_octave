function cosmos_ripCurrentTimeSeries(fname,rips,ir,wl,warningLevels)

warningLevel=rips(ir).warningLevel;
t=rips(ir).t;
v=rips(ir).vmax;
dt=t(2)-t(1);
pps=[16 11];

h=figure('Visible','off');

set(h,'Units','centimeters');
set(h,'PaperUnits','centimeters');
set(h,'PaperSize',pps);
set(h,'PaperPositionMode','manual');
set(h,'PaperPosition',[0 0 pps]);
set(h,'renderer','painters')

s3 = axes; hold on; box on
set(s3,'Units','centimeters');
yl=[-2 2];

% wlp=plot(wl.Time,wl.Val,'k');
% vp=plot(t,v,'b');

[ax,wlp,vp]=plotyy(wl.Time,wl.Val,t,v);

p1=patch([0 0 0 0],[-10 -10 10 10],[-100 -100 -100 -100],[1 1 0],'edgecolor','none');
p2=patch([0 0 0 0],[-10 -10 10 10],[-100 -100 -100 -100],[1 0.5 0],'edgecolor','none');
p3=patch([0 0 0 0],[-10 -10 10 10],[-100 -100 -100 -100],[1 0 0],'edgecolor','none');

for i=1:length(warningLevel)
    if warningLevel(i)>0
        plocx=[t(i)-0.5*dt t(i)+0.5*dt t(i)+0.5*dt t(i)-0.5*dt];
        plocy=[-10 -10 10 10];
        switch warningLevel(i)
            case 1
                c=[1 1 0];
            case 2
                c=[1 0.5 0];
            case 3
                c=[1 0 0];
        end
        patch(plocx,plocy,c,'edgecolor','none');
    end
end

set(s3,'xlim',[t(1) t(end)]);
set(s3,'XTick',t(1):0.125:t(end));

xtck=get(s3,'XTick');
for it=1:length(xtck)
    xtcklab{it}=datestr(xtck(it),'HH');
end
set(s3,'XTickLabel',xtcklab);

for it=1:length(xtck)
    if abs(xtck(it)-round(xtck(it)))<1/86400
        txt=datestr(xtck(it),'yyyy/mm/dd');
        xtx=xtck(it);
        ytx=yl(1)-0.3*(yl(2)-yl(1));
        tx=text(xtx,ytx,txt);
        set(tx,'HorizontalAlignment','center');
    end
end
set(s3,'layer','top'); grid on;
set(s3,'YLim',yl);
ylabel('Water level (m)');

l1=legend([wlp vp p1 p2 p3],'Water level','Current velocity','Moderate','Strong','Very strong','Orientation','vertical');
%set(l1,'Position',[x3+wdt3+0.2 y3+hgt3-1.5 1 1.5]);
set(l1,'Box','off');

% set(s3,'Position',pos3);
% set(clrbar,'Position',posc);
%set(ylh,'String','Seaward current (m/s)','Position',[-3.7 0.5 1]);

print(h,'-dpng','-r100',fname);

close(h);
