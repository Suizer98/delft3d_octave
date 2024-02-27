%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: active_layer_mass_update.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/active_layer_mass_update.m $
%
%active_layer_mass_update updates the mass (volume) of sediment at the active layer.
%
%\texttt{Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,bc,input,fid_log,kt)}
%
%INPUT:
%   -\texttt{Mak} = effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%   -\texttt{detaLa} = variation in elevation of the interface between the active layer and the substarte [m]; [(1)x(nx) double]
%   -\texttt{fIk} = effective volume fraction content of sediment at the interface between the active layer and the substrate [-]; [(nf-1)x(nx) double]
%   -\texttt{qbk} = volume of sediment transported excluding pores per unit time and width and per size fraction [m^2/s]; [(nf)x(nx) double]
%   -\texttt{bc} = boundary conditions structure 
%   -\texttt{input} = input structure
%   -\texttt{fid_log} = identificator of the log file
%   -\texttt{kt} = time step counter [-]; [(1)x(1) double]
%
%OUTPUT:
%   -\texttt{Mak_new} = new effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160429
%   -V. Periodic boundary conditions.
%
%160623
%   -V. Cyclic boundary conditions.
%
%160825
%   -L. Repeated hydrograph - no version update
%
%170517
%   -V. Removed upwind factor.
%
%181104
%   -V. Add possibility of CFL based time step
%   -V. Add pmm to general update

function Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,Dk,Ek,bc,input,~,kt,time_l,pmm)

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
nef=input.mdv.nef;
nf=input.mdv.nf; 
cb=1-input.mor.porosity;
nx=input.mdv.nx; 
UpwFac=input.mdv.UpwFac;
bc_interp_type=input.mdv.bc_interp_type;
B=input.grd.B;
alpha=pmm(1,:);
beta=pmm(2,:);

%%
%% ACTIVE LAYER EQUATION
%%

detaLa_dt=detaLa/dt; %%d(\eta-La)/dt [1xnx double]

%% FLUX FORM
if input.mor.particle_activity==0
    
%% boundary condition

switch bc_interp_type
    case 1 %interpolate at the beggining
        switch input.bcm.type
            case {1,3,11,12,13,14,'set1'}
                Qbkt = mod(kt,bc.repQbkT(2))+(mod(kt,bc.repQbkT(2))==0)*bc.repQbkT(2);
                Qbk0=B(1)*bc.qbk0(Qbkt,:)'; %total load [m^3/s]; [1xnf double]
            case 2
                Qbk0=B(end)*qbk(:,end);
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
            case 2
                Qbk0=B(end)*qbk(:,end);
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
end %bc_interp_type

%% update
    
Qbk=repmat(B,nef+1,1).*qbk; %[1xnf double]

Mak_new(:,1     )=Mak(:,1     )-       dt /(alpha(1,1     ).*beta(1,1     ))        *(       beta(1,1     )        *fIk(:,1     ).*       detaLa_dt(1,1            )+MorFac/cb*(       (Qbk(1:nef,1     )-Qbk0(1:nef,1     ))/(dx/2))./B(2));
Mak_new(:,2:nx-1)=Mak(:,2:nx-1)-repmat(dt./(alpha(1,2:nx-1).*beta(1,2:nx-1)),nef,1).*(repmat(beta(1,2:nx-1),nef,1).*fIk(:,2:nx-1).*repmat(detaLa_dt(1,2:nx-1),nef,1)+MorFac/cb*(UpwFac*(Qbk(1:nef,2:nx-1)-Qbk (1:nef,1:nx-2))/dx+(1-UpwFac)*(Qbk(1:nef,3:nx)-Qbk(1:nef,2:nx-1))/dx)./(repmat(B(3:nx),nef,1)));
Mak_new(:,nx    )=Mak(:,nx    )-       dt /(alpha(1,nx    ).*beta(1,nx    ))        *(       beta(1,nx    )        *fIk(:,nx    ).*       detaLa_dt(1,nx    )       +MorFac/cb*(       (Qbk(1:nef,nx    )-Qbk (1:nef,nx-1  ))/dx)./B(nx));

%% ENTRAINEMNT DEPOSITION FORM
else

Mak_new=Mak+dt*(-fIk.*detaLa_dt+MorFac/cb*(Dk(1:nef,:)-Ek(1:nef,:))); %will not work if version<R2016b

end %input.mor.particle_activity

end %function
