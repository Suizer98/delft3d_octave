%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17215 $
%$Date: 2021-04-29 13:40:02 +0800 (Thu, 29 Apr 2021) $
%$Author: chavarri $
%$Id: check_simulation.m 17215 2021-04-29 05:40:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_simulation.m $
%
%check_simulation does this and that
%
%check_simulation(u,h,Mak,Mak_old,msk,msk_old,La,La_old,Ls,Ls_old,qbk,bc,ell_idx,celerities,pmm,input,fid_log,kt)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%160503
%   -L. Updated for repeated hydrographs
%
%160429
%   -V. Periodic boundary conditions and 3 fractions ls
%
%160504
%   -V. Negative fractions
%
%160614
%   -V. Output pmm for adjusting CFL condition. Relative mass check
%160803
%	-L. Merged
%170126 -L. added case 13 (no new version)
%
%200709
%   -V. Added debug figure

function check_simulation(u,u_edg,h,h_edg,Mak,Mak_old,msk,msk_old,La,La_old,Ls,Ls_old,etab,etab_old,qbk,qbk_edg,bc,ell_idx,celerities,pmm,vpk,input,fid_log,kt,time_l)
         
%%
%% RENAME
%%

nsl=input.mdv.nsl;
nef=input.mdv.nef;
nf=input.mdv.nf;
nx=input.mdv.nx; %number of cells

dt=input.mdv.dt;
dx=input.grd.dx;

cb=1-input.mor.porosity;
g=input.mdv.g;

kappa=input.tra.kappa;

bc_interp_type=input.mdv.bc_interp_type;

Fr_lim=input.mdv.chk.Fr_lim;
cfl_lim=input.mdv.chk.cfl_lim;
dM_lim=input.mdv.chk.dM_lim;
Pe_lim=input.mdv.chk.Pe_lim;

alpha=pmm(1,:);
beta=pmm(2,:);

if nf > 1
    F_lim=input.mdv.chk.F_lim;
end

%% DEBUG FIGURE
% dtstop=1;
% if ~(rem(kt,dtstop))
% hanfig=debug_figure(u,u_edg,h,h_edg,Mak,Mak_old,msk,msk_old,La,La_old,Ls,Ls_old,etab,etab_old,qbk,qbk_edg,bc,ell_idx,celerities,pmm,vpk,input,fid_log,kt,time_l);
% close(hanfig)
% end

%% compute upstream bed load
if input.mor.particle_activity==0
switch bc_interp_type
    case 1 %interpolate at the beggining
        switch input.bcm.type
            case {1,3,11,12,13,14,'set1'}
                Qbkt = mod(kt,bc.repQbkT(2))+(mod(kt,bc.repQbkT(2))==0)*bc.repQbkT(2);
                qbk0=bc.qbk0(Qbkt,:); %total load [m^3/s]; [1xnf double]
            case 2
                qbk0=qbk(:,end);
            case 4
                %it should be computed as the value that keeps the bed
                %stable                
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
    case 2 %interpolate here
        switch input.bcm.type
            case 1
                Qbk0=NaN(1,nf);
                for kf=1:nf
                    Qbk0(1,kf)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time_l,'linear')'; 
                end
                qbk0=Qbk0./input.grd.B(1);
            case 2
                qbk0=qbk(:,end);
            case 4
                %it should be computed as the value that keeps the bed
                %stable
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
end %bc_interp_type
else
    qbk0=qbk(:,end); %this is crap! needs to be updated with qbk0=Gammak0*vpk0-kappa*dGamma/dx
end

%%
%%
%%


%%
%% CFL
%%

