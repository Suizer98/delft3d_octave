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
%$Id: particle_activity_update.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/particle_activity_update.m $
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
%171002
%   -V. Created it for the first time

function Gammak=particle_activity_update(Gammak,u,h,etab,Mak,La,Cf,Cf_b,vpk,Ek_g,Dk_g,Gammak_eq,bc,input,~,kt,time_l)

if input.mor.particle_activity==1
%%
%% RENAME
%%

dx=input.grd.dx;
nf=input.mdv.nf;
dd=input.mdv.dd;
kappa=input.tra.kappa;
g=input.mdv.g;
bc_interp_type=input.mdv.bc_interp_type;
B0=input.grd.B(1,1);

%% 
%% BOUNDARY CONDITION
%%

switch bc_interp_type
    case 1
        %% interpolation of the bondary condition before starting the time loop
            %% upstream
Gammakt_u = mod(kt,bc.repGammakT_u(2))+(mod(kt,bc.repGammakT_u(2))==0)*bc.repGammakT_u(2);
switch input.bcm.pa_u
    case 1 %Dirichlet
        if input.bcm.type~=2 
            switch input.bcm.pa_u_Dirichlet_type
                case 1 %specifying Gammak
                    Gammak(:,1)=bc.Gammak0(Gammakt_u,:)'; 
                case 2 %specifying qbk
                    Gammak(:,1)=bc.qbk0(Gammakt_u,:)./vpk(:,1)'; 
            end
        else %cyclic boundary conditions
            Gammak(:,1)=Gammak(:,end);
        end
        g_u=NaN(2,nf);
        h_u=NaN(2,nf);
    case 2 %Neumann
        error('not done yet')
    case 3 %Robin
        %(1,:)=time t all fractions, (2,:)=time t+1 all fractions
        switch input.bcm.type
            case 1 %qbk(t) as BC
                g_u=bc.g_u(Gammakt_u:Gammakt_u+1,:);
            case 2 %cyclic qbk(t)
                g_u=-repmat(vpk(:,end).*Gammak_eq(:,end),1,2)'; %this is not correct. I should use qbk=vpk*Gammak-kappa*dGammak/dx
        end
        h_u=repmat(vpk(:,1),1,2)'; %ATTENTION! we are using the advection velocity (vpk) at time t for both t and t+1
end

            %% downstream
Gammakt_d = mod(kt,bc.repGammakT_d(2))+(mod(kt,bc.repGammakT_d(2))==0)*bc.repGammakT_d(2);
switch input.bcm.pa_d
    case 0 %if not necessary because kappa=0
        g_d=NaN(2,nf);
        h_d=NaN(2,nf);
    case 1 %Dirichlet
        switch input.bcm.pa_d_Dirichlet_type
            case 1
                Gammak(:,end)=bc.GammakL(Gammakt_d,:)'; %[1xnf double]
            case 2
                Gammak(:,1)=bc.qbkL(Gammakt_u,:)./vpk(:,end)'; 
            case 3
                Gammak(:,end)=Gammak_eq(:,end);             
        end
        g_d=NaN(2,nf);
        h_d=NaN(2,nf);
    case 2 %Neumann
        error('not done yet')
    case 3 %Robin
        %(1,:)=time t all fractions, (2,:)=time t+1 all fractions
        if isnan(input.bcm.QbkL) %flux as if small gradient in Gamma
            g_d=-repmat(vpk(:,end).*Gammak_eq(:,end),1,2)';
        else %imposed value
            g_d=bc.g_d(Gammakt_d:Gammakt_d+1,:);
        end
        h_d=repmat(vpk(:,1),1,2)'; %ATTENTION! we are using the advection velocity (vpk) at time t for both t and t+1
end

    case 2
        %% interpoaltion of the boundary condition at this point
            %% upstream
switch input.bcm.pa_u
    case 1 %Dirichlet
        if input.bcm.type~=2 
            switch input.bcm.pa_u_Dirichlet_type
                case 1 %specifying Gammak
                    Gammak0=NaN(1,nf);
                    for kf=1:nf
                        Gammak0(1,kf)=interp1(input.bcm.timeGammak0,input.bcm.Gammak0(:,kf),time_l,'linear')'; 
                    end
                    Gammak(:,1)=Gammak0'./B0;
                case 2 %specifying qbk
                    Qbk0=NaN(1,nf);
                    for kf=1:nf
                        Qbk0(1,kf)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time_l,'linear')'; 
                    end
                    qbk0=Qbk0./B0;
                    Gammak(:,1)=qbk0(1,:)./vpk(:,1)';       
            end
        else %cyclic boundary conditions
            Gammak(:,1)=Gammak(:,end);
        end
        g_u=NaN(2,nf);
        h_u=NaN(2,nf);
    case 2 %Neumann
        error('not done yet')
    case 3 %Robin
        %(1,:)=time t all fractions, (2,:)=time t+1 all fractions
        switch input.bcm.type
            case 1 %qbk(t) as BC
                Qbk0=NaN(1,nf);
                for kf=1:nf
                    Qbk0(1,kf)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time_l,'linear')'; 
                end
                qbk0=Qbk0./B0;
                g_u=-[qbk0;qbk0(end,:)]; %we need 2 values since the future condition is needed for Robin
            case 2 %cyclic qbk(t)
                g_u=-repmat(vpk(:,end).*Gammak_eq(:,end),1,2)'; %this is not correct. I should use qbk=vpk*Gammak-kappa*dGammak/dx
        end
        h_u=repmat(vpk(:,1),1,2)'; %ATTENTION! we are using the advection velocity (vpk) at time t for both t and t+1
