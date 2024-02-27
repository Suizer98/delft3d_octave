flightpath=[];

t0=datenum('20131107 220000','yyyymmdd HHMMSS');
t1=datenum('20131107 223000','yyyymmdd HHMMSS');
dt=60; % seconds
nt=(t1-t0)/(dt/86400);
n=0;
az0=-76;
az1=0;
daz=(az1-az0)/nt;

az=az0;

for t=t0:dt/86400:t1
    n=n+1;
    az=az+daz;

flightpath.waypoint(n).waypoint.time=datestr(t,'yyyymmdd HHMMSS');
flightpath.waypoint(n).waypoint.cameratargetx=785874.8588;
flightpath.waypoint(n).waypoint.cameratargety=1252337.227;
flightpath.waypoint(n).waypoint.cameratargetz=3.5344;
flightpath.waypoint(n).waypoint.cameraazimuth=az;
flightpath.waypoint(n).waypoint.cameraelevation=38.8;
flightpath.waypoint(n).waypoint.cameradistance=20700;
% flightpath.waypoint(2).waypoint.time='20131107 223000';
% flightpath.waypoint(2).waypoint.cameratargetx=785874.8588;
% flightpath.waypoint(2).waypoint.cameratargety=1252337.227;
% flightpath.waypoint(2).waypoint.cameratargetz=3.5344;
% flightpath.waypoint(2).waypoint.cameraazimuth=az;
% flightpath.waypoint(2).waypoint.cameraelevation=38.8;
% flightpath.waypoint(2).waypoint.cameradistance=20700;
end

struct2xml('flightpath.xml', flightpath,'structuretype','short');
