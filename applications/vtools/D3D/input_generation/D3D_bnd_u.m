%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_bnd_u.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bnd_u.m $
%
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bnd_u(simdef)
%% RENAME

upstream_nodes=simdef.mor.upstream_nodes;
fname_pli_d=simdef.pli.fname_d;
fname_pli_u=simdef.pli.fname_u;
str_bc_u=simdef.bc.fname_u;
str_bc_d=simdef.bc.fname_d;
file_name=simdef.file.extn;
fdir_pli_rel=simdef.file.fdir_pli_rel;
fdir_bc_rel=simdef.file.fdir_bc_rel;

%% FILE

%no edit
kl=1;
    for kny=1:upstream_nodes
data{kl, 1}=''; kl=kl+1;
data{kl, 1}='[boundary]'; kl=kl+1;
data{kl, 1}='quantity=dischargebnd'; kl=kl+1;
data{kl, 1}=sprintf('locationfile=%s%s_%02d.pli',fdir_pli_rel,fname_pli_u,kny); kl=kl+1;
data{kl, 1}=sprintf('forcingfile=%s%s.bc',fdir_bc_rel,str_bc_u); kl=kl+1;
    end
data{kl, 1}=''; kl=kl+1;
data{kl, 1}='[boundary]'; kl=kl+1;
data{kl, 1}='quantity=waterlevelbnd'; kl=kl+1;
data{kl, 1}=sprintf('locationfile=%s%s.pli',fdir_pli_rel,fname_pli_d); kl=kl+1;
data{kl, 1}=sprintf('forcingfile=%s%s.bc',fdir_bc_rel,str_bc_d); kl=kl+1;
data{kl, 1}=''; 

%% WRITE

writetxt(file_name,data,'check_existing',false)

