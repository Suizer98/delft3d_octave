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
%$Id: add_sedflags.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/add_sedflags.m $
%
%add_sedflags parse the sediment input and adds the sediment transport relation flags to the input structure 
%
%\texttt{input=add_sedflags(input)}
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -input = input structure
%
%HISTORY:
%160223
%   -V. Created for the first time.

function input = add_sedflags(input,fid_log)

if nargin<2
    fid_log =NaN;
end

%% make all variables to exist

if isfield(input.mor,'particle_activity')==0 %necessary in case you use this function outside ELV
    input.mor.particle_activity=0;
end

if isfield(input.tra,'cr')==0 
    input.tra.cr=1;
    warningprint(fid_log,'You have not specified a sediment transport relation (input.tra.cr). I will use Meyer-Peter Muller (1948) just because I like it.')
end

if isfield(input.tra,'E_cr')==0 
    input.tra.E_cr=1;
    if input.mor.particle_activity==1
        warningprint(fid_log,'You have not specified an entrainment closure relation (input.tra.E_cr). I will use Fernandez-Luque and van Beek just because I like it.')
    end
end

if isfield(input.tra,'vp_cr')==0 
    input.tra.vp_cr=1;
    if input.mor.particle_activity==1
        warningprint(fid_log,'You have not specified a particle velocity closure relation (input.tra.vp_cr). I will use Fernandez-Luque and van Beek just because I like it.')
    end
end

if isfield(input.tra,'param')==0 
    switch input.tra.cr
        case 1
            warningprint(fid_log,'You have not specified the parameters of the sediment transport relation (input.tra.param). I will use the standard values for Meyer-Peter and Muller. Attention! The standard is without hiding.')
            input.tra.param=[8,1.5,0.047];
            input.tra.hid=0;
        case 2 
            warningprint(fid_log,'You have not specified the parameters of the sediment transport relation (input.tra.param). I will use the standard values, good luck!')
            input.tra.param=[0.05,5];
        case 3
            warningprint(fid_log,'You have not specified the parameters of the sediment transport relation (input.tra.param). I will use the standard values for Ashida-Michiue. Attention! The standard is with hiding.')
            input.tra.param=[17,0.05];
            input.tra.hid=3;
        case 7
            warningprint(fid_log,'You have not specified the parameters of the sediment transport relation (input.tra.param). I will use the standard values for Ribberink. Attention! Mean grain size is arithmetic.')
            input.tra.param=[6,1.5,2.7e-8];
            input.tra.hid=0;
            input.tra.Dm=2;
    end
end

if isfield(input.tra,'E_param')==0 %entrainment function paramenters
    input.tra.E_param=[0.0199,1.5]; 
    if input.mor.particle_activity==1
        warningprint(fid_log,'You have not specified the parameters of the entrainment function (input.tra.E_param). I will use the standard values for Fernandez-Luque van Beek')
    end
end

if isfield(input.tra,'vp_param')==0 %particle velocity function parameters
    input.tra.vp_param=[11.5,0.7]; 
    if input.mor.particle_activity==1
        warningprint(fid_log,'You have not specified the parameters of the particle velocity function (input.tra.vp_param). I will use the standard values for Fernandez-Luque van Beek')
    end
end

if isfield(input.tra,'hid')==0 %hiding correction  
    input.tra.hid=0;
end

if isfield(input.tra,'hiding_b')==0 %hiding parameter of power law
    input.tra.hiding_b=NaN;
end

if isfield(input.tra,'Dm')==0
    input.tra.Dm=1; %default is geometric
end

if isfield(input.tra,'kappa')==0
    if isfield(input.mdv,'nf')==0 %necessary in case you use this function outside ELV
        input.mdv.nf=1;
    end
    input.tra.kappa=NaN(input.mdv.nf,1); 
end



if isfield(input.tra,'mu')==0 
    input.tra.mu=0;
end

if isfield(input.tra,'mu_param')==0 
    input.tra.mu_param=NaN;
