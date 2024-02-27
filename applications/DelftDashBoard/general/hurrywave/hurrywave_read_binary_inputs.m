function [z,msk]=hurrywave_read_binary_inputs(mmax,nmax,bindepfile,binmskfile,varargin)

% Reads binary input files for HurryWave
z=zeros(nmax,mmax);
z(z==0)=NaN;
msk=z;

% Read mask file
fid=fopen(binmskfile,'r');
mskv=fread(fid,nmax*mmax,'integer*1');
fclose(fid);
msk=reshape(mskv,[nmax mmax]);

if ~isempty(bindepfile)
    % Read depth file
    if exist(bindepfile,'file')
        fid=fopen(bindepfile,'r');
        zbv=fread(fid,nmax*mmax,'real*4');
        fclose(fid);
        z=reshape(zbv,[nmax mmax]);
    end
end
