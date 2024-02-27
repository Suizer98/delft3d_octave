%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17214 $
%$Date: 2021-04-29 00:05:01 +0800 (Thu, 29 Apr 2021) $
%$Author: chavarri $
%$Id: preallocate_dependent_vars.m 17214 2021-04-28 16:05:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/preallocate_dependent_vars.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170720
%   -V & Pepijn. Created for the first time.
%
%210315
%   -V. Added interpolation at edges.

function [u_bra,h_bra,etab_bra,Mak_bra,La_bra,msk_bra,Ls_bra,Cf_bra,Cf_b_bra,qbk_bra,thetak_bra,pmm_bra,ell_idx_bra,Gammak_bra,Ek_bra,Dk_bra,psi_bra,u_edg_bra,h_edg_bra,qbk_edg_bra,Cf_b_edg_bra,Mak_edg_bra,La_edg_bra,celerities,celerities_edg,pmm_edg_bra,bc,time_loop]=preallocate_dependent_vars(input,fid_log)

%%
%% RENAME
%%

nb=input(1,1).mdv.nb;

%%
% switch input.mdv.dt_type
%     case 1
%         time_loop=zeros(floor(input(1,1).mdv.Flmap_dt/input(1,1).mdv.dt),1); %this needs to be before output_creation if you want to save the variable. Preallocate with zeros to avoid NaN in first saving loop.
%     case 2
        time_loop=NaN(input(1,1).mdv.disp_t_nt,1); %we do mean without NaN
% end

%matrix
u_bra=cell(nb,1);
h_bra=cell(nb,1);
etab_bra=cell(nb,1);
Mak_bra=cell(nb,1);
La_bra=cell(nb,1);
msk_bra=cell(nb,1);
Ls_bra=cell(nb,1);
Cf_bra=cell(nb,1);
Cf_b_bra=cell(nb,1);
qbk_bra=cell(nb,1);
thetak_bra=cell(nb,1);
pmm_bra=cell(nb,1);
pmm_edg_bra=cell(nb,1);
ell_idx_bra=cell(nb,1);
Gammak_bra=cell(nb,1);
Ek_bra=cell(nb,1);
Dk_bra=cell(nb,1);
psi_bra=cell(nb,1);
u_edg_bra=cell(nb,1);
h_edg_bra=cell(nb,1);
qbk_edg_bra=cell(nb,1);
Cf_b_edg_bra=cell(nb,1);
Mak_edg_bra=cell(nb,1);
La_edg_bra=cell(nb,1);

%structures
bc(nb,1)=struct('q0',[],'Q0',[],'repQT',[],'etaw0',[],'rephT',[],'qbk0',[],'Qbk0',[],'repQbkT',[],'repGammakT_u',[],'repGammakT_d',[],'Gammak0',[],'GammakL',[],'g_u',[],'g_d',[],'repLaT',[],'La',[]); %if you change this line, copy paste the changes in boundary_condition_construction.m
celerities(nb,1)    =struct('ls',[],'lb',[],'gamma',[],'mu',[],'A',[],'eigen',[],'eigen_pmm',[]);
celerities_edg(nb,1)=struct('ls',[],'lb',[],'gamma',[],'mu',[],'A',[],'eigen',[],'eigen_pmm',[]);
% celerities_edg(nb,1)=struct('ls',[],'lb',[]);

for kb=1:nb
    nx=input(kb,1).mdv.nx;
    nef=input(kb,1).mdv.nef;
    nf=input(kb,1).mdv.nf;
    nsl=input(kb,1).mdv.nsl;
    
    u_bra	{kb,1}   =NaN(1  ,nx,1  );
    h_bra	{kb,1}   =NaN(1  ,nx,1  );
    etab_bra{kb,1}   =NaN(1  ,nx,1  );
    Mak_bra	{kb,1}   =NaN(nef,nx,1  );
    La_bra	{kb,1}   =NaN(1  ,nx,1  );
    msk_bra	{kb,1}   =NaN(nef,nx,nsl);
    Ls_bra	{kb,1}   =NaN(1  ,nx,nsl);
    Cf_bra	{kb,1}   =NaN(1  ,nx,1  );
    Cf_b_bra{kb,1}   =NaN(1  ,nx,1  );
    qbk_bra {kb,1}   =NaN(nf ,nx,1  );
    thetak_bra{kb,1} =NaN(nf ,nx,1  );
    pmm_bra{kb,1}    =NaN(2  ,nx,1  );
    ell_idx_bra{kb,1}=NaN(1  ,nx,1  );
    Gammak_bra{kb,1} =NaN(nf ,nx,1  );
    Ek_bra{kb,1}     =NaN(nf ,nx,1  );
    Dk_bra{kb,1}     =NaN(nf ,nx,1  );
    psi_bra{kb,1}    =NaN(1  ,nx    );
    
    u_edg_bra{kb,1}   =NaN(1  ,nx+1,1  );
    h_edg_bra{kb,1}   =NaN(1  ,nx+1,1  );
    qbk_edg_bra{kb,1} =NaN(nf ,nx+1,1  );
    Cf_b_edg_bra{kb,1}=NaN(1  ,nx+1,1  );
    Mak_edg_bra{kb,1} =NaN(nef,nx+1,1  );
    La_edg_bra{kb,1}  =NaN(1  ,nx+1,1  );
    pmm_edg_bra{kb,1} =NaN(2  ,nx+1,1  );

    celerities(kb,1).ls   =NaN(nef,nx    );
    celerities(kb,1).lb   =NaN(1  ,nx    );
    celerities(kb,1).gamma=NaN(nef,nx    );
    celerities(kb,1).mu   =NaN(nef,nx,nef);
    
    celerities_edg(kb,1).ls   =NaN(nef,nx+1    );
    celerities_edg(kb,1).lb   =NaN(1  ,nx+1    );
%     celerities_edg(kb,1).gamma=NaN(nef,nx+1    );
%     celerities_edg(kb,1).mu   =NaN(nef,nx+1,nef);
end