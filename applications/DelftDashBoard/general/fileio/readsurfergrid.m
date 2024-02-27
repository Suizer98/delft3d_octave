function [x,y,z]=readsurfergrid(fname)
x=[];
y=[];
z=[];
fid=fopen(fname,'r');
s=fgets(fid);
s=fgets(fid);
n=str2num(s);
ncols=n(1);
nrows=n(2);
s=fgets(fid);
n=str2num(s);
xmin=n(1);
xmax=n(2);
s=fgets(fid);
n=str2num(s);
ymin=n(1);
ymax=n(2);
s=fgets(fid);
s=textscan(fid,'%f');
s=s{1};

dx=(xmax-xmin)/(ncols-1);
dy=(ymax-ymin)/(nrows-1);

x=xmin:dx:xmax;
y=ymin:dy:ymax;
z=reshape(s,[ncols nrows]);
z=z';

fclose(fid);