end

            %% downstream
switch input.bcm.pa_d
    case 0 %if not necessary because kappa=0
        g_d=NaN(2,nf);
        h_d=NaN(2,nf);
    case 1 %Dirichlet
        switch input.bcm.pa_d_Dirichlet_type
            case 1
                GammakL=NaN(1,nf);
                for kf=1:nf
                    GammakL(1,kf)=interp1(input.bcm.timeGammakL,input.bcm.GammakL(:,kf),time_l,'linear')'; 
                end
                Gammak(:,end)=GammakL./B0';
            case 2
                QbkL=NaN(1,nf);
                for kf=1:nf
                    QbkL(1,kf)=interp1(input.bcm.timeQbkL,input.bcm.QbkL(:,kf),time_l,'linear')'; 
                end
                qbkL=QbkL./B0;
                Gammak(:,1)=qbkL(1,:)./vpk(:,end)'; 
            case 3
                Gammak(:,end)=Gammak_eq(:,end);             
        end
        g_d=NaN(2,nf);
        h_d=NaN(2,nf);
    case 2 %Neumann
        error('not done yet')
    case 3 %Robin
        %(1,:)=time t all fractions, (2,:)=time t+1 all fractions
        if isnan(input.bcm.QbkL) %flux as if small gradient in Gamma
            g_d=-repmat(vpk(:,end).*Gammak_eq(:,end),1,2)';
        else %imposed value
            QbkL=NaN(1,nf);
            for kf=1:nf
                QbkL(1,kf)=interp1(input.bcm.timeQbkL,input.bcm.QbkL(:,kf),time_l,'linear')'; 
            end
            qbkL=QbkL./B0;
            g_d=-[qbkL;qbkL(end,:)]; %we need nT+1 values since the future condition is needed for Robin
        end
        h_d=repmat(vpk(:,1),1,2)'; %ATTENTION! we are using the advection velocity (vpk) at time t for both t and t+1
end %input.bcm.pa_d  
end %bc_interp_type


%%
%% CALC
%%

%% PARAMETERS
[~,~,~,~,~,~,~,~,~,~,~,~,~,~,vpk_hdh,~,~]=sediment_transport(input.aux.flg,input.aux.cnt,h'+dd,(u.*h)',Cf_b',La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,input.tra.E_param,input.tra.vp_param,Gammak',NaN,NaN);
dvpk_dh=(vpk_hdh'-vpk)./dd; %[nf,nx]
Fr2=u.^2./g./h; %[1,nx]
Sf=Cf.*Fr2; %[1,nx] 
%first order
% slope=diff(etab)/dx; 
% slope=[slope,slope(end)]; %[1,nx] %copy last value to have same size. should be negative.
%second order
slope=[etab(2)-etab(1),(etab(3:end)-etab(1:end-2))/2,etab(end)-etab(end-1)]./dx; %[1,nx] should be negative.
Mak=[Mak;La-sum(Mak,1)]; %[nf,nx] %add last volume
S1=Mak.*Ek_g; %[nf,nx]
S2=dvpk_dh./(1-repmat(Fr2,nf,1)).*repmat((slope+Sf),nf,1)-Dk_g; %[nf,nx]

%% SOLVE ADV-DIFF

%test no source term
% S1=zeros(size(S1));
% S2=zeros(size(S2));

%test no dependence on slope
% S2=-Dk_g;

%test stability
% for kf=1:nf
%     h_num=(vpk(kf,:)*1i*pi./dx+S2(kf,:))*input.mdt.dt;
%     
%     %theta=1 (BTCS)
%     if abs(1/(1-h_num))>1
%         error('unstable')
%     end
% end

for kf=1:nf
    if kappa(kf)==0
        Gammak(kf,:)=FTBS(Gammak(kf,:),vpk(kf,:),S1(kf,:),S2(kf,:),input);
    else 
        switch input.mdv.ade_solver
            case 1
                Gammak(kf,:)=theta_method(Gammak(kf,:),vpk(kf,:),kappa(kf),S1(kf,:),S2(kf,:),g_u(:,kf)',h_u(:,kf)',g_d(:,kf)',h_d(:,kf)',input);
            case 2
                Gammak(kf,:)=theta_method_advBS_diffCS(Gammak(kf,:),vpk(kf,:),kappa(kf),S1(kf,:),S2(kf,:),g_u(:,kf)',h_u(:,kf)',g_d(:,kf)',h_d(:,kf)',input);
        end
    end
end %nf


end %input.mor.particle_activity==1












