function sfincs_hmax2arcinfo(ascfile,geomskfile,hmaxfile)

[x,y,z]=sfincs_read_hmaxgeo_bin(geomskfile,hmaxfile);

z=flipud(z);
z=round(z*100);

z(isnan(z))=-999;

x0=x(1);
y0=y(1);
nrows=length(y);
ncols=length(x);
dx=(x(end)-x(1))/(ncols-1);

fid=fopen(ascfile,'wt');

fprintf(fid,'%s %i\n',   'ncols       ',ncols);
fprintf(fid,'%s %i\n',   'nrows       ',nrows);
fprintf(fid,'%s %0.6f\n','xllcorner   ',x0);
fprintf(fid,'%s %0.6f\n','yllcorner   ',y0);
fprintf(fid,'%s %0.6f\n','cellsize    ',dx);
fprintf(fid,'%s\n',      'NODATA_value -999');

fmt='%5i';
fmt=[repmat(fmt,1,ncols) '\n'];
fmt=repmat(fmt,1,nrows);

fprintf(fid,fmt,z');

fclose(fid);
