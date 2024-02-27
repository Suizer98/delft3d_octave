function ripCurrentTimestack(figname,t,ycrs,vcrsmax,wl,rips,warningLevel,warningLevels,ref,jpgfile,jgwfile)

[xc,yc,rc]=rotateGeoImage(jpgfile,jgwfile,ref.x0,ref.y0,ref.width1,ref.width2,ref.length1,ref.length2,ref.orientation-90);

dt=t(2)-t(1);

pps=[16 11];

hgt=6;
hgtb=2;
wdt=12;

% Plot sizes
hgt1=hgt;
wdt1=hgt1*(ref.width1+ref.width2)/(ref.length1+ref.length2);
hgt2=hgt;
wdt2=wdt-wdt1;
hgt3=2.5;
wdt3=wdt2;
% Plot positions
x1=1.5;
y1=2+hgtb;
x2=1.5+wdt1;
y2=y1;
x3=x2;
y3=1;
pos1=[x1 y1 wdt1 hgt1];
pos2=[x2 y2 wdt2 hgt2];
pos3=[x3 y3 wdt3 hgt3];
posc=[x2+wdt2+0.8 y2 0.5 6];

h=figure('Visible','off');

set(h,'Units','centimeters');
set(h,'PaperUnits','centimeters');
set(h,'PaperSize',pps);
set(h,'PaperPositionMode','manual');
set(h,'PaperPosition',[0 0 pps]);
set(h,'renderer','painters')

%% Geo Image
s1 = axes; hold on; box on
set(s1,'Units','centimeters');

image(xc,yc,rc);

% Add markers for rips
for i=1:length(rips)
    xr0(i)=rips(i).x;
    yr0(i)=rips(i).y;
end
xr0=xr0-ref.x0;
yr0=yr0-ref.y0;
rot=(90-ref.orientation)*pi/180;
xr =  xr0 .*  cos(rot) + yr0 .* -sin(rot);
yr =  xr0 .*  sin(rot) + yr0 .* cos(rot);
for i=1:length(rips)
    switch rips(i).warningLevel
        case 1
            c=[1 1 0];
        case 2
            c=[1 0.5 0];
        case 3
            c=[1 0 0];
    end
    plt=plot(xr(i),yr(i),'o');
    set(plt,'MarkerFaceColor',c,'MarkerEdgeColor','k');
end

set(s1,'YDir','normal');
set(s1,'xlim',[-ref.width1 ref.width2]);
set(s1,'ylim',[ycrs(1) ycrs(end)])
set(s1,'layer','top'); grid on;
set(s1,'xticklabel',{' '});
ylabel('Distance along shore (m)');


%% Time Stack
s2 = axes;
hold on;box on
set(s2,'Units','centimeters');

title('Time-stack rip currents');
pcolor(t-0.5*dt,ycrs,vcrsmax);shading flat;
clim([0 1]);
set(s2,'xticklabel',{' '});
set(s2,'layer','top'); grid on;
set(s2,'xlim',[t(1) t(end)]);
set(s2,'xtick',t(1):0.125:t(end));

set(s2,'ylim',[ycrs(1) ycrs(end)]);
set(s2,'yticklabel',{' '});

clrbar=colorbar;
set(clrbar,'Units','centimeters');

clr=zeros(100,3)+1;
for i=1:length(warningLevels)
    n1=floor(warningLevels(i)*100)+1;
    n2=100;
    switch i
        case 1
            c=[1 1 0];
        case 2
            c=[1 0.5 0];
        case 3
            c=[1 0 0];
    end
    for j=n1:n2
        clr(j,:)=c;
    end
end

%col = colormap('hot');
%colormap(flipud(col));
colormap(clr);
set(s2,'XTickLabel',[]);

%% WL time series
s3 = axes; hold on; box on
set(s3,'Units','centimeters');
yl=[-2 2];

plot(wl.Time,wl.Val,'k');

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

l1=legend([p1 p2 p3],'Moderate','Strong','Very strong','Orientation','vertical');
set(l1,'Position',[x3+wdt3+0.2 y3+hgt3-1.5 1 1.5]);
set(l1,'Box','off');

set(s1,'Position',pos1);
set(s2,'Position',pos2);
set(s3,'Position',pos3);
set(clrbar,'Position',posc);
ylh=get(clrbar,'ylabel');
set(clrbar,'ytick',[0 warningLevels 1]);
set(ylh,'String','Seaward current (m/s)','Position',[-3.7 0.5 1]);

print(h,'-dpng','-r100',figname);

close(h);
