function h=muppet_plotLint(handles,i,j,k)

h=[];

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;
 
yarr(1)=0.50;  xarr(1)=-5;
yarr(2)=0.50;  xarr(2)=2;
yarr(3)=1.5;   xarr(3)=2;
yarr(4)=0;     xarr(4)=5;
yarr(5)=-1.5;  xarr(5)=2;
yarr(6)=-0.50; xarr(6)=2;
yarr(7)=-0.50; xarr(7)=-5;
yarr(8)=0.50 ; xarr(8)=-5;
 
[x,y]=landboundary('read',data.polygonfile);
trcum0=data.z;
trcum=trcum0;
 
polno=1;
jj=1;
for ii=1:size(x,1)
    if (isnan(x(ii)))
        polno=polno+1;
        jj=1;
    else
        pol(polno).x(jj)=x(ii);
        pol(polno).y(jj)=y(ii);
        pol(polno).z(jj)=500;
        jj=jj+1;
    end
end
 
for ii=1:polno;

    xxx=pol(ii).x;
    yyy=pol(ii).y;

    alfa0 = atan2((yyy(end)-yyy(1)),(xxx(end)-xxx(1)));
    if (trcum(ii)>=0)
        alfa(ii)=alfa0+pi/2;
    else
        alfa(ii)=alfa0-pi/2;
    end
    
    % Determine where the arrow must be plotted
    pd=pathdistance(xxx,yyy);
    ifirst=find(pd>=pd(end)/2,1,'first')-1;    
    ifrac=(pd(end)/2-pd(ifirst))/(pd(ifirst+1)-pd(ifirst));
    xcen=xxx(ifirst)+ifrac*(xxx(ifirst+1)-xxx(ifirst));
    ycen=yyy(ifirst)+ifrac*(yyy(ifirst+1)-yyy(ifirst));
    
    if opt.unitarrow==0    
        logval=log10(abs(max(trcum)));
    else
        logval=log10(abs(opt.unitarrow));
    end        
    minval=logval-3;
    scaling(ii)=opt.lintscale*plt.scale*max(log10(abs(trcum(ii)))-minval,0);
    scaling(ii)=scaling(ii)*0.005;

    % Create arrows
    for jj=1:8;
        dist=scaling(ii)*0.1*sqrt(xarr(jj)^2+yarr(jj)^2);
        ang0=atan2(yarr(jj),xarr(jj));
        ang1=ang0+alfa(ii);
        arr{ii}(jj,1)=dist*cos(ang1)+xcen;
        arr{ii}(jj,2)=dist*sin(ang1)+ycen;
        arr{ii}(jj,3)=3000+ii*10;
    end
    
    % Create text
    dist=0.002*plt.scale;
    if (cos(alfa(ii))>=0)
        ang0=atan2(1.2,-0.5);ang1=ang0+alfa(ii);
        txx(ii)=dist*cos(ang1)+xcen;
        txy(ii)=dist*sin(ang1)+ycen;
        txz(ii)=3000;
        txtang(ii)=180*alfa(ii)/pi;
    else
        ang0=atan2(-1.2,-0.5);ang1=ang0+alfa(ii);
        txx(ii)=dist*cos(ang1)+xcen;
        txy(ii)=dist*sin(ang1)+ycen;
        txtang(ii)=180*alfa(ii)/pi-180;
        txz(ii)=3000+ii*10;
    end
end
 
for ii=1:polno;
    if scaling(ii)>0

        % Plot arrows
        if opt.fillclosedpolygons
            fl=fill3(arr{ii}(:,1),arr{ii}(:,2),arr{ii}(:,3),'r');hold on;
            set(fl,'FaceColor',colorlist('getrgb','color',opt.fillcolor),'LineStyle','none');
        end
        lin=line(arr{ii}(:,1),arr{ii}(:,2),arr{ii}(:,3));hold on;
        set(lin,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));hold on;

        % Plot text
        if opt.addtext
            frmt=['%0.' num2str(opt.decimals) 'f'];
            tx=num2str(abs(trcum(ii))*opt.multiply,frmt);
            txt=text(txx(ii),txy(ii),txz(ii),tx);
            set(txt,'Rotation',txtang(ii),'HorizontalAlignment','center','Clipping','on');
            set(txt,'VerticalAlignment','baseline');
            set(txt,'FontName',opt.font.name);
            set(txt,'FontWeight',opt.font.weight);
            set(txt,'FontAngle',opt.font.angle);
            set(txt,'FontSize',opt.font.size);
            set(txt,'Color',colorlist('getrgb','color',opt.font.color));

        end
    end
end
