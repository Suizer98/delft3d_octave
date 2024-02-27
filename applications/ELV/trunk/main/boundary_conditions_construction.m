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
%$Id: boundary_conditions_construction.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/boundary_conditions_construction.m $
%
%boundary_condition_construction is a function that interpolates the boundary conditions
%
%bc=boundary_conditions_construction(u,h,Mak,La,Cf,input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -bc = boundary conditions [struct] 
%
%HISTORY:
%160223
%   -V. Created for the first time.
%%160429
%   -L. Adjusted for hydraulic boundary condition cases
%160626
%   -V. cyclic boundary conditions
%
%160803
%	-L. Merged versions
%160824
%   -L. Version 4; removed small error
%170126
%   -L. Updated case numbers, case 2 'cyclic hydrograph' has been replaced
%171005
%   -V. Added particle activity
%181102
%   -V. Made a nested function


function bc=boundary_conditions_construction(u,h,Mak,La,Cf,input,fid_log)

%the nested function is not the best solution. It would be nicer to create a new one. I do this to avoid changing the other functions that call boundary_conditions_construction
switch input.mdv.bc_interp_type
    case 1
        bc=boundary_conditions_construction_interp(u,h,Mak,La,Cf,input,fid_log);
    case 2
        %preallocate bc
        bc=struct('q0',[],'Q0',[],'repQT',[],'etaw0',[],'rephT',[],'qbk0',[],'Qbk0',[],'repQbkT',[],'repGammakT_u',[],'repGammakT_d',[],'Gammak0',[],'GammakL',[],'g_u',[],'g_d',[],'repLaT',[],'La',[]); %if you change this line, copy paste the changes in preallocate_dependent_vars.m
end

end %boundary_conditions_construction
   
function bc=boundary_conditions_construction_interp(u,h,Mak,La,Cf,input,fid_log)

%%
%% RENAME
%%

        
%do not use v2struct because of the switch. vaiables may be or may be not
%used.

time=input.mdv.time;
nt=input.mdv.nt;
nf=input.mdv.nf;
Tstop=input.mdv.Tstop;

%warning in case the interpolation may take a lot of time
if input.mdv.nt>1e8
    warning('The number of time steps is very large, the computer may freeze while interpolating the boundary conditions, be patience, the simulation has not crashed.')
end

%preallocate bc
bc=struct('q0',[],'Q0',[],'repQT',[],'etaw0',[],'rephT',[],'qbk0',[],'Qbk0',[],'repQbkT',[],'repGammakT_u',[],'repGammakT_d',[],'Gammak0',[],'GammakL',[],'g_u',[],'g_d',[],'repLaT',[],'La',[]); %if you change this line, copy paste the changes in preallocate_dependent_vars.m

%%
%% UPSTREAM HYDRODYNAMIC BOUNDARY CONDITION
%%

switch input.bch.uptype
    case {1,11} %from input
		tend = min(floor(input.bch.timeQ0(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
		Q0=interp1(input.bch.timeQ0,input.bch.Q0,time(1:tend),'linear')'; %column vector
		bc.q0=Q0./input.grd.B(1,1);
        bc.Q0=Q0;
		bc.repQT = [input.bch.timeQ0(end),tend]; % total time step; number of time-instances
    
	case 2 %cyclic hydrograph
        f_s2y=1/3600/24/365; %factor second to years
        epsilon=1*f_s2y; %small value for interpolation [s] 
        v2struct(input.bch.ch,{'fieldnames','p','Q0k'});
        nm=numel(p)+1; %number of modes
        nm_c=(nm-1)*2+2; %number of components in the year vector
        nY=ceil(Tstop*f_s2y); %number of years (cycles)
        
        p_m=p-epsilon; %year time minus epsilon
        p_c=[0;reshape([p_m,p]',nm_c-2,1);1-epsilon];    %[0 ;p1-e;p1;p2-e;p2;...;pn;1 ]
        Q0_c=reshape(repmat(Q0k,1,2)',nm_c,1);           %[q1;q1  ;q2;q2  ;q3;...;qn;qn]
        
        timeQ0_y=NaN(nm_c*nY,1);
        Q0_bi=NaN(nm_c*nY,1);
        count=1;
        for kc=0:nY %cycle loop
            for km=1:nm_c %mode loop
                timeQ0_y(count,1)=kc+p_c(km); 
                Q0_bi(count,1)=Q0_c(km);
                count=count+1;
            end
        end
        Q0=interp1(timeQ0_y/f_s2y,Q0_bi,time,'linear')'; %column vector
        bc.q0=Q0./input.grd.B(1,1);
        bc.Q0=Q0;
		
		
	case 12 %load from file and interpolate
		load(fullfile(input.bch.path_file_Q)); % Loads t,Q
        
        try 
            numel(t); %check if t exists
        catch %assume a daily discharge series
            % Q,t construction; 
            if exist('Qw')==1
                Q = Qw;
            end
            T = numel(Q)*24*3600; %repeated simulation period in days;
            daysec = 24*3600;
            t = 0:daysec:(T-1);
        end
		tend = min(floor(t(end)/input.mdv.dt)+1,nt);
		Q0 = interp1(t,Q,time(1:tend),'linear')'; %column vector 
		bc.q0=Q0./input.grd.B(1,1);
        bc.Q0=Q0;
		bc.repQT = [t(end),tend]; % total time step; number of time-instances

           
        if t(end)<input.mdv.dt
            error('The last time of the upstream hydraulic boundary condition in the boundary condition is not larger or equal than the simulation time step.')
		elseif t(end)<input.mdv.Tstop
            warningprint(fid_log,'The last time of the upstream hydraulic boundary condition in the boundary condition is not larger or equal to the simulation time. The hydrograph will be repeated.')
        end
        
        % Save in result folder;
        save(fullfile(input.mdv.path_folder_results,'Q.mat'),'Q0','t');
        
        
    case 13 % load from ascii
        error('This case is not yet implemented; contact the amazing V or L, or do it yourself');       
        
    case {14,141} %load from file, but use the dominant discharge of the file               
        if input.bcm.type ~= 13
            warningprint(fid_log,'You are using a dominant discharge without NFL boundary; check whether this is really what you want');
        end
        
        switch input.bch.uptype
            case 14
                load(fullfile(input.bch.path_file_Q)); % Loads t,Q
                try 
                    numel(t); %check if t exists
                catch %assume a daily discharge series
                    % Q,t construction; 
                    if exist('Qw')==1
                        Q = Qw;
                    end
                    T = numel(Q)*24*3600; %repeated simulation period in days;
                    daysec = 24*3600;
                    t = 0:daysec:(T-1);
                end
                tend = min(floor(t(end)/input.mdv.dt)+1,nt);
                Q0 = interp1(t,Q,time(1:tend),'linear')'; %column vector 
            case 141
                tend = min(floor(input.bch.timeQ0(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
                Q0=interp1(input.bch.timeQ0,input.bch.Q0,time(1:tend),'linear')'; %column vector
        end
          
        switch input.bcm.NFLtype
            case 1
                S = input.bcm.NFLparam(1);
                Fk = input.bcm.NFLparam(2:end);
            case 2
                AL = input.bcm.NFLparam(1);
                Fk = input.bcm.NFLparam(2:end);
                if isfield(input.bcm,'NFLiparam')==1
                    S = get_equislope(Q0,input,AL,Fk,input.bcm.NFLiparam);
                else
                    S = get_equislope(Q0,input,AL,Fk);
                end
            case 3
                AL = input.bcm.NFLparam;   
                if isfield(input.bcm,'NFLiparam')==1
                    iguess = input.bcm.NFLiparam;
                    iguess = iguess(1:end-1);
                else
                    iguess = [1e-1, 0.5*(AL./sum(AL))];
                    iguess = iguess(1:end-1);
                end
                [S, Fk] = get_equivals(Q0,input,sum(AL),AL./sum(AL),iguess);
                Qbk = get_sedigraph(Q0,input,S,Fk);
        end 
            X0 = max(Q0);
            func = @(X)solve_qdom(X,input,S,Fk,AL,1:1);
            options=optimoptions('fsolve','TolFun',1e-15,'TolX',1e-15,'display','none','MaxFunEvals',1000);
            [X_s,~,~,~]=fsolve(func,X0,options);   
            Qdom = X_s;
            Q0 = [Qdom; Qdom]; 
            t = [0; input.mdv.dt];   
            tend = min(floor(t(end)/input.mdv.dt)+1,nt);
            bc.q0=Q0./input.grd.B(1,1);
            bc.Q0=Q0;
                        
            bc.repQT = [t(end),tend]; % total time step; number of time-instances
           
            if t(end)<input.mdv.dt
                error('The last time of the upstream hydraulic boundary condition in the boundary condition is not larger or equal than the simulation time step.')
            elseif t(end)<input.mdv.Tstop
                warningprint(fid_log,'The last time of the upstream hydraulic boundary condition in the boundary condition is not larger or equal to the simulation time. The hydrograph will be repeated.')
            end
        
        % Save in result folder;
        save(fullfile(input.mdv.path_folder_results,'Q.mat'),'Q0','t');
        
        
        
		
end

%%
%% DOWNSTREAM HYDRODYNAMIC BOUNDARY CONDITION
%%

switch input.bch.dotype
    case {1,11}
        tend2 = min(floor(input.bch.timeetaw0(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
        bc.etaw0=interp1(input.bch.timeetaw0,input.bch.etaw0,time(1:tend2),'linear')'; %column vector
        bc.rephT = [input.bch.timeetaw0(end),tend2]; % total time step; number of time-instances
        
    case 12 % load from file and interpolate
        tend2 = min(floor(t(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
        load(fullfile(input.bch.path_file_etaw0)); % Loads t,Q
        bc.etaw0=interp1(t,etaw0,time,'linear')'; %column vector
        bc.rephT = [t(end),tend2]; % total time step; number of time-instances
               
       if t(end)<input.mdv.dt
            error('The last time of the downstream hydraulic boundary condition in the boundary condition is not larger or equal than the simulation time step.')
       elseif t(end)<input.mdv.Tstop
            warningprint(fid_log,'The last time of the downstream hydraulic boundary condition in the boundary condition is not larger or equal to the simulation time. The hydrograph will be repeated.')
       end
        
    case 'set1'
        tend2 = min(floor(input.bch.timeetaw0(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
%         bc.etaw0=repmat(input.ini.etab0+h(end),nt,1);
        bc.etaw0=repmat(input.bch.etaw0,nt,1);
        bc.rephT = [input.bch.timeetaw0(end),tend2]; % total time step; number of time-instances
end

%%
%% MORPHODYNAMIC BOUNDARY CONDITION
%%

%% NO PARTICLE ACTIVITY
if input.mor.particle_activity==0

switch input.bcm.type
    case {1,11}
        tend = min(floor(input.bcm.timeQbk0(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

        Qbk0=NaN(tend,nf);
        for kf=1:nf
            Qbk0(:,kf)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time(1:tend),'linear')'; 
        end
        bc.qbk0 = Qbk0./input.grd.B(1,1);
        bc.Qbk0 = Qbk0./input.grd.B(1);
        bc.repQbkT = [input.bcm.timeQbk0(end), tend];
    case 3
        f_s2y=1/3600/24/365; %factor second to years
        epsilon=1*f_s2y; %small value for interpolation [s] 
        v2struct(input.bcm.ch,{'fieldnames','p','Qbk0i'});
        nm=numel(p)+1; %number of modes
        nm_c=(nm-1)*2+2; %number of components in the year vector
        nY=ceil(Tstop*f_s2y); %number of years (cycles)
        
        p_m=p-epsilon; %year time minus epsilon
        p_c=[0;reshape([p_m,p]',nm_c-2,1);1-epsilon];    %[0 ;p1-e;p1;p2-e;p2;...;pn;1 ]
        Qbk0i_c=NaN(nm_c,nf); %[qb1_1,qb2_1;qb1_2,qb2_2;qb1_3,qb2_3;...;qb1_n,qb2_n]
        for kf=1:nf
            Qbk0i_c(:,kf)=reshape(repmat(Qbk0i(:,kf),1,2)',nm_c,1); %#ok
        end
        
        timeQbk0i_y=NaN(nm_c*nY,1);
        Qbk0i_bi=NaN(nm_c*nY,nf);
        count=1;
        for kc=0:nY %cycle loop
            for km=1:nm_c %mode loop
                timeQbk0i_y(count,1)=kc+p_c(km); 
                Qbk0i_bi(count,:)=Qbk0i_c(km,:);
                count=count+1;
            end
        end
        Qbk0=NaN(nt+1,nf);
        for kf=1:nf
            Qbk0(:,kf)=interp1(timeQbk0i_y/f_s2y,Qbk0i_bi(:,kf),time,'linear')'; 
        end
        bc.qbk0=Qbk0./input.grd.B(1,1);
        bc.Qbk0=Qbk0;
    case 'set1'
        [qbk,~]=sediment_transport(input.aux.flg,input.aux.cnt,h(1),u(1)*h(1),Cf(1),La(1),Mak(:,1)',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,fid_log,0);
%         bc.qbk0=repmat(qbk,nt,1);
%         bc.qbk0=repmat(qbk,2,1);
        bc.qbk0=qbk;
        bc.repQbkT = [input.mdv.Tstop, 1];

        % bc.Qbk0 cannot be defined here
        fprintf(fid_log,'qbk0=%4.2e \n',qbk);
		
	case 12 %load from file and interpolate
        load(fullfile(input.bcm.path_file_Qbk0));
        % Check input
        if size(Qbk,2) ~= nf
            error('The columns of Qbk0 load from file should be the same as the number of grain size fractions');
        end
        tend = min(floor(t(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
        for kf=1:nf
            Qbk0(:,kf)=interp1(t,Qbk(:,kf),time(1:tend),'linear')'; 
        end
        bc.qbk0=Qbk0./input.grd.B(1,1);
        bc.Qbk0=Qbk0;
        bc.repQbkT = [t(end),tend]; % total time step; number of time-instances
        
    case 13 %normal flow load distribution
        
        switch input.bcm.NFLtype
            case 1
                Sin = input.bcm.NFLparam(1);
                Fkin = input.bcm.NFLparam(2:end);
                Qbk = get_sedigraph(Q0,input,Sin,Fkin);
            case 2
                AL = input.bcm.NFLparam(1);
                Fkin = input.bcm.NFLparam(2:end);
                if isfield(input.bcm,'NFLiparam')==1
                    S = get_equislope(Q0,input,AL,Fkin,input.bcm.NFLiparam);
                else
                    S = get_equislope(Q0,input,AL,Fkin);
                end
                Qbk = get_sedigraph(Q0,input,S,Fkin);
            case 3
                AL = input.bcm.NFLparam;   
                if isfield(input.bcm,'NFLiparam')==1
                    iguess = input.bcm.NFLiparam;
                    iguess = iguess(1:end-1);
                else
                    iguess = [1e-1, 0.5*(AL./sum(AL))];
                    iguess = iguess(1:end-1);
                end
                [S, Fk] = get_equivals(Q0,input,sum(AL),AL./sum(AL),iguess);
                Qbk = get_sedigraph(Q0,input,S,Fk);
        end 
        tend = numel(Q0);%min(floor(t(end)/input.mdv.dt),nt); % number of time-instances that a bc is defined
        t = time(1:tend);
        save(fullfile(input.mdv.path_folder_results,'Qbk0.mat'),'Qbk','t');
        
        %tend = min(floor(t(end)/input.mdv.dt),nt); % number of time-instances that a bc is defined
        for kf=1:nf
            Qbk0(:,kf)=interp1(t,Qbk(:,kf),time(1:tend),'linear')'; 
        end
        bc.qbk0=Qbk0./input.grd.B(1,1);
        bc.Qbk0=Qbk0;
        bc.repQbkT = [t(end),tend]; % total time step; number of time-instances
             
end

%% PARTICLE ACTIVITY
else
    
%upstream
bc.repGammakT_u=NaN(1,2); %we preallocate because it needs to exist although it may not be used
switch input.bcm.pa_u
    case 1 %Dirichlet
        %it is possible to input Gammak0 or Qbk0 (if the diffusion coefficient is zero)
        switch input.bcm.pa_u_Dirichlet_type
            case 0 %not necessary

            case 1 %Gammak
                tend = min(floor(input.bcm.timeGammak0(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

                Gammak0=NaN(tend,nf);
                for kf=1:nf
                    Gammak0(:,kf)=interp1(input.bcm.timeGammak0,input.bcm.Gammak0(:,kf),time(1:tend),'linear')'; 
                end
                bc.Gammak0 = Gammak0./input.grd.B(1,1);
    %             bc.Qbk0 = Qbk0./input.grd.B(1);
                bc.repGammakT_u = [input.bcm.timeGammak0(end), tend];
            case 2 %Qbk
                tend = min(floor(input.bcm.timeQbk0(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

                Qbk0=NaN(tend,nf);
                for kf=1:nf
                    Qbk0(:,kf)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time(1:tend),'linear')'; 
                end
                bc.qbk0 = Qbk0./input.grd.B(1,1);
                bc.Qbk0 = Qbk0./input.grd.B(1);
                bc.repGammakT_u = [input.bcm.timeQbk0(end), tend];
        end
    case 2 %Neumann
        error('not done yet')
    case 3 %Robin
        tend = min(floor(input.bcm.timeQbk0(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

        Qbk0=NaN(tend,nf);
        for kf=1:nf
            Qbk0(:,kf)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time(1:tend),'linear')'; 
        end
        qbk0 = Qbk0./input.grd.B(1,1);
        bc.repGammakT_u = [input.bcm.timeQbk0(end), tend];
        bc.g_u=-[qbk0;qbk0(end,:)]; %we need nT+1 values since the future condition is needed for Robin
%         bc.h_u=[vpk(1),vpk(1)];

end

%downstream
bc.repGammakT_d=NaN(1,2); %we preallocate because it needs to exist although it may not be used
switch input.bcm.pa_d
    case 0 %boundary condition not necessary because it is purely advective (kappa=0)

    case 1 %Dirichlet
        switch input.bcm.pa_d_Dirichlet_type
            case 1 %GammakL
                tend = min(floor(input.bcm.timeGammakL(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

                GammakL=NaN(tend,nf);
                for kf=1:nf
                    GammakL(:,kf)=interp1(input.bcm.timeGammakL,input.bcm.GammakL(:,kf),time(1:tend),'linear')'; 
                end
                bc.GammakL = GammakL./input.grd.B(1,1);
        %         bc.Qbk0 = Qbk0./input.grd.B(1);
                bc.repGammakT_d = [input.bcm.timeGammakL(end), tend];
            case 2 %QbkL
                tend = min(floor(input.bcm.timeQbkL(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

                QbkL=NaN(tend,nf);
                for kf=1:nf
                    QbkL(:,kf)=interp1(input.bcm.timeQbkL,input.bcm.QbkL(:,kf),time(1:tend),'linear')'; 
                end
                bc.qbkL = QbkL./input.grd.B(1,1);
                bc.repGammakT_d = [input.bcm.timeQbkL(end), tend];
        end
    case 2 %Neumann
        error('not done yet')
    case 3 %Robin
        if isnan(input.bcm.QbkL)==0 %if it is not capacity
            tend = min(floor(input.bcm.timeQbkL(end,1)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined

            QbkL=NaN(tend,nf);
            for kf=1:nf
                QbkL(:,kf)=interp1(input.bcm.timeQbkL,input.bcm.QbkL(:,kf),time(1:tend),'linear')'; 
            end
            qbkL = QbkL./input.grd.B(1,1);
            bc.repGammakT_d = [input.bcm.timeQbkL(end), tend];
            bc.g_d=-[qbkL;qbkL(end,:)]; %we need nT+1 values since the future condition is needed for Robin
    %         bc.h_d=[vpk(1),vpk(1)];
        end
end

end %input.mor.particle_activity

%%
%% ACTIVE LAYER THICKNESS VARIATION WITH TIME
%%

if input.mor.Latype==4
    tend = min(floor(input.mor.timeLa(end)/input.mdv.dt)+1,nt); % number of time-instances that a bc is defined
    La=interp1(input.mor.timeLa,input.mor.La,time(1:tend),'linear')'; %column vector
    bc.La=La;
    bc.repLaT = [input.mor.timeLa(end),tend]; % total time step; number of time-instances
end
end %boundary_conditions_construction_interp