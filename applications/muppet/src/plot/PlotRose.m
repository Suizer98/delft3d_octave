function handles=PlotRose(handles,i,j,k,mode)
 
DeleteObject(i,j,k);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
dirs=Data.x(:,1);
upperlimits=Data.y(1,:);
dat=Data.z;
cstep=Plt.RadiusStep;
cmax=Plt.MaxRadius;
str=cstep:cstep:cmax;
nrad=size(str,2);
sm=sum(dat,2);
linewidths=[1 2 4 7 12 18 27 40 48 52 56 60 64 68 72];
if Plt.ColoredWindRose
    colors={'k','b','r','g','y','c','m','k','b','r','g','y','c','m'};
else
    colors={'k','k','k','k','k','k','k','k','k','k','k','k','k','k'};
end
sz=size(dat);
nocon=sz(2);
nodir=sz(1);
cirdir=0:0.01:(2*pi);

for ii=1:nrad
    cirx=str(ii)/cmax*cos(cirdir);
    ciry=str(ii)/cmax*sin(cirdir);
    p=plot(cirx,ciry,'k:');hold on;
    SetObjectData(p,i,j,k,'windrose');
end
for ii=1:8
    p=plot( [-cos(ii*pi/8) cos(ii*pi/8)] , [-sin(ii*pi/8) sin(ii*pi/8)] ,'k:');
    SetObjectData(p,i,j,k,'windrose');
end

for ii=1:nodir
    x(1)=0;
    y(1)=0;
    dist=0;
    for jj=1:nocon
        x(2)=x(1)+max(dat(ii,jj),0.0)/cmax*cos(pi*(90-dirs(ii))/180);
        y(2)=y(1)+max(dat(ii,jj),0.0)/cmax*sin(pi*(90-dirs(ii))/180);
        p=plot(x,y,colors{jj});hold on;
        set(p,'LineWidth',linewidths(jj));
        SetObjectData(p,i,j,k,'windrose');
        x(1)=x(2);
        y(1)=y(2);
    end
    if Plt.AddWindRoseTotals
        if sm(ii)>0
            txx=(sm(ii)+1.8*str(nrad)/16.0)/cmax*cos(pi*(90-dirs(ii))/180);
            txy=(sm(ii)+1.8*str(nrad)/16.0)/cmax*sin(pi*(90-dirs(ii))/180);
            tx2=text(txx,txy,[num2str(sm(ii),'%4.1f') '%']); 
            set(tx2,'HorizontalAlignment','center','VerticalAlignment','middle');
            set(tx2,'FontSize',[6]);
            SetObjectData(tx2,i,j,k,'windrose');
        end
    end
end

for ii=1:nrad
    txx=str(ii)/cmax*cos(pi*(7/16));
    txy=str(ii)/cmax*sin(pi*(7/16));
    tx=text(txx,txy,[num2str(str(ii)) '%']);
    set(tx,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(tx,'FontSize',[5]);
    SetObjectData(tx,i,j,k,'windrose');
end

% Legend
if Plt.AddWindRoseLegend
    nr=size(dat,2);
    x(1)=1.2;
    x(2)=x(1);
    y(1)=-1.0;
    for ii=1:nr
        y(2)=y(1)+2*(1/nr);
        pltleg=plot(x,y,colors{ii});hold on;
        set(pltleg,'LineWidth',linewidths(ii),'Clipping','off');
        SetObjectData(pltleg,i,j,k,'windrose');
        txleg=text(1.2+linewidths(nocon)/150,(y(2)+y(1))/2,Data.Class{ii});
        set(txleg,'HorizontalAlignment','left','VerticalAlignment','middle');
        set(txleg,'FontSize',[7]);
        SetObjectData(txleg,i,j,k,'windrose');
        y(1)=y(2);
    end
end
