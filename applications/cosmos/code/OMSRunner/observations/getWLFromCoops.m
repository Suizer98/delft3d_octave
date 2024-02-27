function [t,wl]=getWLFromCoops(station,t0,t1)

url=['http://opendap.co-ops.nos.noaa.gov/dods/IOOS/Raw_Water_Level.ascii?&WATERLEVEL_RAW_PX._STATION_ID="' station '"&WATERLEVEL_RAW_PX._DATUM="MSL"&WATERLEVEL_RAW_PX._BEGIN_DATE="' datestr(t0,'yyyymmdd') '"&WATERLEVEL_RAW_PX._END_DATE="' datestr(t1,'yyyymmdd') '"'];
h=urlread(url);
ii=regexp(h,['"' station '"']);
dst=ii(2)-ii(1);
for j=1:length(ii)
    str=h(ii(j):ii(j)+dst-1);
    d=strread(str,'%s','delimiter',',');
    tstr=d{7}(2:end-1);
    t(j)=datenum(tstr);
    wl(j)=str2double(d{8});
end
