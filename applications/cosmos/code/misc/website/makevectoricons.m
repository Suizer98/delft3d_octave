function makevectors

xx0=[-1 1 0.6 1 0.6];
yy0=[0 0 -0.4 0 0.4];
xx0=xx0*10;
yy0=yy0*10;
ang0=atan2(yy0,xx0);
psize=20;
dst0=sqrt(xx0.^2+yy0.^2);

rgb=makeColorMap(jet,10);

for jj=1:10
for ii=0:10:350
    close all;
    ang=ang0+ii*pi/180;
    
    % xx=xx0.*cos(ang);
    % yy=yy0.*sin(ang);
    
    % Compute velocity magnitude and angle of each vector
    vel=1;
    
    % Multiply unit vector with velocity magnitude
    %dst0=vel*dst0;
    
    % Rotate vector with velocity angle
    %ang=repmat(ang,5);
    %ang=ang+repmat(ang0,1);
    xx=dst0.*cos(ang);
    yy=dst0.*sin(ang);
    
    figure;
    set(gcf,'Units','pixels');
    set(gcf,'PaperUnits','points');
    set(gcf,'PaperPosition',[1 1 psize psize]);
    set(gcf,'PaperSize',[psize psize]);
    set(gcf,'Position',[1 1 psize psize]);
    ax=axes;
    set(ax,'Units','pixels');
    set(ax,'xlim',[-10 10],'ylim',[-10 10]);
    set(ax,'position',[1 1 psize psize]);
    p=plot(xx,yy);
    set(p,'color',rgb(jj,:));
    set(ax,'xlim',[-10 10],'ylim',[-10 10]);
    set(ax,'Box','off');
    set(ax,'xtick',[]);
    set(ax,'ytick',[]);
    print('-dpng','-r50','test.png');
    a = imread('test.png');
    wt=sum(a,3)==3*255;
    r=squeeze(a(:,:,1));
    g=squeeze(a(:,:,2));
    b=squeeze(a(:,:,3));
    r(wt)=NaN;
    g(wt)=NaN;
    b(wt)=NaN;
    c(:,:,1)=r;
    c(:,:,2)=g;
    c(:,:,3)=b;
    trans=zeros(size(wt))+1;
    trans(wt)=0;
    imwrite(c,['c:\xampp\htdocs\img\arrows\arrow.' num2str(jj,'%0.2i') '.' num2str(ii,'%0.3i') '.png'],'alpha',trans);
    
end
end

%%
function rgb=makeColorMap(clmap,n)

if size(clmap,2)==4
    x=clmap(:,1);
    r=clmap(:,2);
    g=clmap(:,3);
    b=clmap(:,4);
else
    x=0:1/(size(clmap,1)-1):1;
    r=clmap(:,1);
    g=clmap(:,2);
    b=clmap(:,3);
end

for i=2:size(x,1)
    x(i)=max(x(i),x(i-1)+1.0e-6);
end

x1=0:(1/(n-1)):1;

r1=interp1(x,r,x1);
g1=interp1(x,g,x1);
b1=interp1(x,b,x1);

rgb(:,1)=r1;
rgb(:,2)=g1;
rgb(:,3)=b1;

rgb=max(0,rgb);
rgb=min(1,rgb);
