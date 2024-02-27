function msk=sfincs_boundary_mask(z,zlev)

z(z<zlev)=NaN;

msk=zeros(size(z));

msk(~isnan(z))=1;

imax=size(msk,1);
jmax=size(msk,2);

% Find any surrounding points that have a NaN value

% Left
iside=1;
ii1a(iside)=1;
ii2a(iside)=imax;
jj1a(iside)=1;
jj2a(iside)=jmax-1;
ii1b(iside)=1;
ii2b(iside)=imax;
jj1b(iside)=2;
jj2b(iside)=jmax;
% Right
iside=2;
ii1a(iside)=1;
ii2a(iside)=imax;
jj1a(iside)=2;
jj2a(iside)=jmax;
ii1b(iside)=1;
ii2b(iside)=imax;
jj1b(iside)=1;
jj2b(iside)=jmax-1;
% Bottom
iside=3;
ii1a(iside)=1;
ii2a(iside)=imax-1;
jj1a(iside)=1;
jj2a(iside)=jmax;
ii1b(iside)=2;
ii2b(iside)=imax;
jj1b(iside)=1;
jj2b(iside)=jmax;
% Top
iside=4;
ii1a(iside)=2;
ii2a(iside)=imax;
jj1a(iside)=1;
jj2a(iside)=jmax;
ii1b(iside)=1;
ii2b(iside)=imax-1;
jj1b(iside)=1;
jj2b(iside)=jmax;

for iside=1:4
    zb=z(ii1a(iside):ii2a(iside),jj1a(iside):jj2a(iside));
    zc=z(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));
    mskc=msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));
    ibnd= isnan(zb) & ~isnan(zc);
    mskc(ibnd)=2;
    msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside))=mskc;
end


