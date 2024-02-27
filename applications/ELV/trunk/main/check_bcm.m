%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16757 $
%$Date: 2020-11-02 14:34:08 +0800 (Mon, 02 Nov 2020) $
%$Author: chavarri $
%$Id: check_bcm.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_bcm.m $
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

function input_out=check_bcm(input,fid_log)

%check that the kind of morphodynamic boundary condition is specified
if isfield(input.bcm,'type')==0
    error('You need to specify the kind of morphodynamic boundary condition in input.bcm.type')
end

%check that the input matches the kind of input
switch input.bcm.type
    case {1,11} %sediment discharge
        switch input.ini.initype
            case 4 %if it is equal to 4, it is internally computed
                if isfield(input.bcm,'timeQbk0') || isfield(input.bcm,'Qbk0')
                    warningprint(fid_log,'You are providing a time series of sediment discharge which is not used.')
                end
            otherwise
                if isfield(input.bcm,'timeQbk0')==0
                    error('You need to provide the time at which the volume of sediment transported excluding pores per unit time, and per size fraction is specified (input.bcm.timeQbk0) if you want such a morphodynamic boundary condition')
                elseif isfield(input.bcm,'Qbk0')==0
                    error('You need to provide the volume of sediment transported excluding pores per unit time, and per size fraction at the specified times (input.bcm.Qbk0) if you want such a morphodynamic boundary condition')
                end 
                %check the dimensions of the input
                if size(input.bcm.Qbk0,1)~=size(input.bcm.timeQbk0,1)
                    error('The rows of input.bcm.Qbk0 must be the same as the rows of input.bcm.timeQbk0')
                end
                if size(input.bcm.Qbk0,2)~=input.mdv.nf
                    error('The colums of input.bcm.Qbk0 must be the same as the number grain size fractions')
                end
                %check proper time definition
                if input.bcm.timeQbk0(end)<input.mdv.dt
                    error('The last time of the upstream morphodynamic boundary condition in the boundary condition is not larger or equal to the chosen time step')
                elseif input.bcm.timeQbk0(end)<input.mdv.Tstop
                    warningprint(fid_log,'The last time of the upstream morphodynamic boundary condition in the boundary condition must be larger or equal to the simulation time')
                end 
        end
    case 12
        if isfield(input.bcm,'path_file_Qbk0')==0 %if there does not exist a path to the Qbk-file 
            [path_folder_main,~,~] = fileparts(input.mdv.path_file_input); %get path to main folder
            input.bcm.path_file_Qbk0=fullfile(path_folder_main, 'Qbk0.mat'); %path to the Qbk file
        end 

    case {2,'set1',4}

    case 13
    %nothing implemented yet... 
    % check input.bcm.NFLtype;input.bcm.NFLparam; input.bcm.NFLiparam (at
    % least check the dimensions)
    
    
    otherwise
        error('input.bcm.type can be: 1=sediment discharge; 2=periodic; 12 ')
end

if input.mdv.bc_interp_type==2 && ~any(input.bcm.type==[1,2,4])
    error('If you interpolate in the loop, the only moprhodynamic boundary conditions possible are either 1, 2, or 4.')
end

%%
%% PARTICLE ACTIVITY
%%
if input.mor.particle_activity
 
%% upstream
if isfield(input.bcm,'pa_u')==0 
    error('Specify upstream boundary condition for particle activity')
end

