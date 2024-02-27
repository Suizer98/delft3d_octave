function [dmin,dmax,aaa,www]=sfincs_subgrid_area_and_depth(d,nbin,dx)
% Determine SFINCS subgrid area and depth

nmax=size(d,1);
mmax=size(d,2);
nrd=size(d,3);

dmin=min(d,[],3);
dmax=max(d,[],3);

dbin=(dmax-dmin)/nbin;

aaa=zeros(nmax,mmax,nbin);
www=aaa;

% First bin
zb=dmin+dbin;
zb=repmat(zb,[1 1 nrd]);
ibelow=d<=zb;
nbelow=sum(ibelow,3);
www(:,:,1)=dx*nbelow/nrd;
aaa(:,:,1)=0.5*www(:,:,1).*dbin;

% Next bins
for ibin=2:nbin
    zb=dmin+ibin*dbin;
    zb=repmat(zb,[1 1 nrd]);
    ibelow=d<=zb;
    nbelow=sum(ibelow,3);
    www(:,:,ibin)=dx*nbelow/nrd;
    aaa(:,:,ibin)=aaa(:,:,ibin-1)+0.5*(www(:,:,ibin)+www(:,:,ibin-1)).*dbin;
end
