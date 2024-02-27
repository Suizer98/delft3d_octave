function [zsmax,vmax,tmax] = sfincs_read_binary_map_simple(dr,np,indices,msk,inp)
% Load binary output from SFINCS
% Redo inp
% zsmax
DAT_file        = [dr, '\zsmax.dat'];
fid             = fopen(DAT_file,'r');
idummy          = fread(fid,1,'integer*4');
zsv             = fread(fid,np,'real*4');
idummy          = fread(fid,1,'integer*4');
zs0             = NaN(inp.nmax,inp.mmax);
if isempty(zsv)
    error('not results in binary output: stop script')
end
zs0(indices)    = zsv;
%zs0(zs0 < -100 | msk ~= 1) = NaN;
zs0(zs0 < -100) = NaN;
zsmax           = zs0;
fclose(fid);

% zsmax
DAT_file        = [dr, '\velmax.dat'];
fid             = fopen(DAT_file,'r');
idummy          = fread(fid,1,'integer*4');
zsv             = fread(fid,np,'real*4');
idummy          = fread(fid,1,'integer*4');
zs0             = NaN(inp.nmax,inp.mmax);
zs0(indices)    = zsv;
%zs0(zs0 < -100 | msk ~= 1) = NaN;
zs0(zs0 < -100) = NaN;
vmax            = zs0;
fclose(fid);

% zsmax
DAT_file        = [dr, '\tmax.dat'];
fid             = fopen(DAT_file,'r');
idummy          = fread(fid,1,'integer*4');
zsv             = fread(fid,np,'real*4');
idummy          = fread(fid,1,'integer*4');
zs0             = NaN(inp.nmax,inp.mmax);
zs0(indices)    = zsv;
%zs0(zs0 < -100 | msk ~= 1) = NaN;
zs0(zs0 < -100) = NaN;
tmax            = zs0;
fclose(fid);

end