switch input.bcm.pa_u %particle activity upstream boundary condition type
    case 0 %no particle acticity
    case 1 %Dirichlet (Gammak at x=0 specified)
        if input.mdv.ade_solver==2 && any(input.tra.kappa)~=0
            error('Dirichlet boundary conditions are not implemented for this ADE solver (yet)')
        end
        if input.bcm.type~=2
        %input Gammak0
        if isfield(input.bcm,'timeGammak0')==1 
            %if you input Gammak you do not use Qbk0
            if isfield(input.bcm,'timeQbk0')==1 || isfield(input.bcm,'Qbk0')==1
               warningprint(fid_log,'You have a time series of Gammak but also of Qbk0. You choose what you prefer but CHOOSE!')
            end
            %assign flag
            input.bcm.pa_u_Dirichlet_type=1; %Dirichlet on Gammak
            %check you input Gammak0
            if isfield(input.bcm,'Gammak0')==0
                error('You need to provide a time series of Gammak0 (both time input.bcm.timeGammak0 and values input.bcm.Gammak0')
            end
            %check dimensions
            if size(input.bcm.timeGammak0,2)>1
                error('In input.bcm.timeGammak0 time goes in rows')
            end
            if size(input.bcm.timeGammak0,1)~=size(input.bcm.Gammak0,1)
                error('number of times in input.bcm.timeGammak0 must be equal to the number of times in input.bcm.Gammak0')
            end
            if size(input.bcm.Gammak0,1)~=input.mdv.nf
                error('one value of Gamma per size fraction (in columns)')
            end
            %check proper time definition
            if input.bcm.timeGammak0(end)<input.mdv.dt
                error('The last time of the upstream morphodynamic boundary condition in the boundary condition is not larger or equal to the chosen time step')
            elseif input.bcm.timeGammak0(end)<input.mdv.Tstop
                warningprint(fid_log,'The last time of the upstream morphodynamic boundary condition in the boundary condition must be larger or equal to the simulation time')
            end
        %input Qbk0    
        elseif isfield(input.bcm,'timeQbk0')==1
            %check diffusion is 0 (input.tra is done afterwards, it would be nice if it is moved before this check)
            if any(input.tra.kappa)~=0
                error('You want to impose a time series of sediment transport but the diffusion coefficient is not 0. You should apply Robin boundary conditions.')
            end
            %if you input Gammak you do not use Qbk0
            if isfield(input.bcm,'timeGammak0')==1 || isfield(input.bcm,'Gammak0')==1
               warningprint(fid_log,'You have a time series of Qbk0 but also of Gammak0. You choose what you prefer but CHOOSE!')
            end
            %assign flag
            input.bcm.pa_u_Dirichlet_type=2; %Dirichlet on Qbk
            %check you input Qbk0
            if isfield(input.bcm,'Qbk0')==0
                error('You need to provide a time series of Qbk0')
            end
            %check dimensions
            if size(input.bcm.timeQbk0,2)>1
                error('In input.bcm.timeQbk0 time goes in rows')
            end
            if size(input.bcm.timeQbk0,1)~=size(input.bcm.Qbk0,1)
                error('number of times in input.bcm.timeQbk0 must be equal to the number of times in input.bcm.Qbk0')
            end
            if size(input.bcm.Qbk0,2)~=input.mdv.nf
                error('one value of Qb per size fraction (in columns)')
            end
            %check proper time definition
            if input.bcm.timeQbk0(end)<input.mdv.dt
                error('The last time of the upstream morphodynamic boundary condition in the boundary condition is not larger or equal to the chosen time step')
            elseif input.bcm.timeQbk0(end)<input.mdv.Tstop
                warningprint(fid_log,'The last time of the upstream morphodynamic boundary condition in the boundary condition must be larger or equal to the simulation time')
            end
        else
            error('The magic upstream boundary condition does not exist yet. Provide eather a time series of Gammak or Qbk0')
        end
        else %cyclic boundary conditions for sediment
            %assign flag
            input.bcm.pa_u_Dirichlet_type=0; %Dirichlet on Gammak but a value is not necessary when cycling
            if isfield(input.bcm,'Gammak0') || isfield(input.bcm,'Qbkk0')
                warningprint(fid_log,'The time series of Gammak or Qbk are not going to be used as you want cyclic boundary conditions.')
            end
        end %input.bcm.type
    case 2 %Neumann (dGammak/dx at x=0 specified)
        error('Sorry, Neumann upstream not implemented yet')
    case 3 %Robin (Qbk at x=0 specified)
        %check diffusion is not 0 (input.tra is done afterwards, it would be nice if it is moved before this check)
        if any(input.tra.kappa)==0
            error('You want to impose a Robin boundary condition for the particle activity but the diffusion coefficient is equal to 0. Kind of nonesense dude... The derivative at the boundary does not exist! If there is no diffusion you know the concentration and this is called Dirichlet.')
        end
        if any(input.tra.kappa)<1e-6
            warningprint(fid_log,'You may have problems because the matrix can be singular to computer precision')
        end
        %check input makes sense
        if isfield(input.bcm,'timeGammak0')==1 || isfield(input.bcm,'Gammak0')==1
            warningprint(fid_log,'There is input as if you want Dirichlet upstream boundary condition for Gammak, but you have set Robin')
        end
        if isfield(input.bcm,'timeQbk0')==0
            error('You need to provide the time at which the volume of sediment transported excluding pores per unit time, and per size fraction is specified (input.bcm.timeQbk0) if you want such a morphodynamic boundary condition')
        elseif isfield(input.bcm,'Qbk0')==0
            error('You need to provide the volume of sediment transported excluding pores per unit time, and per size fraction at the specified times (input.bcm.Qbk0) if you want such a morphodynamic boundary condition')
        end 
        %check the dimensions of the input
        if size(input.bcm.Qbk0,1)~=size(input.bcm.timeQbk0,1)
            error('The rows of input.bcm.Qbk0 must be the same as the rows of input.bcm.timeQbk0')
        end
        if size(input.bcm.Qbk0,2)~=input.mdv.nf
            error('The colums of input.bcm.Qbk0 must be the same as the number grain size fractions')
        end
        %check proper time definition
        if input.bcm.timeQbk0(end)<input.mdv.dt
            error('The last time of the upstream morphodynamic boundary condition in the boundary condition is not larger or equal to the chosen time step')
        elseif input.bcm.timeQbk0(end)<input.mdv.Tstop
            warningprint(fid_log,'The last time of the upstream morphodynamic boundary condition in the boundary condition must be larger or equal to the simulation time')
        end
        %check cyclic
        if input.bcm.type==2
            error('This is not yet tested. If you want to cycle the sediment transport rate with diffusion you have to consider qbk=vpk*Gammak-kappa*dGammak/dx')
        end
    otherwise
        error('If you have a boundary condition which is not Dirichlet, Neumann, or Robin, contact the Fields Medal committee.')
