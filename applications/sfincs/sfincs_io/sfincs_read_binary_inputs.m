function [z,msk]=sfincs_read_binary_inputs(mmax,nmax,indexfile,bindepfile,binmskfile)

% Reads binary input files for SFINCS

z=zeros(nmax,mmax);
z(z==0)=NaN;
msk=z;

% Read index file
fid=fopen(indexfile,'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read depth file
fid=fopen(bindepfile,'r');
zbv=fread(fid,np,'real*4');
fclose(fid);

% Read depth file
fid=fopen(binmskfile,'r');
mskv=fread(fid,np,'integer*1');
fclose(fid);

z(indices)=zbv;
msk(indices)=mskv;
