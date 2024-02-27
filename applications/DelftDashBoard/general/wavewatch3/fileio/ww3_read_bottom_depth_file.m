function s=ww3_read_bottom_depth_file(fname,nx,ny,scalingfactor)

fid=fopen(fname,'r');
s=textscan(fid,'%f',nx*ny);
s=s{1};
fclose(fid);

s=reshape(s,[nx ny]);
s=s';

s=s*scalingfactor;
