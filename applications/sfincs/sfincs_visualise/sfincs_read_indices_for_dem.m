function [indices,nmax,mmax]=sfincs_read_indices_for_dem(fname)

fid=fopen(fname,'r');
nmax=fread(fid,1,'integer*4');
mmax=fread(fid,1,'integer*4');
np=nmax*mmax;
indices=fread(fid,np,'integer*4');
fclose(fid);

