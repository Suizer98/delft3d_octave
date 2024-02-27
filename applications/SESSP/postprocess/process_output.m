clear variables;close all;

s=load('shorelinepoints.txt');
nstat=size(s,1);
x=s(:,1);
y=s(:,2);


pd=pathdistance(x,y,'geographic')/1000;

p(1).name='grand_isle';
p(1).x=-90.09;
p(1).y= 29.26;

p(2).name='pilot_station_east';
p(2).x=-89.41;
p(2).y= 28.92;

p(3).name='port_sulphur';
p(3).x=-89.64;
p(3).y= 29.50;

p(4).name='waveland';
p(4).x=-89.36;
p(4).y= 30.28;

p(5).name='gulfport';
p(5).x=-89.08;
p(5).y= 30.36;

p(6).name='pascagoula';
p(6).x=-88.56;
p(6).y= 30.31;

for ip=1:length(p)
    
    dst=sqrt((x-p(ip).x).^2+(y-p(ip).y).^2);
    imin=find(dst==min(dst),1,'first');
    fd3d=['e:\work\empirical_surge_formula\scripts\test_ike\katrina\d3d\' num2str(imin,'%0.4i') '.tek'];
    [td3d,vd3d]=readtekaltimeseries(fd3d);
    fsessp=['e:\work\empirical_surge_formula\scripts\test_ike\katrina\sessp\' num2str(imin,'%0.4i') '.tek'];
    [tsessp,vsessp]=readtekaltimeseries(fsessp);
    
    figure(ip)
    plot(td3d,vd3d,'b');
    hold on
    plot(tsessp,vsessp,'r');
    datetick('x');
    title(p(ip).name);
    
    p(ip).xx=pd(imin);
    
end

info = tekal('open','e:\work\empirical_surge_formula\scripts\test_ike\katrina\d3d\zmax.tek');
zmax_d3d = tekal('read',info,1);
info = tekal('open','e:\work\empirical_surge_formula\scripts\test_ike\katrina\sessp\zmax.tek');
zmax_sessp = tekal('read',info,1);

figure(100)
plot(zmax_d3d(:,1),zmax_d3d(:,2),'b');
hold on
plot(zmax_sessp(:,1),zmax_sessp(:,2),'r');
for ip=1:length(p)
    plot([p(ip).xx p(ip).xx],[0 10],'k');
end
zmxx=max(max(zmax_d3d(:,2)),max(zmax_sessp(:,2)));
set(gca,'xlim',[1000 1700],'ylim',[0 ceil(zmxx)+1]);
