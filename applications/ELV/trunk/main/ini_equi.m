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
%$Id: ini_equi.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/ini_equi.m $
%
%ini_spacem approximates the alternating steady equilibrium profile using the space marching algorithm
%
%[u,h,etab,qb,Fak] = ini_spacem(input,fid_log,bc)
%
%INPUT:
%   -input: general ELV input file;
%       input.ini.initype:  12 alternating steady, return mean condition
%                           13 alternating steady + time reconstrcution,
%                           return first condition
%                           14 do not use in combination with ELV
%       input.ini.initype:  5- space marching model + time reconstruction,
%                           return the first condition as initial condition
%                           51=12 - space marching, return mean condition
%                           52 = 5 =13
%                           53 = 15 =parstudy settings, loading, (dq,pq) from
%                           file
%                           
%   -fid_log: variable for log-file, may be empty
%   -bc: struct consisting of the boundary conditions
%           -bc.q0
%           -bc.qbk
%           -bc.etaw0
%
%OUTPUT:
%   -
%
%HISTORY:
%170727
%   -L. Created for the first time; modulization of ini_spacem and consistency checks for good! 

function [u,h,etab,qb,Fak] = ini_equi(input,fid_log,bc)

%% INITIALIZATION
input.ini.sp.options=optimoptions('fsolve','Algorithm','levenberg-marquardt','TolFun',1e-12,'TolX',1e-12,'display','off','MaxFunEvals',1000);
switch input.ini.initype 
    case 14
        input=check_ini(input,fid_log);
    otherwise
        % input check has been performed in ELV already; remove after merging # L 20170727 
        input=check_ini(input,fid_log);
end

% Bend cut-off/narrowing/widening
input = do_engineering(input);

% Get grid

[xgrid, dxi, ratio] = get_grid(input);

% Get width
[B, Bi, dBdxi] = get_width(input,xgrid,dxi);

% Rename constants
[c_f,g,~,nx,xstore,~,~,~,nf] = rename_constants(input);

% Define hydrodynamic modes
[dq,dH,pq,K,~,ic,qw,H,dT]  = get_hydrodynamic_modes(input,bc);

% Get solver type
solver_type = get_solver_type(input,K);

% Uptstream BCS - Average load
AL = get_average_load(input,bc);

% Downstream BCS
[eta_new,H_new,Fak_new] = get_downstream_condition(input,solver_type,pq,dq,dH,AL,B,Bi);

