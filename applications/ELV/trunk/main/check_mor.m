%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17436 $
%$Date: 2021-08-02 11:18:12 +0800 (Mon, 02 Aug 2021) $
%$Author: chavarri $
%$Id: check_mor.m 17436 2021-08-02 03:18:12Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_mor.m $
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

function input_out=check_mor(input,fid_log)

%gsdupdate
if isfield(input.mor,'gsdupdate')==0 %if it is not defined  
    warningprint(fid_log,'You are not specifying how to update the GSD of the bed, I will use Hirano.')
    input.mor.gsdupdate=1;
end
if any(input.mor.gsdupdate==[2,3,4,5,6])
    warningprint(fid_log,'You shall not pass!!!!!!! You are trying to update the grain size distribution using techniques that do not work.')
end

%scheme
if isfield(input.mor,'scheme')==0
    input.mor.scheme=0;
    warningprint(fid_log,'You are not specifying the type of morphodynamic scheme. I am using FTBS.')
end
if input.mor.scheme~=0 && input.mor.gsdupdate~=0
    error('You are trying to update the bed GSD with a morphodynamic scheme different than FTBS. I have not implemented this yet...')
end
switch input.mor.scheme
    case 0
    case 1
    case 2
        input.mdv.interp_edges=1;
        if isfield(input.mor,'fluxtype')==0
            input.mor.fluxtype=8;
            warningprint(fid_log,'This morphodynamic scheme requires a flux type limiter which you are not specifying, I am using Koren.')
        else 
            if input.mor.fluxtype>8
                error('The automagic flux limiter for morphodynamics has not been implemented.')
            end
        end
        if input.mor.ellcheck==0
            warningprint(fid_log,'I am setting input.mor.ellcheck=1 because it is needed for computing the fluxes using this morphodynamic scheme')
        end
        input.mor.ellcheck=1;
    otherwise
        error('The automagic morphodynamic scheme has not been implemented.')
end

%particle activity
if isfield(input.mor,'particle_activity')==0 %if it is not defined  
    input.mor.particle_activity=0;
end
if input.mor.particle_activity==1 && input.mor.interfacetype==2
    error('Particle activity and Hoey-Ferguson cannot be done. Definition of sediment transport needs to checked')
end
if input.mor.particle_activity==1 && input.mor.gsdupdate>1
    error('Particle activity and PMM cannot be used')
end
if input.mor.particle_activity==1 && input.bcm.type==4
    error('Particle activity and fixed bed boundary condition has not been implemented')
end

%active layer
if input.mdv.nf~=1
    %interfacetype
    if input.mor.interfacetype==2
        if isfield(input.mor,'fIk_alpha')==0
            error('Specify fIk_alpha if you use Hoey and Ferguson')
        end
        if input.mor.fIk_alpha<0 || input.mor.fIk_alpha>1
            error('input.mor.fIk_alpha must be between 0 and 1')
        end
    end  
    %type
    switch input.mor.Latype
        case 1
        case 2
            error('I have not done it yet... :(')
        case 3
            error('I have not done it yet... :(')
        case 4
            if isfield(input.mor,'La_t_growth')
                error('Sorry, this input has been deprecated in favor of a time series. Use input.mor.timeLa and input.mor.La.')
            end
            if isfield(input.mor,'timeLa')==0 || isfield(input.mor,'La')==0
                error('specify the time series of the active layer thickness')
            end
            if size(input.mor.timeLa,1)~=size(input.mor.La,1) || size(input.mor.timeLa,2)>1 || size(input.mor.La,2)>1
                error('input.mor.timeLa and input.mor.La must column vectors of the same length')
            end
    end
else
    input.mor.Latype=1; %pseudo
end

%thickness of the last layer
if isfield(input.mor,'ThUnLyrEnd')==0 %if it is not defined 
    input.mor.ThUnLyrEnd=input.mor.ThUnLyr; %use the same as the rest
end

%factor multiplying the thickness of the first layer
if isfield(input.mor,'lsk1_fc')==0 %if it is not defined 
    input.mor.lsk1_fc=1; %make it 1 (no modification)
end
if input.mor.lsk1_fc<0
   error('You cannot have negative thickness. Set a positive value for input.mor.lsk1_fc') 
end

%morfac
if isfield(input.mor,'MorFac')==0 %if it does not exist
    input.mor.MorFac=1; 
end

%ellipticity check
if isfield(input.mor,'ellcheck')==0 %if it does not exist
    input.mor.ellcheck=0; %default is not to check (expensive!)
end

if input.mor.ellcheck==0 && input.mdv.chk.ell==1
    input.mor.ellcheck=1;
    warningprint(fid_log,'Hum... seems you want to check for ellipticity but you have not actually asked for it (check input.mor.ellcheck). I am checking for ellipticity because it seems you are a nice person, but ELV does not like stupid input! :D')
end

%factor of alpha in pmm
if isfield(input.mor,'pmm_alpha_eps')==0 %if it does not exist
    input.mor.pmm_alpha_eps=0.05; %fraction added to alpha to avoid equal eigenvalues; [1x1 double]; e.g. [0.05]
end

%start time
if isfield(input.mor,'Tstart')==0
    input.mor.Tstart=-1;
end

%struiksma
if isfield(input.mor,'Struiksma')==0
    input.mor.Struiksma=0;
end
if input.mor.Struiksma==1
    if input.mor.scheme==2
        error('This is not yet possible. You have to modify function ''struiksma_reduction'' for dealing with interpolated sediment transport')
    end
end
    
%I think it should be equal to the input active layer thickness
% if input.mor.Struiksma==1
%     if isfield(input.mor,'L_alluvial')
%         
%     end
% end

%% OUTPUT 

input_out=input;