function [u,v]=ww3_read_obstructions_file(fname,nx,ny,scalingfactor)

fid=fopen(fname,'r');
u=textscan(fid,'%f',nx*ny);
u=u{1};
v=textscan(fid,'%f',nx*ny);
v=v{1};
fclose(fid);

u=reshape(u,[nx ny]);
v=reshape(v,[nx ny]);

u=u*scalingfactor;
v=v*scalingfactor;
