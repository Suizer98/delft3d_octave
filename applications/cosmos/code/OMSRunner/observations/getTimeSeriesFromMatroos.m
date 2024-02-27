function [t,obs]=getTimeSeriesFromMatroos(urlstr,t0,t1,id,par)

t(1:14400) = NaN;
obs(1:14400)=NaN;
startdate = [datestr(floor(t0),'yyyymmdd') '000000'];
stopdate = [datestr(ceil(t1),'yyyymmdd') '000000'];
[t, obs]=GetMatroosSeries(par,'observed',id,startdate,stopdate);
