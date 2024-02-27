%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16707 $
%$Date: 2020-10-28 12:22:00 +0800 (Wed, 28 Oct 2020) $
%$Author: chavarri $
%$Id: flow_update.m 16707 2020-10-28 04:22:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/flow_update.m $
%
%flow_update updates the flow depth and the mean flow velocity.
%
%[u_new,h_new]=flow_update(u,h,etab,Cf,bc,input,fid_log,kt)
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
%160418
%   -L. bwc bug with qw=q_old
%
%160428
%   -L. Update hbc and Qbc cases
%       - Update case numbers
%       - Modulo construction for repeated time steps
%
%160513
%   -L. Implicit Preismann scheme
%
%
%160623
%   -V. cyclic boundary conditions
%
%160702
%   -V. tiny performance improvements
%
%160803
%	-L. Merged Vv4 Lv4
%
%160818
%   -L. Adjusted for variable flow.
%
%161130
%   -L. Geklooi met breedte_variaties
%
%170724
%   -Pepijn Addition of branches
%
%181104
%   -V. adapt boundary conditions to CFL time steping method

function [u_new,h_new,bc]=flow_update(u,h,etab,Cf,bc,input,fid_log,kt,time_l)

%%
%% RENAME
%%

nb=input(1,1).mdv.nb;
flowtype=input(1,1).mdv.flowtype;
bc_interp_type=input(1,1).mdv.bc_interp_type;

%%
%% ONE BRANCH
%%
if nb==1 %one branch

    %% RENAME

    %from cell array to matrix
    u=u{1,1};
    h=h{1,1};
    etab=etab{1,1};
    Cf=Cf{1,1};

    nx=input.mdv.nx; %number of cells
    B=input.grd.B;
    g=input.mdv.g;
    dx=input.grd.dx;
    
    %% BOUNDARY CONDITION

    %% upstream 

    switch input.bch.uptype
    %%water discharge    
        case {1,11,12,13,14,2}
            switch bc_interp_type
                case 1
                    Qbct = mod(kt,bc.repQT(2))+(mod(kt,bc.repQT(2))==0)*bc.repQT(2); 
                    qwup=bc.q0(Qbct); %[1x1 double]
                    Qwup=bc.Q0(Qbct); %[1x1 double]
                case 2
                    Qwup=interp1(input.bch.timeQ0,input.bch.Q0,time_l,'linear')'; %column vector
                    qwup=Qwup./input.grd.B(1,1);
            end
        otherwise
            error('The answer is 42, why do yo need to run a model? In any case, please provide a input.bch.uptype that is implemented.')
    end
    
    %% downstream

    switch input.bch.dotype
    %%water elevation    
        case {1,11,12,13,'set1'} 
            switch bc_interp_type
                case 1
                    hbct = mod(kt,bc.rephT(2))+(mod(kt,bc.rephT(2))==0)*bc.rephT(2);
                    Hdown=bc.etaw0(hbct)-3/2*etab(nx)+1/2*etab(nx-1); %water depth at the downsteam end [1x1 double]
                case 2
                    etaw0=interp1(input.bch.timeetaw0,input.bch.etaw0,time_l,'linear')'; %column vector
                    Hdown=etaw0-3/2*etab(nx)+1/2*etab(nx-1); %water depth at the downsteam end [1x1 double]
            end
    %%water depth   
        case {2,21,22,23} 
            error('not yet implemented')
    %%normal flow depth 
        case {3}
            Hdown = ((Cf(1,nx)*(qwup.*B(1)/B(end))^2)/(g*(etab(nx-1)-etab(nx))/dx))^(1/3); %normal flow depth at the downstream end [1x1 double]    
        otherwise
            error('The magic downstream boundary condition is not yet implemented. Please provide a input.bch.dotype that is implemented.')
    end

    %% UPDATE
    switch flowtype
        case 0 % constant
            u_new{1,1}=u;
            h_new{1,1}=h;
        case 1 % steady
            switch input.mdv.steady_solver
                case 1
                    [u_new{1,1},h_new{1,1}]=flow_steady_energy_euler(qwup,Hdown,Cf,etab,input);
                case 2
                    [u_new{1,1},h_new{1,1}]=flow_steady_energy_RK4(qwup,Hdown,Cf,etab,input);
                case 3
                    [u_new{1,1},h_new{1,1}]=flow_steady_depth_euler(qwup,Hdown,Cf,etab,input);
                case 4
                    [u_new{1,1},h_new{1,1}]=flow_steady_depth_RK4(qwup,Hdown,Cf,etab,input);
            end
        case {2,4} % quasi-steady or unsteady-implicit
            [u_new{1,1},h_new{1,1}]=preissmann(u,h,etab,Cf,Hdown,qwup,input,fid_log,kt);
        case 3 % unsteady-explicit
            [u_new{1,1},h_new{1,1}]=flow_unsteady_explicit(u,h,etab,Cf,Hdown,qwup,input,fid_log,kt);            
        case 5 % already taken for space marching
            
        case 6 % Backwater solver;
             bedslope = [NaN, -(etab(2:end)-etab(1:end-1))/dx];
            if input.grd.crt==1
                [U,H] = backwater_rect(bedslope,Cf,Hdown,Qwup,input);
            else
                [U,H] = backwater(bedslope,Cf,Hdown,Qwup,input);
            end
            u_new{1,1}=U';
            h_new{1,1}=H';
        otherwise
            error('We have not yet implemented the super flow solver that reads your mind to know how to solve the flow. Please provide a flowtype solver.')
    end

%%
%% SEVERAL BRANCHES
%%

else %more than one branch
    Qbct = mod(kt,bc.repQT(2))+(mod(kt,bc.repQT(2))==0)*bc.repQT(2); 
    hbct = mod(kt,bc.rephT(2))+(mod(kt,bc.rephT(2))==0)*bc.rephT(2);
    switch flowtype
        case 1
            Q=zeros(nb,1);
            etaw0=zeros(nb,1);
            [u_new,h_new,Q,etaw0]=flow_update_branches(u,h,Q,etaw0,etab,Cf,bc,Qbct,hbct,input,1,fid_log);
            for kb=1:nb
                bc(kb,1).Q0(Qbct,1)=Q(kb,1);
                bc(kb,1).q0(Qbct,1)=Q(kb,1)/input(kb,1).grd.B(1);
                bc(kb,1).etaw0(hbct,1)=etaw0(kb,1);
            end
        otherwise
            error('We have not yet implemented the super flow solver for bifurcations that reads your mind to know how to solve the flow. Please provide a flowtype solver.')
    end
end



