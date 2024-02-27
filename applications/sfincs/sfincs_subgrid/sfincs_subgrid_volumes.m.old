function [dmin,dmax,vvv]=sfincs_subgrid_volumes(d,nbin,dx,dy)
% Determine SFINCS subgrid volumes

nmax=size(d,1);
mmax=size(d,2);
nrd=size(d,3);

dmin=min(d,[],3);
dmax=max(d,[],3);
a=dx*dy/nrd; % pixel area

dbin=(dmax-dmin)/nbin;

vvv=zeros(nmax,mmax,nbin);

for ibin=1:nbin
    zb=dmin+ibin*dbin;
    zb=repmat(zb,[1 1 nrd]);
    vvv(:,:,ibin)=sum(a*max(zb-d,0),3);
end