function [x,y,z]=sfincs_read_hmaxgeo_bin(geomskfile,datafile)

% Geo-mask file
fid=fopen(geomskfile,'r');
ncols=fread(fid,1,'int32');
nrows=fread(fid,1,'int32');
xll=fread(fid,1,'double');
yll=fread(fid,1,'double');
dlon=fread(fid,1,'double');
np=fread(fid,1,'int32');
ind=fread(fid,np,'int32');
fclose(fid);

% Data file
fid=fopen(datafile,'r');
fread(fid,1,'int64'); % dummy line
zv=fread(fid,np,'real*4');
fclose(fid);

% Set
z=zeros(nrows,ncols);
z(z==0)=NaN;
z(ind)=zv;

% Grid
x=xll:dlon:xll+(ncols-1)*dlon;
y=yll:dlon:yll+(nrows-1)*dlon;
