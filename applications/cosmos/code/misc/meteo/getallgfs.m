clear all;close all;

t0=datenum(2009,3,4);
t1=datenum(2009,3,6,0,0,0);
%t2=datenum(2009,3,02);
dt=0.25;

datenow=floor(now);
thnow=(now-datenow);
thnow=0.25*floor(4*thnow);
cycnow=datenow+thnow;

disp(datestr(cycnow,'yyyymmdd HHMMSS'));

hm.modelDirectory='d:\OperationalModelSystem\SantaBarbara\';

for t=t0:dt:t1
    th=(t-floor(t))*24;
    tcyc=[t th];
    disp(datestr(t));
    if t<cycnow-0.25
        tt=[t t+0.125];
        disp(datestr(tt));
        GetOpenDAP('gfs05',tcyc,tt,[],[],[hm.modelDirectory 'meteo\']);
    else
        tt=[t t1];
        disp(datestr(tt));
        GetOpenDAP('gfs05',tcyc,tt,[],[],[hm.modelDirectory 'meteo\']);
        break
    end        
end


