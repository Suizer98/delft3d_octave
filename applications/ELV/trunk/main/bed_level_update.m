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
%$Id: bed_level_update.m 17214 2021-04-28 16:05:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_level_update.m $
%
%bed_level_update updates the bed elevation
%
%etab_new=bed_level_update(etab,qbk,bc,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160429
%   -V. Introduction of periodic boundary conditions
%
%160623
%   -V. Cyclic boundary conditions.
%
%160803
%	-L. Merging; including cycled boundary conditions
%
%170126
%   -L. Added cases 13,14 (no new version)
%
%170516
%   -V. Erased upwind factor
%
%171005
%   -V. Added entrianment deposition formulation
%   -V. Add pmm to general update
%
%200715
%   -V. Solved bug with unsteady flow and mixed-size sediment
%
%201102
%   -V. Restructuring

function etab_new=bed_level_update(etab,qbk,Dk,Ek,bc,input,fid_log,kt,time_l,pmm,celerities,u,u_edg,qbk_edg,pmm_edg,celerities_edg)

%%
%% RENAME
%%

% dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
cb=1-input.mor.porosity;
% nx=input.mdv.nx; %number of cells
nf=input.mdv.nf; 
% UpwFac=input.mdv.UpwFac;
bc_interp_type=input.mdv.bc_interp_type;
B=input.grd.B;
B_edg=input.grd.B_edg;
beta=pmm(2,:); 
beta_edg=pmm_edg(2,:);

%%
%% EXNER
%%

%% FLUX FORM
if input.mor.particle_activity==0
    
%% boundary condition

%%upstream bed load
switch bc_interp_type
    case 1 %interpolate at the beggining
        switch input.bcm.type
            case {1,3,11,12,13,14,'set1'}
                Qbkt = mod(kt,bc.repQbkT(2))+(mod(kt,bc.repQbkT(2))==0)*bc.repQbkT(2);
                Qbk0=B(1)*bc.qbk0(Qbkt,:); %total load [m^3/s]; [1xnf double]
                Qb0=sum(Qbk0,2); %[1x1 double]
            case 2
                Qbk0=B(end)*qbk(:,end);
                Qb0=sum(Qbk0,1); %[1x1 double]       
            case 4
                Qb0=NaN;%nothing to do
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
    case 2 %interpolate here
        switch input.bcm.type
            case 1
                Qbk0=NaN(nf,1);
                for kf=1:nf
                    Qbk0(kf,1)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time_l,'linear'); 
                end
                Qb0=sum(Qbk0,1); %total load [m^3/s]; [1x1 double] 
            case 2
                Qbk0=B(end)*qbk(:,end);
                Qb0=sum(Qbk0,1); %[1x1 double]   
            case 4
                Qb0=NaN;%nothing to do
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
end %bc_interp_type

%% update

%total load
Qb=B.*sum(qbk,1); %[1,nx] double
Qb_edg=B_edg.*sum(qbk_edg,1); 

%upwind factor
UpwFac_loc = 1-(Qb<0); %sets the UpwFac to 1 if flow comes from left, and to 0 if flow comes from right [1,nx] double
if any(~UpwFac_loc)
    input.mor.scheme=0;
    warningprint(fid_log,'At some location flow is reversed and I can only compute morphodynamic update with FTBS, implementation is needed...')
end

switch input.mor.bedupdate
    case 0
        etab_new=etab;
    case 1
        switch input.mor.scheme
            case 0
                etab_new=bed_FTBS(input,etab,Qb0,Qb,beta);
            otherwise
                etab_new=bed_level_update_combined(input,etab,Qb0,Qb,beta,celerities,u,u_edg,Qb_edg,celerities_edg,beta_edg);
        end
        
    otherwise
       error(':( I thought you wanted to use Exner... :(')
        
end


%% ENTRAINMENT DEPOSITION FORM
else
    
switch input.mor.bedupdate
    case 0
        etab_new=etab;
    case 1
        D=sum(Dk,1); %[(1)x(nx)]
        E=sum(Ek,1); %[(1)x(nx)]
        etab_new=etab+MorFac*dt/cb*(D-E); %[(1)x(nx)]
    otherwise
       error(':( I thought you wanted to use Exner... :(')
end %input.mor.bedupdate

end %input.mor.particle_activity

%% CHECK

%this happens in the first time step when the flux depends on the
%celerities
if any(isnan(etab_new))
    if time_l<=input(1,1).mdv.Tstop+dt
        etab_new=etab;
    end
end

end %function