function [t,obs]=getTimeSeriesFromCoops(urlstr,t0,t1,id,par)

starttime=datestr(t0,'yyyymmdd');
stoptime=datestr(t1,'yyyymmdd');

datum='MSL';

wstr='WATERLEVEL_RAW_PX.';
stat='_STATION_ID';
dat='_DATUM';
beg='_BEGIN_DATE';
endd='_END_DATE';
val='WL_VALUE';

str1=[urlstr 'Raw_Water_Level?' wstr stat ',' wstr dat ',' wstr beg ',' wstr endd ',' wstr val ',' wstr 'DATE_TIME' '&'];
str2=[wstr stat '="' id '"&' wstr dat '="' datum '"&' wstr beg '="' starttime '"&' wstr endd '="' stoptime '"'];

str=[str1 str2];

nok=0;
while nok<5
    try
        loaddap(str);
        nok=5;
    catch
        system(killwdapstr);
        disp('Process writedap.exe was killed (prmsl)');
        nok=nok+1;
        pause(0.5);
    end
end

a=WATERLEVEL_RAW_PX;

obs=a.WL_VALUE;
t=datenum(a.DATE_TIME);

