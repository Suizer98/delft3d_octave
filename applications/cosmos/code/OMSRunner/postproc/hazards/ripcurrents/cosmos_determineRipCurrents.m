function hm=cosmos_determineRipCurrents(hm,m,ih)

model=hm.models(m);

hazard=model.hazards(ih);

maparchdir=model.cycledirmaps;
hisarchdir=model.cycledirtimeseries;
hazarchdir=model.cycledirhazards;
figdir=model.cycledirfigures;
datadir=[model.datafolder 'data' filesep];

vel=load([maparchdir 'vel.mat']);
wlm=load([maparchdir 'wl.mat']);
bot=load([maparchdir 'bedlevel.mat']);

%% 
wl=load([hisarchdir 'wl.' hazard.wlStation '.mat']);
figname=[figdir 'ripcurrentstack.' hazard.name '.png'];
geojpg=[datadir hazard.geoJpgFile];
geojgw=[datadir hazard.geoJgwFile];

ref.x0=hazard.x0;
ref.y0=hazard.y0;
ref.orientation=hazard.coastOrientation;
ref.length1=hazard.length1;
ref.length2=hazard.length2;
ref.width1=hazard.width1;
ref.width2=hazard.width2;

x=vel.X;
y=vel.Y;
u=vel.U;
v=vel.V;
h=wlm.Val;
d=squeeze(bot.Val);
t=vel.Time;

dmin=0.5;
dmax=3;
warningLevels=[0.15 0.3 0.5];

%% Offshore velocities
[vcrsmax,ycrs,rips,warningLevel]=getRipCurrents(x,y,t,u,v,h,d,ref,warningLevels,dmin,dmax);

%% Time stack figure
ripCurrentTimestack(figname,t,ycrs,vcrsmax,wl,rips,warningLevel,warningLevels,ref,geojpg,geojgw);

%% Individual time series figures per rip
for ir=1:length(rips)
    fn=[figdir hazard.name '.ripcurrent' num2str(ir) '.png'];
    data.x=rips(ir).t;
    data.y=rips(ir).vmax;
    data.color='k';
    data.name='rip current';
    xl=[rips(ir).t(1) rips(ir).t(end)];
    xtcks=[rips(ir).t(1):1/8:rips(ir).t(end)];
    cosmos_timeSeriesPlot(fn,data,'xlim',xl,'xticks',xtcks,'ylim',[0 1],'yticks',[0:0.2:1],'ylabel','Current velocity (m/s)','title','Rip current velocity');
%    cosmos_ripCurrentTimeSeries(fn,rips,ir,wl,warningLevels);
end


%% Hazard xml and html
fname=[hazarchdir hazard.name '.xml'];

hzrd.type.type.value='ripcurrents';
hzrd.type.type.ATTRIBUTES.type.value='char';

hzrd.name.name.value=hazard.name;
hzrd.name.name.ATTRIBUTES.type.value='char';

hzrd.longname.longname.value=hazard.longName;
hzrd.longname.longname.ATTRIBUTES.type.value='char';

hzrd.html.html.value=[hazard.name '.html'];
hzrd.html.html.ATTRIBUTES.type.value='char';

%% Write html code
fi2=fopen([figdir hazard.name '.html'],'wt');
fprintf(fi2,'%s\n','<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
fprintf(fi2,'%s\n','<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">');
fprintf(fi2,'%s\n','<head>');
fprintf(fi2,'%s\n','</head>');
fprintf(fi2,'%s\n','<body>');
str=['<img src="ripcurrentstack.' hazard.name '.png">'];
fprintf(fi2,'%s\n',str);
fprintf(fi2,'%s\n','</body>');
fprintf(fi2,'%s\n','</html>');
fclose(fi2);

if ~strcmpi(model.coordinateSystem,'wgs 84')
    [lon,lat]=convertCoordinates(hazard.location(1),hazard.location(2),'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
else
    lon=hazard.location(1);
    lat=hazard.location(2);
end

hzrd.longitude.longitude.value=lon;
hzrd.longitude.longitude.ATTRIBUTES.type.value='real';
hzrd.latitude.latitude.value=lat;
hzrd.latitude.latitude.ATTRIBUTES.type.value='real';

% First try to determine distance between corner points of model limits
% Get value from xml
xlim=model.xLim;
ylim=model.yLim;
if ~strcmpi(model.coordinateSystem,'wgs 84')
    [xlim,ylim]=convertCoordinates(xlim,ylim,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
end
dstx=111111*(xlim(2)-xlim(1))*cos(mean(ylim)*pi/180);
dsty=111111*(ylim(2)-ylim(1));
dst=sqrt(dstx^2+dsty^2);
% Elevation is distance times 2
dst=dst*2;
dst=min(dst,10000000);
hzrd.elevation.elevation.value=dst;
hzrd.elevation.elevation.ATTRIBUTES.type.value='real';

for ir=1:length(rips)
    
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.name.name.value=['ripcurrent' num2str(ir)];
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.name.name.ATTRIBUTES.type.value='char';
    
    switch rips(ir).warningLevel
        case 1
            hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.longname.longname.value='Moderate rip current';
        case 2
            hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.longname.longname.value='Strong rip current';
        case 3
            hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.longname.longname.value='Very strong rip current';
    end
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.longname.longname.ATTRIBUTES.type.value='char';
    
    if ~strcmpi(model.coordinateSystem,'wgs 84')
        [lon,lat]=convertCoordinates(rips(ir).x,rips(ir).y,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    else
        lon=rips(ir).x;
        lat=rips(ir).y;
    end

    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.longitude.longitude.value=lon;
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.longitude.longitude.ATTRIBUTES.type.value='real';
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.latitude.latitude.value=lat;
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.latitude.latitude.ATTRIBUTES.type.value='real';
    
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.warninglevel.warninglevel.value=rips(ir).warningLevel;
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.warninglevel.warninglevel.ATTRIBUTES.type.value='int';
    
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.html.html.value=[hazard.name '.ripcurrent' num2str(ir) '.html'];
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.html.html.ATTRIBUTES.type.value='char';
    
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.warninglevel.warninglevel.value=rips(ir).warningLevel;
    hzrd.warninglocations.warninglocations.warninglocation(ir).warninglocation.warninglevel.warninglevel.ATTRIBUTES.type.value='int';

    %% Write html code
    fi2=fopen([figdir hazard.name '.ripcurrent' num2str(ir) '.html'],'wt');
    fprintf(fi2,'%s\n','<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
    fprintf(fi2,'%s\n','<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">');
    fprintf(fi2,'%s\n','<head>');
    fprintf(fi2,'%s\n','</head>');
    fprintf(fi2,'%s\n','<body>');
    str=['<img src="' hazard.name '.ripcurrent' num2str(ir) '.png">'];
    fprintf(fi2,'%s\n',str);
    fprintf(fi2,'%s\n','</body>');
    fprintf(fi2,'%s\n','</html>');
    fclose(fi2);
    
end

struct2xml(fname,hzrd,'includeattributes',1,'structuretype','long');
