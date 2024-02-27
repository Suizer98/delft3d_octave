function sfincs_convert_qinffile(qinffile_in, qinffile_out, indexfile, mmax, nmax)
% Convert old SFINCS infiltration file to new unit (-m/s to +mm/hr), both still binary format
% v1.0  Leijnse     Jun-20

% Reads binary input files for SFINCS
inf_q = zeros(nmax,mmax);
inf_q(inf_q==0) = NaN;

% Read index file
fid=fopen(indexfile,'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read infiltration file
fid=fopen(qinffile_in,'r');
qinf=fread(fid,np,'real*4');
fclose(fid);

inf_q(indices) = qinf;

inf_q = inf_q *-1*1000*3600; %from -m/s to +mm/hr

inf_q_write = inf_q(indices);

fid = fopen(qinffile_out,'w');
fwrite(fid,inf_q_write,'real*4');
fclose(fid);