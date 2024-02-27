function subgrd=sfincs_read_binary_subgrid_tables_v8(folder)

inpfile=[folder filesep 'sfincs.inp'];

inp=sfincs_read_input(inpfile);
nmax=inp.nmax;
mmax=inp.mmax;

% Read index file
fid=fopen([folder inp.indexfile],'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read subgrd file
fid=fopen([folder inp.sbgfile],'r');
np=fread(fid,1,'integer*4');
uopt=fread(fid,1,'integer*4');
nbin=fread(fid,1,'integer*4');

subgrd.nbins=nbin;

switch uopt
    case 0
        subgrd.uopt='mean';
    case 1
        subgrd.uopt='min';
    case 2
        subgrd.uopt='minmean';
end
        
v0=zeros(nmax,mmax);
v0(v0==0)=NaN;
v03=zeros(nbin,nmax,mmax);
v03(v03==0)=NaN;
subgrd.z_zmin=v0;
subgrd.z_zmax=v0;
%subgrd.z_vol=v03;
subgrd.z_depth=v03;
subgrd.u_zmin=v0;
subgrd.u_zmax=v0;
subgrd.u_dhdz=v0;
subgrd.u_hrep=v03;
subgrd.u_navg=v03;
subgrd.v_zmin=v0;
subgrd.v_zmax=v0;
subgrd.v_dhdz=v0;
subgrd.v_hrep=v03;
subgrd.v_navg=v03;

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.z_zmin=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.z_zmax=v;

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.z_volmax=v;

for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
%     subgrd.z_vol(:,:,ibin)=v;
    subgrd.z_depth(ibin,:,:)=v;
end

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.u_zmin=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.u_zmax=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.u_dhdz=v;
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.u_hrep(ibin,:,:)=v;
end
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.u_navg(ibin,:,:)=v;
end

v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.v_zmin=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.v_zmax=v;
v=v0;
d=fread(fid,np,'real*4');
v(indices)=d;
subgrd.v_dhdz=v;
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.v_hrep(ibin,:,:)=v;
end
for ibin=1:nbin
    v=v0;
    d=fread(fid,np,'real*4');
    v(indices)=d;
    subgrd.v_navg(ibin,:,:)=v;
end

fclose(fid);