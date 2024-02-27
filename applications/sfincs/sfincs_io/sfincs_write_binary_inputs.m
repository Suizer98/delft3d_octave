function sfincs_write_binary_inputs(z,msk,indexfile,bindepfile,binmskfile)

% Writes binary input files for SFINCS

iincl=0;  % include only msk=1 and msk=2
%iincl=-1; % include all points

% Index file
indices=find(msk>iincl);

mskv=msk(msk>iincl);

fid=fopen(indexfile,'w');
fwrite(fid,length(indices),'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

% Depth file
zv=z(msk>iincl);
% zv=max(zv,-5);

fid=fopen(bindepfile,'w');
fwrite(fid,zv,'real*4');
fclose(fid);

% Mask file
fid=fopen(binmskfile,'w');
fwrite(fid,mskv,'integer*1');
fclose(fid);
