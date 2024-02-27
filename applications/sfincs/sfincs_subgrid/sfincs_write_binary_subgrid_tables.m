function sfincs_write_binary_subgrid_tables(subgrd,msk,nbin,subgridfile,uopt)

% Writes binary subgrid files for SFINCS
% nmax=size(msk,1);
% mmax=size(msk,2);

uopt='min'; % always set to min!

iincl=0;  % include only msk=1 and msk=2
% iincl=-1; % include all points

indices=find(msk>iincl);

fid=fopen(subgridfile,'w');

fwrite(fid,length(indices),'integer*4');

switch lower(uopt)
    case{'mean'}
        fwrite(fid,0,'integer*4');
    case{'min'}
        fwrite(fid,1,'integer*4');
    case{'minmean'}
        fwrite(fid,2,'integer*4');
end

fwrite(fid,nbin,'integer*4');

% Volumes
val=subgrd.z_zmin(msk>iincl);
fwrite(fid,val,'real*4');
val=subgrd.z_zmax(msk>iincl);
fwrite(fid,val,'real*4');
volmax=squeeze(subgrd.z_volmax);
val=volmax(msk>iincl);
fwrite(fid,val,'real*4');
for ibin=1:nbin
%    v=squeeze(subgrd.z_vol(:,:,ibin));
    v=squeeze(subgrd.z_depth(:,:,ibin));
    val=v(msk>iincl);
    fwrite(fid,val,'real*4');
end

% U points
val=subgrd.u_zmin(msk>iincl);
fwrite(fid,val,'real*4');
val=subgrd.u_zmax(msk>iincl);
fwrite(fid,val,'real*4');
val=subgrd.u_dhdz(msk>iincl);
fwrite(fid,val,'real*4');
for ibin=1:nbin
    v=squeeze(subgrd.u_hrep(:,:,ibin));
    val=v(msk>iincl);
    fwrite(fid,val,'real*4');
end
for ibin=1:nbin
    v=squeeze(subgrd.u_navg(:,:,ibin));
    val=v(msk>iincl);
    fwrite(fid,val,'real*4');
end


% for ibin=1:nbin
% %    v=squeeze(subgrd.u_area(:,:,ibin));
%     v=squeeze(subgrd.u_hrep(:,:,ibin));
%     val=v(msk>0);
%     fwrite(fid,val,'real*4');
% end

% V points
val=subgrd.v_zmin(msk>iincl);
fwrite(fid,val,'real*4');
val=subgrd.v_zmax(msk>iincl);
fwrite(fid,val,'real*4');
val=subgrd.v_dhdz(msk>iincl);
fwrite(fid,val,'real*4');
for ibin=1:nbin
    v=squeeze(subgrd.v_hrep(:,:,ibin));
    val=v(msk>iincl);
    fwrite(fid,val,'real*4');
end
for ibin=1:nbin
    v=squeeze(subgrd.v_navg(:,:,ibin));
    val=v(msk>iincl);
    fwrite(fid,val,'real*4');
end
% for ibin=1:nbin
% %    v=squeeze(subgrd.v_area(:,:,ibin));
%     v=squeeze(subgrd.v_hrep(:,:,ibin));
%     val=v(msk>0);
%     fwrite(fid,val,'real*4');
% end

fclose(fid);