end %input.bcm.pa_u

%% downstream
if isfield(input.bcm,'pa_d')==0
    input.bcm.pa_d=0;
end

switch input.bcm.pa_d %particle activity downstream boundary condition type
    case 0 %no particle acticity
        if any(input.tra.kappa~=0)
            warningprint(fid_log,'You do not have downstream boundary condition but there is diffusion. That is kind of niet goed.')
        end
    case 1 %Dirichlet (Gammak at x=L specified)
        if input.mdv.ade_solver==2
            error('Dirichlet boundary conditions are not implemented for this ADE solver (yet)')
        end
        %input GammakL
        if isfield(input.bcm,'timeGammakL')==1 
            %assign flag
            input.bcm.pa_d_Dirichlet_type=1; %Dirichlet on Gammak
            %if you input Gammak you do not use Qbk0
            if isfield(input.bcm,'timeQbkL')==1 || isfield(input.bcm,'QbkL')==1
               warningprint(fid_log,'You have a time series of Gammak but also of Qbk. You choose what you prefer but CHOOSE!')
            end
            %check you input GammakL
            if isfield(input.bcm,'GammakL')==0
                error('You need to provide a time series of GammakL (both time input.bcm.timeGammakL and values input.bcm.GammakL')
            end
            %check dimensions
            if size(input.bcm.timeGammakL,2)>1
                error('In input.bcm.timeGammakL time goes in rows')
            end
            if size(input.bcm.timeGammakL,1)~=size(input.bcm.GammakL,1)
                error('number of times in input.bcm.timeGammakL must be equal to the number of times in input.bcm.GammakL')
            end
            if size(input.bcm.GammakL,1)~=input.mdv.nf
                error('one value of Gamma per size fraction (in columns)')
            end
            %check proper time definition
            if input.bcm.timeGammakL(end)<input.mdv.dt
                error('The last time of the upstream morphodynamic boundary condition in the boundary condition is not larger or equal to the chosen time step')
            elseif input.bcm.timeGammakL(end)<input.mdv.Tstop
                warningprint(fid_log,'The last time of the upstream morphodynamic boundary condition in the boundary condition must be larger or equal to the simulation time')
            end
        %input QbkL    
        elseif isfield(input.bcm,'timeQbkL')==1
            %assign flag
            input.bcm.pa_d_Dirichlet_type=2; %Dirichlet on Qbk
            warningprint(fid_log,'untested!!!!!!!!!!!!')
            %check diffusion is 0 (input.tra is done afterwards, it would be nice if it is moved before this check)
            if any(input.tra.kappa)~=0
                error('You want to impose a time series of sediment transport but the diffusion coefficient is not 0. You should apply Robin boundary conditions.')
            end
            %if you input Gammak you do not use Qbk
            if isfield(input.bcm,'timeGammakL')==1 || isfield(input.bcm,'GammakL')==1
               warningprint(fid_log,'You have a time series of QbkL but also of GammakL. You choose what you prefer but CHOOSE!')
            end
            %check you input Qbk0
            if isfield(input.bcm,'QbkL')==0
                error('You need to provide a time series of QbkL')
            end
            %check dimensions
            if size(input.bcm.timeQbkL,2)>1
                error('In input.bcm.timeQbkL time goes in rows')
            end
            if size(input.bcm.timeQbkL,1)~=size(input.bcm.QbkL,1)
                error('number of times in input.bcm.timeQbkL must be equal to the number of times in input.bcm.QbkL')
            end
            if size(input.bcm.QbkL,2)~=input.mdv.nf
                error('one value of Qb per size fraction (in columns)')
            end
            %check proper time definition
            if input.bcm.timeQbkL(end)<input.mdv.dt
                error('The last time of the upstream morphodynamic boundary condition in the boundary condition is not larger or equal to the chosen time step')
            elseif input.bcm.timeQbkL(end)<input.mdv.Tstop
                warningprint(fid_log,'The last time of the upstream morphodynamic boundary condition in the boundary condition must be larger or equal to the simulation time')
            end
        %saturation value downstream
        else 
            %assign flag
            input.bcm.pa_d_Dirichlet_type=3; %Dirichlet saturation
        end
        %check kappa
        if any(input.tra.kappa)==0
            error('You have downstream boundary condition but there is no diffusion. Niet goed malaka.')
        end
    case 2 %Neumann (dGammak/dx at x=L specified)
        error('Sorry, Neumann downstream not implemented yet')
    case 3 %Robin (Qbk at x=L specified)
        if isfield(input.bcm,'timeGammakL')==1 || isfield(input.bcm,'GammakL')==1
            warningprint(fid_log,'There is input as if you want Dirichlet dowsntream boundary condition for Gammak, but you have set Robin')
        end
        if isnan(input.bcm.QbkL)

        else
            if isfield(input.bcm,'timeQbkL')==0 || isfield(input.bcm,'QbkL')==0
                error('You need to provide a time series of QbkL (both time input.bcm.timeQbkL and values input.bcm.QbkL')
            else
                if size(input.bcm.timeQbkL,2)>1
                    error('In input.bcm.timeQbkL time goes in rows')
                end
                if size(input.bcm.timeQbkL,1)~=size(input.bcm.QbkL,1)
                    error('number of times in input.bcm.timeQbkL must be equal to the number of times in input.bcm.QbkL')
                end
                if size(input.bcm.QbkL,2)~=input.mdv.nf
                    error('one value of QbkL per size fraction (in columns)')
                end
            end
        end
        %check kappa
        if any(input.tra.kappa)==0
            error('You have downstream boundary condition but there is no diffusion. Niet goed malaka.')
        end
    otherwise
        error('If you have a boundary condition which is not Dirichlet, Neumann, or Robin, contact the Fields Medal committee.')
end %input.bcm.pa_u

end %particle_activity

%% OUTPUT 

input_out=input;