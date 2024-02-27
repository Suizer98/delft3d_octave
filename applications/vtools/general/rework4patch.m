%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: rework4patch.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/rework4patch.m $
%
%Rework input from scatter to patch
%
%NOTATION IN DESCRIPTION
%   -nx: number of streamwise cells (with associated value)
%   -nxe: number of cell edges (i.e., nn + 1)
%   -nl: number of substrate layers (with associated value)
%   -nle: number of substrate edges (i.e., nl+1)
%
%INPUT:
%   -XCOR: coordinates of cell edges; dimensions [1,nxe], e.g. [1x1101 double]
%   -sub: coordinates of substrate points; dimensions [nle,nx], e.g. [22x1100 double]
%   -cvar: values at cell centre; dimentions [nl,nx], e.g. [21x1100 double]

function [f,v,col]=rework4patch(in)

%% RENAME in

XCOR=in.XCOR;
sub=in.sub;
cvar=in.cvar;

%sizes
nxe=size(XCOR,2);
nx=nxe-1;
nl=size(cvar,1);
nle=nl+1;

%% CHECK INUT

if sum(size(XCOR)-[1,nxe])~=0
    error('XCOR dimensions are incorrect')
end
if sum(size(sub)-[nle,nx])~=0
    error('sub dimensions are incorrect')
end
if sum(size(cvar)-[nl,nx])~=0
    error('cvar dimensions are incorrect')
end

%% data rework

%patches
Cm=cvar'; 
Xm=repmat(XCOR,nle,1);
Ym=sub;

xr=reshape(Xm',nxe*nle,1);
yr=reshape(Ym',nx*(nl+1),1);
aux= reshape(repmat(1:1:nxe,2,1),nxe*2,1);
aux1=reshape(repmat(1:1:nx*(nl+1),2,1),(nx*(nl+1))*2,1);
aux2=aux(2:end-1);
aux3=repmat(aux2,nl+1,1);
v(:,1)=xr(aux3);
v(:,2)=yr(aux1);

f=NaN(nl*nx,4);
f(:,1:2)=(reshape(1:1:(nx*2*nl),2,nl*nx))';
aux=(reshape((nx*2+1):1:((nx*2)*(nl+1)),2,nl*nx))';
f(:,3)=aux(:,2);
f(:,4)=aux(:,1);

col=reshape(Cm,nx*nl,1);