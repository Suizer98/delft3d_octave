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
%$Id: check_frc.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_frc.m $
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

function input_out=check_frc(input,fid_log)

%%
%% EXISTENCE
%%

%% DEPRECATED

%total friction type
if isfield(input.mdv,'frictiontype') %deprecated input
    warningprint(fid_log,'input.mdv.frictiontype is deprecated in favor of input.frc.Cf_type and will be removed in future ELV versions. Adapt or die...');
    input.frc.Cf_type=input.mdv.frictiontype;
end
%friction parameter
if isfield(input.mdv,'Cf') %deprecated input
    warningprint(fid_log,'input.mdv.Cf is deprecated in favor of input.frc.Cf and will be removed in future ELV versions. Thanks for your understanding!');
    input.frc.Cf=input.mdv.Cf;
end

%% TEST EXISTENCE

%total friction model
if isfield(input.frc,'Cf_type')==0
    input.frc.Cf_type=1; 
end
%wall correction
if isfield(input.frc,'wall_corr')==0
    input.frc.wall_corr=0; %flume wall correction: 0=NO; 1=Johnson (1942); 
end
%ripple correction
if isfield(input.frc,'ripple_corr')==0
    input.frc.ripple_corr=0; %ripple correction: 0=NO; 1=constant values; 2=depending on active layer
end
%skin friction model
if isfield(input.frc,'Cfb_model')==0
    input.frc.Cfb_model=0; %0=plane bed (Cf_b=Cf); 2=Nikuradse (1933); 3=imposed bed friction coefficient; 4=related to active layer thickness; 5=Engelund-Hansen (1967); 6=Wright and Parker (2004); 7=Smith and McLean (1977)
    warningprint(fid_log,'You have not specified a skin friction model. I will assume it is plane bed.');
end
%roughness height
if isfield(input.frc,'nk')==0
    input.frc.nk=2;
    if input.frc.Cfb_model==2
        warningprint(fid_log,'You have not specified a Nikuradse friction height. I will use standard value equal to 2. This is used (at least) if you correct for bedforms.');
    end
end

%%
%% CONSISTENCY
%%

%total friction model
switch input.frc.Cf_type
    case 1 %constant
        if isfield(input.frc,'Cf')==0
            error('You need to specify input.frc.Cf')
        end  
    case 2 %related to grain size
        error('not yet done, sorry... :-{D')
    case 3 %related to flow depth
        error('not yet done, sorry... :-{D')
    case 4 %depending on the active layer thickness
        if isfield(input.frc,'Cf_param')==0
            error('You need to specify input.frc.Cf_param')
        end  
        if size(input.frc.Cf_param,1)~=1 || size(input.frc.Cf_param,2)~=2
            error('specify [a,b] parameters of Cf=a*La+b; [1x2 double]')
        end
    otherwise
        error('input.frc.Cf_type can be: 1 constant')
end

%wall correction
switch input.frc.wall_corr
    case 0
        
    case 1 
end

%ripple correction
switch input.frc.ripple_corr
    case 1 
        if isfield(input.frc,'H')==0 || isfield(input.frc,'L')==0
            error('You need to specify a ripple height (input.frc.H) and length (input.frc.L)')
        end
    case 2
        if isfield(input.frc,'H_param')==0 || isfield(input.frc,'L_param')==0
            error('You need to specify the parameters relating H and L to the active layer thickness')
        end
        if size(input.frc.H_param,1)~=1 || size(input.frc.H_param,2)~=2 || size(input.frc.L_param,1)~=1 || size(input.frc.L_param,2)~=2
            error('The size of the parameters relating H and L to the active layer thickness are incorrect')
        end
end

%skin friction model
switch input.frc.Cfb_model %skin friction model  ; 4= 5=; 6=; 7=
    case 0
        input.frc.Cfb=input.frc.Cf; %plane bed (Cf_b=Cf)
    case 2 %Nikuradse (1933);
        
    case 3 %imposed bed friction coefficient 
        if isfield(input.frc,'Cfb')==0
           error('If you want to impose a value for the bed friction, you better input it...  input.frc.Cfb')
        end
    case 4 %related to active layer thickness;
        if isfield(input.frc,'Cfb_param')==0
           error('If you want Cfb to be a function of the active layer thickness you have to provide the parameters')
        end
        if size(input.frc.Cfb_param,1)~=1 || size(input.frc.Cfb_param,2)~=2 
            error('Wrong size of input.frc.Cfb_param')
        end
    case 5 %Engelund-Hansen (1967)
    case 6 %Wright and Parker (2004)
    case 7 %Smith and McLean (1977)
    case 8 %Haque (1983) 
        if isfield(input.frc,'H')==0 || isfield(input.frc,'L')==0
            error('You need to specify a ripple height (input.frc.H) and length (input.frc.L)')
        end
    otherwise
        error('I am not sure what you want to do with friction but it is not implemented.')
end


if input.mdv.flowtype == 6 %main-flood1-flood2
    if numel(input.frc.Cf)==1
        if input.grd.crt==1
            warningprint(fid_log,'Only one friction coefficient is supplied, but the channel is rectangular.');
            warningprint(fid_log,'No action is taken.');
        else
            warningprint(fid_log,'Only one friction coefficient is supplied, it is used everywhere');
            input.frc.Cf = [input.frc.Cf; input.frc.Cf; input.frc.Cf];
        end
    elseif numel(input.frc.Cf)==2
        warningprint(fid_log,'Only two friction coefficients are supplied, it is assumed you want both floodplains with same coefficient');
        input.frc.Cf = [input.frc.Cf input.frc.Cf; input.frc.Cf(2)];
    elseif numel(input.frc.Cf)==3         
    else
        error('Wrong dimensions for input.frc.Cf');
    end 
end

%% OUTPUT 

input_out=input;
