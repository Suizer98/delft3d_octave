clear variables;close all;

x=-500000:10000:500000;
y=zeros(size(x));

phic=0.5*pi;
w=100000;
ad=0.03;

xx=0:10:w;
zz=-ad*xx.^(2/3);
maxdepth=100;
xoff=-100;
% iid=compute_iid(xx,zz,-100,xoff);
iid=10000;

fid=fopen('shorelinepoints.txt','wt');
for ip=1:length(x)
    fprintf(fid,'%12.1f %12.1f %12.4f %12.1f %12.4f %12.1f\n',x(ip),y(ip),phic,w,ad,iid);
end
fclose(fid);

coastfile='shorelinepoints.txt';
trackfile='test.cyc';
outputfolder='test01\';
t0=datenum(2014,1,31);
t1=datenum(2014,2,02,6,0,0);
dt=10;
latitude=30;
windspeedconversionfactor=1;

[t,xx,lon,lat,stot,snor,spar,srad,sekm,sibe]=sessp_simulate_track(coastfile,trackfile,outputfolder,t0,t1,dt,'latitude',30,'include_tide',0,'cstype','projected','writeoutput',0,'phi_spiral',20,'windspeedconversionfactor',windspeedconversionfactor);

stotmax=max(stot,[],1);
plot(x,stotmax);

ix=find(x>30000,1,'first');
% ix=find(x>=0,1,'first');
figure(2)
plot(squeeze(stot(:,ix)));


figure(3)
plot(squeeze(snor(:,ix)));
figure(4)
plot(squeeze(spar(:,ix)));
figure(5)
plot(squeeze(srad(:,ix)));
figure(6)
plot(squeeze(sekm(:,ix)));
figure(7)
plot(squeeze(sibe(:,ix)));

tt=t0:dt/1440:t1;
tt=86400*(tt-datenum(2014,2,1)); % convert to seconds wrt landfall
s.x=x;
s.y=y;
s.time=tt;
for ix=1:length(x)
    s.data(ix,1).water_level_without_waves=stot(:,ix);
end
save('results_sessp_mild_slope.mat','-struct','s');