if input.mdv.chk.flow==1
    
    sqrt_gh=sqrt(g*h);
    Fr=u./sqrt_gh;
    
    %advection
    if isempty(celerities.lb)==1
        psi=5*sum(qbk,1)./(u.*h); %dqb_dq approximation as EH (analytical)
        celerities.lb=psi./(1-Fr.^2);
    end
       
    if isempty(celerities.ls)==1
        celerities.ls=sum(qbk,1)./La./u; %approximation
    end
    
    c=celerities4CFL(u,h,celerities,pmm,vpk,input,fid_log,kt);

    %diffusion
    if input.mor.particle_activity==1 && any(kappa)~=0
        Pe=dx.*vpk./repmat(kappa,1,nx);
        [Pe_max,Pe_max_kx]=max(max(Pe,[],1));
    end
    
    [Fr_max,Fr_max_kx]=max(Fr);
    [c_max,c_max_kx]=max(c);
    cfl_max=c_max*dt/dx;
     
    
    if kt==1 || time_l-input.mor.Tstart<3*input.mdv.dt %initial max Fr and CFL numbers 
        warningprint(fid_log,sprintf('max. initial CFL = %4.2f at node %d',cfl_max,c_max_kx))
        warningprint(fid_log,sprintf('max. initial Fr  = %4.2f at node %d',Fr_max,Fr_max_kx))
        if input.mor.particle_activity==1 && any(kappa)~=0
        warningprint(fid_log,sprintf('max. initial Pe  = %4.2f at node %d',Pe_max,Pe_max_kx))
        end
    else 
        if Fr_max>Fr_lim
            warningprint(fid_log,sprintf('ATTENTION!!! Max. Fr  = %4.2f at kx = %d; kt= %d',Fr_max,Fr_max_kx,kt))
        end
        if cfl_max>cfl_lim
            warningprint(fid_log,sprintf('ATTENTION!!! Max. CFL = %4.2f at kx = %d; kt= %d',cfl_max,c_max_kx,kt))
        end
        if input.mor.particle_activity==1 && any(kappa)~=0 && Pe_max>Pe_lim
            warningprint(fid_log,sprintf('ATTENTION!!! Max. Pe = %4.2f at kx = %d; kt= %d',Pe_max,Pe_max_kx,kt))
        end
    end
end %input.mdv.chk.flow==1

%% 
%% MASS
%%

if input.mdv.chk.mass==1
%check of the mass in terms of volume considering pores    
    
%previous domain mass
L_all_old=NaN(1,nx,nsl+1);
L_all_old(1,:,1      )=La_old;
L_all_old(1,:,2:nsl+1)=Ls_old;

m_dom_old=NaN(nf,nx,nsl+1); %active layer and substrate in one matrix
m_dom_old(1:nef,:,1    )=Mak_old;
m_dom_old(1:nef,:,2:end)=msk_old;
m_dom_old(nf   ,:,:    )=L_all_old-sum(m_dom_old(1:nef,:,:),1);

Mk_dom_old=sum(sum(m_dom_old,3),2)*dx; %mass in the domain per size fraction [m^2]; [1xnef double]

%current domain mass    
L_all_new=NaN(1,nx,nsl+1);
L_all_new(1,:,1      )=La;
L_all_new(1,:,2:nsl+1)=Ls;

m_dom_new=NaN(nf,nx,nsl+1); %active layer and substrate in one matrix
m_dom_new(1:nef,:,1    )=Mak;
m_dom_new(1:nef,:,2:end)=msk;
m_dom_new(nf   ,:,:    )=L_all_new-sum(m_dom_new(1:nef,:,:),1);

Mk_dom_new=sum(sum(m_dom_new,3),2)*dx; %mass in the domain per size fraction [m^2]; [1xnef double]

%entering mass
Mk_in=qbk0*dt/cb;

%exiting mass
Mk_out=qbk(:,end)*dt/cb;

%mass check
dMk=Mk_dom_old+Mk_in-Mk_out-Mk_dom_new; %mass variation per size fraction (should be 0)
dM=sum(dMk,1); %total mass variation (should be 0)

%relative mass
M_dom_old=sum(Mk_dom_old,1); %total mass in the domain
dM_rel=dM/M_dom_old; %relative total mass variation

% if dM>dM_lim
%     fprintf(fid_log,'ATTENTION!!! Variation in mass = %6.4e at kt= %d\n',dM,kt);
% end

if dM_rel>dM_lim
    warningprint(fid_log,sprintf('ATTENTION!!! Relative variation in mass = %6.4e at kt= %d',dM_rel,kt))
end

%end %input.mdv.chk.mass==1
  
%%
%% FRACTIONS
%%

F_all_new=m_dom_new./repmat(L_all_new,nf,1,1);
% F_all_new=m_dom_new/L_all_new; %double check!

if nf>1
    if any(any(any(F_all_new>1+F_lim | F_all_new<-F_lim)))
        warningprint(fid_log,sprintf('ATTENTION!!! Volume fraction problem at kt= %d',kt))
    end
end

end %input.mdv.chk.mass==1

%%
%% NaN
%%

if input.mdv.chk.nan==1
    