end

%% once everything exists 

if input.mor.particle_activity==1 && input.tra.E_cr~=input.tra.cr 
    warningprint(fid_log,'The closure relation for the sediment transport rate does not match the closure relation for the entrainment rate. This possible but problematic. It may creates a discontinuity in Dk because it is 0 when Qbk_st is 0 but it may cancel with the term in Ek_st')
end

switch input.tra.cr
        
    case 7
        if input.tra.Dm==1
            warningprint(fid_log,'In Ribberink''s sediment transport relation the mean grain size is calibrated for arithmetic and you are setting it to geometric')
        end
        
end

if input.tra.mu~=0 && isnan(input.tra.mu_param)
    error('You want to set a ripple factor but you are not setting the value')
end
switch input.tra.mu
    case 0
        
    case 1
        if input.tra.cr~=1
            warningprint(fid_log,'You are setting a ripple factor but using a transport relation which is not MPM, you are doing nothing!')
        end

    otherwise
        error('this ripple factor is not implemented yet')
end
 
switch input.tra.E_cr
    case 0 %no entrainment deposition computation
        
    case 1 %FLvB-type
        if numel(input.tra.E_param)~=2
            error('wrong dimension in input.tra.E_param')
        end
        if input.tra.E_param(2)~=input.tra.param(2) && input.mor.particle_activity==1
            warningprint(fid_log,'the power of the excess shield should be the same in the sediment transport relation than in the entrainement formulation. Otherwise tt may create a discontinuity in Dk because it is 0 when Qbk_st is 0 but it may cancel with the term in Ek_st')
        end
    case 3 %AM-type
        if numel(input.tra.E_param)~=1
            error('wrong dimension in input.tra.E_param')
        end
        if input.tra.E_param(1)<0.05
            warningprint(fid_log,'You are the AM-type entrainment form but the parameter seems the one of FLvB-type. You can use it but then the depositional rate is not the same as in FLvB. Use E_param=0.0591 to guarantee that the depositional rate is the one measured by FLvB. ')
        end
    otherwise
        error('whatever you want to do, it is not implemented yet')
end

switch input.tra.vp_cr
    case 1
        if numel(input.tra.vp_param)~=2
            error('wrong dimension in input.tra.vp_param')
        end

    otherwise
        error('whatever you want to do, it is not implemented yet')
end

if size(input.tra.kappa,1)~=input.mdv.nf || size(input.tra.kappa,2)>1
    error('kappa dimensions are not correct')
end

if input.tra.hid==2
   if isnan(input.tra.hiding_b)
       error('you must specify the hiding parameter if using the Power Law')
   end
   if input.tra.hiding_b>0
      error('the hiding parameter of the Power Law is defined as (dk/Dm)^(hiding_b). Thus, it should be negative')
   end
end

    %in case the function is used outside ELV
% if isfield(input,'grd')==0 || isfield(input.grd,'dx')==0
%         input.grd.dx=NaN; 
% end

%% RENAME
% the sediment transport function requires these structures. This can be improved by changing sediment_transport 
flg.sed_trans=input.tra.cr;
flg.friction_closure=1;
flg.hiding=input.tra.hid;
flg.Dm=input.tra.Dm; 
flg.hiding_parameter=input.tra.hiding_b;
flg.E=input.tra.E_cr;
flg.vp=input.tra.vp_cr;
flg.particle_activity=input.mor.particle_activity;
flg.mu=input.tra.mu;
flg.mu_param=input.tra.mu_param;
flg.extra=0; 

cnt.g=input.mdv.g;
cnt.rho_w=input.mdv.rhow;
cnt.p=0; %this is to compute the sediment transport without pores. Porosity is in bed level update.
cnt.R=(input.sed.rhos-input.mdv.rhow)/input.mdv.rhow;
cnt.kappa=input.tra.kappa;
cnt.dx=input.grd.dx;

input.aux.flg=flg;
input.aux.cnt=cnt;

end %function

