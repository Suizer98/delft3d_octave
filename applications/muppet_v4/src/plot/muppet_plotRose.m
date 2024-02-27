function h=muppet_plotRose(handles,i,j,k)
 
h=[];

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;
% opt.skipfirstcolumn=0;

dirs=data.x(:,1);
%upperlimits=data.y(1,:);
dat=data.z;
sumsmall=sum(data.z(:,1));

cstep=opt.radiusstep;
cmax=opt.maxradius;
str=cstep:cstep:cmax;
nrad=size(str,2);
sm=sum(dat,2);
linewidths=[1 2 4 7 12 18 24 30 36 42 48 54 60 66 72];
if opt.coloredrose
    colors={'k','b','r','g','m','c','y','k','b','r','g','m','c','y'};
else
    colors={'k','k','k','k','k','k','k','k','k','k','k','k','k','k'};
end
sz=size(dat);
nocon=sz(2);
nodir=sz(1);
cirdir=0:0.01:(2*pi);

%% Plot dotted grid
if opt.firstcolumncalm
    r0=0.1;
else
    r0=0;
end
radii=(r0+str/cmax)/(1+r0);
for ii=1:nrad
    cirx=radii(ii)*cos(cirdir);
    ciry=radii(ii)*sin(cirdir);
    p=plot(cirx,ciry,'k:');hold on;
end
for ii=1:16
    p=plot( [r0*cos(ii*pi/8) cos(ii*pi/8)] , [r0*sin(ii*pi/8) sin(ii*pi/8)] ,'k:');
end
for ii=1:nrad
    txx=radii(ii)*cos(pi*(7/16));
    txy=radii(ii)*sin(pi*(7/16));
    tx=text(txx,txy,[num2str(str(ii)) '%']);
    set(tx,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(tx,'FontSize',5);
end

%% And now the data
for ii=1:nodir
    if opt.firstcolumncalm
        xx(ii,1,1)=r0;
        xx(ii,1,2)=r0;
    else
        xx(ii,1,1)=0;
        xx(ii,1,2)=max(dat(ii,1),0.0)/cmax;
    end
    for jj=2:nocon
        xx(ii,jj,1)=xx(ii,jj-1,2);
        xx(ii,jj,2)=xx(ii,jj,1)+max(dat(ii,jj),0.0)/(cmax+r0);
    end
end

for ii=1:nodir
    for jj=1:nocon
        x(1)=xx(ii,jj,1)*cos(pi*(90-dirs(ii))/180);
        y(1)=xx(ii,jj,1)*sin(pi*(90-dirs(ii))/180);
        x(2)=xx(ii,jj,2)*cos(pi*(90-dirs(ii))/180);
        y(2)=xx(ii,jj,2)*sin(pi*(90-dirs(ii))/180);
        p=plot(x,y,colors{jj});hold on;
        set(p,'LineWidth',linewidths(jj));
    end
    if opt.addrosetotals
        if sm(ii)>0
            txx=(xx(ii,end,2)+0.05)*cos(pi*(90-dirs(ii))/180);
            txy=(xx(ii,end,2)+0.05)*sin(pi*(90-dirs(ii))/180);
            tx=text(txx,txy,[num2str(sm(ii),'%4.1f') '%']); 
            set(tx,'HorizontalAlignment','center','VerticalAlignment','middle');
            set(tx,'FontSize',6);
        end
    end
end

if opt.firstcolumncalm
    % Add circle in middle of rose with percentage calm conditions
    xp=0.1*cos(cirdir);
    yp=0.1*sin(cirdir);
    plot(xp,yp,'k');
    tx=text(0,0,[num2str(sumsmall,'%3.1f') '%']);
    set(tx,'HorizontalAlignment','center');
    set(tx,'FontSize',8);
end
    

% Legend
if opt.addroselegend
    nr=size(dat,2);
    x(1)=1.2;
    x(2)=x(1);
    y(1)=-1.0;
    for ii=1:nr
        y(2)=y(1)+2*(1/nr);
        pltleg=plot(x,y,colors{ii});hold on;
        set(pltleg,'LineWidth',linewidths(ii),'Clipping','off');
        txleg=text(1.2+linewidths(nocon)/150,(y(2)+y(1))/2,data.class{ii});
        set(txleg,'HorizontalAlignment','left','VerticalAlignment','middle');
        set(txleg,'FontSize',7);
        y(1)=y(2);
    end
end