%any is faster than find, plot the results to see the problem :D
if any(isnan(h))
    idx_nan=find(isnan(h));
    nidx=numel(idx_nan);
    aux_str=repmat('%d, ',1,nidx);
    aux_str2=sprintf('There is a NaN in flow depth at kt=%s, kx=%s','%d',aux_str);
    warningprint(fid_log,sprintf(aux_str2,kt,idx_nan))
end
if any(isnan(u))
    idx_nan=find(isnan(u));
    nidx=numel(idx_nan);
    aux_str=repmat('%d, ',1,nidx);
    aux_str2=sprintf('There is a NaN in flow velocity at kt=%s, kx=%s','%d',aux_str);
    warningprint(fid_log,sprintf(aux_str2,kt,idx_nan))
end
if input.mdv.nf>1
    if any(isnan(Mak))
        idx_nan=find(isnan(Mak));
        [kf_nan,kx_nan]=ind2sub(size(Mak),idx_nan);
        nidx=numel(idx_nan);
        aux_str=repmat('%d, ',1,nidx);
        aux_str2=sprintf('There is a NaN mass in the active layer at kt=%s; kx=%s; kf=%s','%d',aux_str,aux_str);
        warningprint(fid_log,sprintf(aux_str2,kt,kx_nan,kf_nan))
    end
    if any(isnan(La))
        idx_nan=find(isnan(La));
        nidx=numel(idx_nan);
        aux_str=repmat('%d, ',1,nidx);
        aux_str2=sprintf('There is a NaN in active layer thickness at kt=%s, kx=%s','%d',aux_str);
        warningprint(fid_log,sprintf(aux_str2,kt,idx_nan))
    end
    if any(any(isnan(msk)))
        idx_nan=find(isnan(msk));
        [kf_nan,kx_nan,ksl_nan]=ind2sub(size(msk),idx_nan);
        nidx=numel(idx_nan);
        aux_str=repmat('%d, ',1,nidx);
        aux_str2=sprintf('There is a NaN in mass in the substrate at kt=%s; kx=%s; kf=%s; ksl=%s','%d',aux_str,aux_str,aux_str);
        warningprint(fid_log,sprintf(aux_str2,kt,kx_nan,kf_nan,ksl_nan))
    end
    if any(any(isnan(Ls)))
        idx_nan=find(isnan(Ls));
        [kf_nan,kx_nan,ksl_nan]=ind2sub(size(Ls),idx_nan);
        nidx=numel(idx_nan);
        aux_str=repmat('%d, ',1,nidx);
        aux_str2=sprintf('There is a NaN in substrate thickness at kt=%s; kx=%s; kf=%s; ksl=%s','%d',aux_str,aux_str,aux_str);
        warningprint(fid_log,sprintf(aux_str2,kt,kx_nan,kf_nan,ksl_nan))
    end
end

end %input.mdv.chk.nan==1


%%
%% ELLIPTICITY
%%

if input.mdv.chk.ell==1
    
if input.mdv.flowtype~=1 %in this case the pmm celerities have not been computed
    clb=u.*celerities.lb./beta; %dimensional bed celerity
    cls=repmat(u,nef,1).*celerities.ls./alpha./beta; %dimensional sorting celerity
end

%lb/ls
if input.mor.particle_activity==0
    if any(clb<0)
        idx_neg=find(clb<0);
        nidx=numel(idx_neg);
        aux_str=repmat('%d, ',1,nidx);
        aux_str2=sprintf('ATTENTION!!! Negative bed celerity at kt=%s, kx=%s','%d',aux_str);
        warningprint(fid_log,sprintf(aux_str2,kt,idx_neg))
    end
    if any(cls<0)
        idx_neg=find(cls<0);
        nidx=numel(idx_neg);
        aux_str=repmat('%d, ',1,nidx);
        aux_str2=sprintf('ATTENTION!!! Negative sorting celerity at kt=%s, kx=%s','%d',aux_str);
        warningprint(fid_log,sprintf(aux_str2,kt,idx_neg))
    end
end

end %input.mdv.chk.ell

%pmm
if input.mdv.chk.pmm==1
if any(pmm.alpha~=1) || any(pmm.beta~=1)
    max_alpha=max(pmm.alpha);
    min_alpha=min(pmm.alpha);
    max_beta=max(pmm.beta);
    min_beta=min(pmm.beta);

    fprintf(fid_log,'max alpha=%6.3f; max beta=%6.3f; min alpha=%6.3f; min beta=%6.3f\n',max_alpha,max_beta,min_alpha,min_beta);
end

end %input.mdv.chk.ell

end %function

