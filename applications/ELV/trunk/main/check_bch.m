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
%$Id: check_bch.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_bch.m $
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

function input_out=check_bch(input,fid_log)


%% UPSTREAM

%check that the kind of upstream hydrodynamic boundary condition is specified
if isfield(input.bch,'uptype')==0
    error('You need to specify the kind of upstream hydrodynamic boundary condition in input.bch.uptype')
end

%check that the input matches the kind of input
switch input.bch.uptype
    case {1,11} %water discharge Q
        if isfield(input.bch,'timeQ0')==0
            error('You need to provide the time at which the specific water discharge is specified (input.bch.timeQ0) if you want such an upstream hydrodynamic boundary condition')
        elseif isfield(input.bch,'Q0')==0
            error('You need to provide the specific water discharge at the specified times (input.bch.Q0) if you want such an upstream hydrodynamic boundary condition')
        end 
        if input.bch.timeQ0(end)<input.mdv.dt
            error('The last time of the upstream hydraulic boundary condition is not larger than or equal to the time step')
        elseif input.bch.timeQ0(end)<input.mdv.Tstop
            warningprint(fid_log,'The last time of the upstream hydraulic boundary condition in the boundary condition is not larger or equal to the simulation time. The hydrograph will be repeated.')
        end

    case {12,13,14}
        if isfield(input.bch,'path_file_Q')==0 %if there does not exist a path to the Q-file 
            [path_folder_main,~,~]=fileparts(input.mdv.path_file_input); %get path to main folder
            input.bch.path_file_Q=fullfile(path_folder_main, 'Q.mat'); %path to the Q file
        end 

    case 'set1'
        if isfield(input.bch,'timeQ0') || isfield(input.bch,'Q0')
            fprintf(fid_log,'ATTENTION! input.bch.timeQ0 and input.bch.Q0 are not used if you specify normal flow for a given initial condition \n');
        end
        
        
    otherwise
        error('input.bch.uptype can be: 1, 11=water discharge from input, 12=water discharge from file')
end        



%% DOWNSTREAM

%check that the kind of downstream hydrodynamic boundary condition is specified
if isfield(input.bch,'dotype')==0
    error('You need to specify the kind of downstream hydrodynamic boundary condition in input.bch.dotype')
end

%check that the input matches the kind of input
switch input.bch.dotype
    case {1,11} %downstream water elevation
        if isfield(input.bch,'timeetaw0')==0
            error('You need to provide the time at which the downstream water level is specified (input.bch.timeetaw0) if you want such a downstream hydrodynamic boundary condition')
        elseif isfield(input.bch,'etaw0')==0
            error('You need to provide the donwstream water level at the specified times (input.bch.etaw0) if you want such an upstream hydrodynamic boundary condition')
        end 
        if input.bch.timeetaw0(end)<input.mdv.dt
            error('The last time of the downstream hydraulic boundary condition in the boundary condition is not larger or equal to the chosen time step')
        elseif input.bch.timeetaw0(end)<input.mdv.Tstop
            warningprint(fid_log,'The last time of the downstream hydraulic boundary condition in the boundary condition is not larger or equal to the simulation time. The downstream boundary condition will be repeated') 
        end
        if any(size(input.bch.timeetaw0)~=size(input.bch.etaw0))
            error('The size of the downstream hydrodynamic boundary conditions does not match')
        end
    case 12
        if isfield(input.bch,'path_file_etaw0')==0 %if there does not exist a path to the hdown-file 
            [path_folder_main,~,~]=fileparts(input.mdv.path_file_input); %get path to main folder
            input.bch.path_file_etaw0=fullfile(path_folder_main, 'etaw0.mat'); %path to the hdown file
        end         
    case 'set1'
        if isfield(input.bch,'timeetaw0') || isfield(input.bch,'etaw0')
            fprintf(fid_log,'ATTENTION!!! input.bch.timeetaw0 and input.bch.etaw are computed to have normal flow for a given water discharge and slope \n');
        end
    case {2,21} %downstream water depth
        error('not working yet??')
%         if isfield(input.bch,'path_file_etaw0')==0 %if there does not exist a path to the hdown-file 
%             [path_folder_main,~,~]=fileparts(path_file_input); %get path to main folder
%             input.bch.path_file_etaw0=fullfile(path_folder_main, 'etaw0.mat'); %path to the hdown file
%         end 
    case 22 %water depth from file
        error('not working yet??')
    case 3 %normal flow depth
    otherwise
        error('input.bch.dotype can be: 1,11=downstream water elevation from input, 12=downstream water elevation from file')
end

%% OUTPUT 

input_out=input;