%% EQUILIBRIUM SOLVER
switch solver_type        
    case {0,1}
        % Preallocation variables for storage
        Ks = numel(qw);
        Hs = zeros(Ks,nx);
        switch input.ini.initype % prepare the vector to allow for a dynamic correction if type is 5 
            case {5,13,52}
                eta_s = zeros(Ks,nx);       
            otherwise
                eta_s = zeros(1,nx);
        end
        k = 0;

        Cf = input.frc.Cf(1,1).*ones(1,K); 
        if nf>1
            La = input.mor.La.*ones(1,K);
            Fak_s = zeros(Ks,nx,nf-1);

        else
            La = NaN * ones(1,K);
            Mak = NaN * ones(1,K);
        end

        % Prepare initial guess
        ib_new = 1e-3;
        dFak_new = zeros(nf-1,1);
        X0 = [ib_new; dFak_new];


        % Marching loop
        for j = 1:(nx*ratio)
            xloc = input.grd.L - (j-1)*dxi;
            eta_old = eta_new;
            H_old = H_new;

            Fak_old = Fak_new;
            Mak = input.mor.La.*Fak_old;


            % Do a marching step;
            switch nf
                case 1
                    switch input.mdv.flowtype
                        case 6
                             [H_new, eta_new] = march_step_dBdx(H_old,eta_old,dq,pq,input,dxi,j,Cf,La,Mak,AL,Bi(1),Bi(end-j+1),dBdxi(end-j+1)); 
                        otherwise
                             [H_new, eta_new] = march_step_uni(H_old,eta_old,dq,pq,input,dxi,j,Cf,La,Mak,AL);  
                    end
                otherwise
                    switch input.mdv.flowtype
                        case 6
                             [H_new, eta_new, Fak_new, ib_new, dFak_new]  = march_step_dBdx_mixed(H_old,eta_old,Fak_old,dq,pq,input,dxi,j,Cf,La,Mak,AL,Bi(1),Bi(end-j+1),dBdxi(end-j+1),X0); 
                        otherwise
                             [H_new, eta_new, Fak_new, ib_new, dFak_new]  = march_step_mixed(H_old,eta_old,Fak_old,dq,pq,input,dxi,j,Cf,La,Mak,AL,X0);  
                    end                              
                    X0 = [ib_new; dFak_new];            
            end



            % Store results if required
            if sum(xloc==xstore)==1 %store on outer grid cells
                k = k+1;
                disp(strcat('Space-marching step:',num2str(k),'/',num2str(numel(xstore))));
                Hs(:,k) = H_new(ic);

                switch input.ini.initype
                    case {5,13,52}
                        %compute the gradient in sediment transport
                        switch input.mdv.flowtype
                            case 6
                                Qb_down = Bi(end-j+1)*sediment_transport(input.aux.flg,input.aux.cnt,H_old-eta_old,dq*Bi(1)/Bi(end-j+1),Cf,La,repmat(Mak,K,1),input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
                                Qb_up = Bi(end-j)*sediment_transport(input.aux.flg,input.aux.cnt,H_new-eta_new,dq*Bi(1)/Bi(end-j),Cf,La,repmat(input.mor.La.*Fak_new,K,1),input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);   
                                diff = (AL*Bi(1)- sum(repmat(pq,1,nf).*Qb_up,1))/(AL*Bi(1));
                                [eta_dyn, Fak_dyn] = active_reconstruction_mean(Qb_down,Qb_up,eta_new,Fak_new,input,dxi,dT,Bi(end-j+1),ic);
                                if abs(diff) > 0.001
                                    warning('more than 0.1% of mass lost');
                                    disp(diff);
                                end
                            otherwise 
                                %Check if width will change:
                                xloc1 = input.grd.L - (j-1)*dxi;
                                xind1 = round((xloc1+input.grd.dx/2)/input.grd.dx)+1;
                                xloc2 = input.grd.L - (j)*dxi;
                                xind2 = round((xloc2+input.grd.dx/2)/input.grd.dx)+1;
                                Qb_down = B(xind1)*sediment_transport(input.aux.flg,input.aux.cnt,H_old-eta_old,dq*B(1)/B(xind1),Cf,La,repmat(Mak,K,1),input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
                                Qb_up = B(xind2)*sediment_transport(input.aux.flg,input.aux.cnt,H_new-eta_new,dq*B(1)/B(xind2),Cf,La,repmat(Mak,K,1),input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
                                diff = (AL*B(1)- sum(repmat(pq,1,nf).*Qb_up,1))/(AL*B(1));
                                if abs(diff) > 0.001
                                    warning('more than 0.1% of mass lost');
                                    disp(diff)
                                end

                                %if B(xind1)==B(xind2) %NO
                                    [eta_dyn, Fak_dyn] = active_reconstruction_mean(Qb_down,Qb_up,eta_new,Fak_new,input,dxi,dT,B(xind1),ic);
                                %else %YES, but abrupt
                                %    eta_dyn = eta_new*ones(Ks+1,1);
                                %    if nf>1
                                %        Fak_dyn = Fak_new*ones(Ks+1,nf-1);
                                %    else 
                                %        Fak_dyn = [];
                                %    end
                                %end
                        end

                        eta_s(:,k) = eta_dyn(1:end-1);
                        Fak_s(:,k,:) = Fak_dyn(1:end-1,:);
                    otherwise
                        eta_s(:,k) = eta_new;
                        Fak_s(:,k) = Fak_new;
                end
                end
        end
end
    

%% Postprocessing 
% Engineering meaures
if isfield(input.grd,'L_cut')
    ind_up = round(input.grd.loc_cut./input.grd.dx)+1;
    ind_down = numel(xstore) - (ind_up-1);
    Hs(:,ind_up:ind_down) = [];
    eta_s(:,ind_up:ind_down) = [];
end

% Storage
switch input.ini.initype  
    case {5,52,13}
        % Select first realization
        h = Hs(1,:)-eta_s(1,:);
        u = dq(1)./h;
               
        % Prepare output
        h = fliplr(h);
        eta_s = fliplr(eta_s);
        etab = eta_s(1,:);
        u = fliplr(u);
        Fak_s = fliplr(Fak_s);
        Fak = NaN;
        if nf>1
            Fak = Fak_s(1,:);
            Fak =squeeze(Fak)';
        end
        qb = NaN;
        save(fullfile(input.mdv.path_folder_results,'output_sp.mat'),'-v6');
    case {51,12}
                % Select first realization
        h = Hs(1,:)-eta_s(1,:);
        u = dq(1)./h;
               
        % Prepare output
        h = fliplr(h);
        eta_s = fliplr(eta_s);
        etab = mean(eta_s,1);
        u = fliplr(u);
        Fak_s = fliplr(Fak_s);
        Fak = mean(Fak_s,1);
        if nf>2
            Fak =squeeze(Fak)';
        end
        qb = NaN;
        save(fullfile(input.mdv.path_folder_results,'output_sp.mat'),'-v6');
      
        
end
end






function AL = get_average_load(input,bc)
    try %if an explicit average load is specified.
        AL = input.ini.sp.AL/input.grd.B(1,1);
    catch
        try %if an upstream morphodynamic boundary condtion is loaded.
            AL = mean(bc.qbk0);   % [m2/s]
        catch
            error('Either specify annual load or sedigraph');
        end
    end
end


function [eta_new,H_new,Fak_new] = get_downstream_condition(input,solver_type,pq,dq,dH,AL,B,Bi)
    [c_f,g,~,~,~,R,por,dk,nf] = rename_constants(input);
   
    switch solver_type
        case 0 % Static equilibrium                   
                    iguess = [1e-2, 0.5*(AL./sum(AL))];
                    iguess = iguess(1:end-1);
                    [slope, Fak_new] = get_equivals_pdf(pq',dq*input.grd.B(1,1),input,sum(AL)*input.grd.B(1,1),AL'./sum(AL),iguess);
                    
                    h_new =  ((c_f*(dq*B(1)/B(end)).^2)/(g*slope)).^(1/3);
                    Fak_new = Fak_new(1:end-1); 
            
                    if isfield(input.bch,'etaw0')
                        eta_new = input.bch.etaw0(1,1) - h_new;
                        H_new = input.bch.etaw0(1,1);
                    else
                        eta_new = 0;
                        H_new = h_new;
                    end
            
        case 1 % Dynamic equilibrium
            switch input.bch.dotype
                case 3 %Normal flow downstream --> dominant discharge solution for slope
                    iguess = [1e-2, 0.5*(AL./sum(AL))];
                    iguess = iguess(1:end-1);
                    [slope, Fak_new] = get_equivals_pdf(pq',dq*input.grd.B(1,1),input,sum(AL)*input.grd.B(1,1),AL'./sum(AL),iguess);
                    
                    eta_new = 0;
                    H_new =  ((c_f*(dq*B(1)/B(end)).^2)/(g*slope)).^(1/3);
                    Fak_new = Fak_new(1:end-1); 
                                        
                otherwise
                    
                    % Compute EH values for unisize; either as solution or as initial guess
                    if input.tra.cr == 2
                        m_eh = input.tra.param(1);
                        n = input.tra.param(2);
                    else %use default values (it is just for the initial guess)
                        m_eh = 0.05;
                        n = 5;
                    end
                    m = m_eh*c_f.^(3/2)/g^2/R^2/(1-por)/mean(dk);
                    Hdown = sum(m*pq.*(dq*B(1)/B(end)).^n/(sum(AL)*B(1)/B(end))).^(1/n);

                    X = min(dH)-Hdown; %initial guess flow depth                    
                    pqbk = AL/sum(AL);
                    X(2:nf) = pqbk(1:end-1);
                    
                    % Compute actual boundary condition
                    switch input.mdv.flowtype
                        case 6
                            F = @(X)solve_equibed(X,dH,input,(dq*Bi(1)/Bi(end)),pq,AL*Bi(1)/Bi(end));
                        otherwise
                            F = @(X)solve_equibed(X,dH,input,(dq*B(1)/B(end)),pq,AL*B(1)/B(end));
                    end
                    if nf>1
                        options=optimoptions('fsolve','TolFun',1e-20,'TolX',1e-20,'display','none','MaxFunEvals',1000);
                        [X_s,~,~,~]=fsolve(F,X,options);
                        eta_new = X_s(1);
                        Fak_new = X_s(2:end);
                    else
                        eta_new = fzero(F,X);
                        Fak_new = [];
                    end
                    H_new = dH;
            end
    end
end
                                        



function solver_type = get_solver_type(input,K)
    % STATIC/DYNAMIC EQUILIBRIUM
    solver_type = 1; %default solver type is dynamic equilibrium

    if isfield(input.ini,'sp')
        if isfield(input.ini.sp,'type')
            solver_type = input.ini.sp.type;
        end
    end

    % Change to static equilibrium solver when the equilibrium is static;
    if K==1
        solver_type = 0;
    end
end


function [B, Bi, dBdxi] = get_width(input,xgrid,dxi)   
    switch input.mdv.flowtype
        case 6 %for flowtype 6 we will account for dBdx; for the others we do not. However, we take the width as on the outer solution grid.
            B = input.grd.B(1,:);
            if length(B) == 1
                B = B*ones(nx+2,1);
                Bi = NaN;
                dBdxi = NaN;
            else            
                B = [B(1), B, B(end)];
                xstore = (input.grd.dx/2):input.grd.dx:(input.grd.L-input.grd.dx/2);
                xval = [0, xstore, input.grd.L];
                Bi = interp1(xval,B,xgrid);       
                dBdxi = [0,(Bi(2:end)-Bi(1:end-1))/dxi];
            end
        otherwise
            % Make the width vector one longer to avoid issues with dBdx; the width at
            % the upstream end is doubled.
            B = input.grd.B(1,:);
            if length(B) == 1
                B = B*ones(input.mdv.nx+1,1);
            else
                B = [B(1), B];
            end
            Bi = NaN;
            dBdxi = NaN;
        end
end

function input = do_engineering(input)
    % Bend cut-off
    if isfield(input.grd,'L_cut')
        disp('Case of bend cut-off');
        fprintf(fid_log,'Case of bend cut-off');
        input.grd.L = input.grd.L +input.grd.L_cut;
    end
    
    % Channel narrowing/widening
    if isfield(input.grd,'B_old')
        disp('Case of channel narrowing or widening');
        fprintf(fid_log,'Case of channel narrowing or widening');
        input.grd.B = input.grd.B_old;
    end
end

function [xgrid, dxi, ratio] = get_grid(input)
    % Define an internal dx
    try
        dxi = input.ini.sp.dx;
    catch   
        dxi = 1;
    end
    ratio = input.grd.dx/dxi;
    xgrid = 0:dxi:input.grd.L;
end



function [c_f,g,dx,nx,xstore,R,por,dk,nf] = rename_constants(input)
    c_f = input.frc.Cf(1,1);
    g = input.mdv.g;
    dx = input.grd.dx;
    nx = input.mdv.nx;
    xstore = (dx/2):dx:(input.grd.L-dx/2);
    R = input.aux.cnt.R;
    por = 0;
    dk = input.sed.dk;
    nf = input.mdv.nf; 
end


function [dq,dH,pq,K,ia,ic,qw, H, dT] = get_hydrodynamic_modes(input,bc)
%% Set time resolution
try
    dT = input.ini.sp.dT;
catch
    dT = 3600*24; %default value for timestep in time-reconstruction 
end
ratiodt = dT/input.mdv.dt;


%% CONSTRUCTION
% Upstream BCS
qw = bc.q0;             % [m2/s]

% Downstream BCS
switch input.bch.dotype
    case 3 %Normal flow boundary condition
        t_end = numel(qw);
        qw = qw(1:ratiodt:t_end); 

        bcmat = qw;
        [C, ia,ic] = unique(bcmat, 'rows');

        dq = C(:,1);
        K = numel(dq);

        [pq, ~] = hist(ic,numel(ia));
        pq = pq'./numel(ic);
        dH = [];
        H = [];

    otherwise % User defined downstream condition
        % Downstream BCS: Check whether downstream flow depth should be considered as the boundary
        % condition or not..
        if isfield(input.ini,'sp')
            if isfield(input.ini.sp,'etaw0')
                bc.etaw0 = [input.ini.sp.etaw0; input.ini.sp.etaw0];
            end
        end

        repfac =round(numel(bc.q0)./numel(bc.etaw0));
        if repfac>1
            H = repmat(bc.etaw0,ceil(repfac),1);
        else
            H = bc.etaw0;
            qw = repmat(qw,ceil(1/repfac),1);
        end

        t_end = min(numel(H),numel(qw));
        H = H(1:ratiodt:t_end); 
        qw = qw(1:ratiodt:t_end); 

        bcmat = [qw, H];
        [C, ia,ic] = unique(bcmat, 'rows');

        dq = C(:,1);
        dH = C(:,2);  
        K = numel(dq);

        [pq, ~] = hist(ic,numel(ia));
        pq = pq'./numel(ic);
end
end