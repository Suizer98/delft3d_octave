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
%$Id: check_ini.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_ini.m $
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

function input_out=check_ini(input,fid_log)

%check that the kind of input is specified
if isfield(input.ini,'initype')==0
    error('You need to specify the kind of initial condition in input.ini.initype')
end

%check that the input matches the kind of input
switch input.ini.initype
    case 1 %normal flow (for a given qbk0)
        if isfield(input.bch,'timeQ0')==0 
            if input.bch.uptype == 12 && input.bch.dotype == 12
            else
                error('You need to provide the time at which the specific water discharge is specified (input.bch.timeQ0) if you want such an upstream hydrodynamic boundary condition')
            end
        elseif isfield(input.bch,'Q0')==0
            if input.bch.uptype == 12 && input.bch.dotype == 12
            else
                error('You need to provide the specific water discharge at the specified times (input.bch.Q0) if you want such an upstream hydrodynamic boundary condition')
            end
        end
        if isfield(input.bcm,'timeQbk0')==0
            if input.bcm.type == 12
            else
                error('You need to provide the time at which the volume of sediment transported excluding pores per unit time, and per size fraction is specified (input.bcm.timeQbk0) if you want such a morphodynamic boundary condition')
            end
        elseif isfield(input.bcm,'Qbk0')==0
            if input.bcm.type == 12
            else
                error('You need to provide the volume of sediment transported excluding pores per unit time, and per size fraction at the specified times (input.bcm.Qbk0) if you want such a morphodynamic boundary condition')
            end
        end
%         if isfield(input.ini,'Fak')==0 || isfield(input.ini,'u')==0 || isfield(input.ini,'h')==0 || isfield(input.ini,'slopeb')==0
%             error('You need to specify an initial value of Fak, u, h, and slopeb as an initial guess to find the normal flow intial condition')
%         end
        switch input.frc.wall_corr
            case {1,2}
                error('There is a problem with the initial condition. You need the flow for the bed friction and the bed friction for the sediment transport, which you need for the flow')
        end
            
    case 2 %free
        %check dimension if vectors
        if     numel(input.ini.u)~=1 && size(input.ini.u,2)~=input.mdv.nx
            error('The dimensions of input.ini.u are incorrect')
        elseif numel(input.ini.h)~=1 && size(input.ini.h,2)~=input.mdv.nx
            error('The dimensions of input.ini.h are incorrect')
        end
        if input.mdv.nf~=1
            if size(input.ini.Fak,1)~=input.mdv.nef
                error('The rows of input.ini.Fak need to be the number of size fractions minus 1')
            elseif size(input.ini.Fak,2)~=1 && size(input.ini.Fak,2)~=input.mdv.nx
                error('The columns of input.ini.Fak need to be the number of x points')
            end
        end
        %check slope or bed elevation
        if isfield(input.ini,'etab') && isfield(input.ini,'slopeb')
            error('If you provide the initial bed elevation you cannot provide the initial slope')
        end
        if (isfield(input.ini,'slopeb') && isfield(input.ini,'etab0')==0) || (isfield(input.ini,'slopeb')==0 && isfield(input.ini,'etab0'))
            error('If you provide the initial slope you have to provide the downstream bed elevation and viceversa')
        end
        if isfield(input.ini,'etab')
            if numel(input.ini.etab)~=1 && size(input.ini.etab,2)~=input.mdv.nx
                error('The dimensions of input.ini.etab are incorrect')
            end
        end
        if isfield(input.ini,'slopeb')
            if numel(input.ini.slopeb)~=1 && size(input.ini.slopeb,2)~=input.mdv.nx
                error('The dimensions of input.ini.slopeb are incorrect')
            end
        end

    case 3 %from file
        %check that inicon.mat exists
        warning('there is no check to the input when willing to load file')
        
    case 4 %normal flow (for a given initial condition)
        input.bch.mor='set1';
        input.bch.dotype='set1';
        input.bcm.type='set1';
        if isfield(input.ini,'u') || isfield(input.ini,'h')
            fprintf(fid_log,'ATTENTION!!! input.ini.u and input.ini.b are computed to have normal flow for a given water discharge and slope \n');
        end
        %check dimension if vectors
        if input.mdv.nf~=1
            if size(input.ini.Fak,1)~=input.mdv.nef
                error('The rows of input.ini.Fak need to be the number of size fractions minus 1')
            elseif size(input.ini.Fak,2)~=1 && size(input.ini.Fak,2)~=input.mdv.nx
                error('The columns of input.ini.Fak need to be the number of x points')
            end
        end
        
    case {5,51,52,53,12,13} %alternating steady equilibrium profile
        warningprint(fid_log,'For a space-marching initial condition no input-check is performed');
       
    otherwise
        error('input.ini.initype can be: 1 (normal flow), 2 (free), 3 (from file), 4 (normal flow out of initial condition), 5(space marching)')
end

       %check substrate
switch input.ini.initype
    case {1,2,4}
        if input.mdv.nf~=1
            if isfield(input.ini,'fsk')==0
                error('You have to specify the initial condition of the substrate (input.ini.fsk)');
            else
                %load it if it is a file
                if ischar(input.ini.fsk)
                    load(input.ini.fsk);
                end
                    %actual check
                if     size(input.ini.fsk,1)~=input.mdv.nef
                        error('The number of rows of input.ini.fsk needs to be the number of size fractions minus 1')
                elseif size(input.ini.fsk,2)~=1 && size(input.ini.fsk,2)~=input.mdv.nx        
                        error('The number of columns of input.ini.fsk needs to be the number of x points')
                elseif size(input.ini.fsk,3)~=1 && size(input.ini.fsk,3)~=input.mdv.nsl        
                        error('The 3rd dimension of input.ini.fsk needs to be the number of layers in the substrate')
                end
                   %add patch
                if isfield(input.ini,'subs') && isfield(input.ini.subs,'patch') 
                    if isfield(input.ini.subs.patch,'x')==0 || isfield(input.ini.subs.patch,'releta')==0 || isfield(input.ini.subs.patch,'fsk')==0
                        error('You need to specify input.ini.subs.patch.x, input.ini.subs.patch.releta, and input.ini.subs.patch.fsk if you want to add a patch') 
                    end
                    if diff(input.ini.subs.patch.x)<=0
                        error('input.ini.subs.patch.x in increasing coordinate order')
                    end
                    if any(input.ini.subs.patch.releta<0)
                        error('Specify substrate depth, positive downward')
                    end
                    %check dimension if vectors
                    if size(input.ini.subs.patch.fsk,1)~=input.mdv.nef
                        error('The rows of input.ini.fsk need to be the number of size fractions minus 1')
                    elseif size(input.ini.subs.patch.fsk,2)~=1
                        error('The columns of input.ini.fsk needs to be 1')
                    end 
                end
            end
        end
    case {5,51,52,53,12,13} %alternating steady equilibrium profile
        warningprint(fid_log,'For a space-marching initial condition no input-check is performed');
end

%noise to initial condition
if isfield(input.ini,'noise')==0
    input.ini.noise=0;
end
switch input.ini.noise
    case 1
        if isfield(input.ini,'noise_param')==0
            error('specify the parameters to add noise')
        end
        if size(input.ini.noise_param,1)~=1 || size(input.ini.noise_param,2)~=2
            error('the size of the noise parameters is incorrect')
        end
    case 2
        if isfield(input.ini,'trench')==0
            error('You need to provide data on the trench if you want to model it input.ini.trench')
        end
end

%% OUTPUT 

input_out=input;