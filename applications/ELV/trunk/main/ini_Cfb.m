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
%$Id: ini_Cfb.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/ini_Cfb.m $
%
%ini_Cfb is a function that creates the initial bed friction coefficient vector
%
%Cf=ini_Cf(input,fid_log)
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

function Cf_b=ini_Cfb(input,Cf,u,h,La,Mak,fid_log)

%% RENAME

nx=input.mdv.nx;
g=input.mdv.g;

nk=input.frc.nk;
R=input.aux.cnt.R;
rhow=input.mdv.rhow;

input_i=input; %to modify when entered

%% CALC

switch input.frc.wall_corr
    case 0 %no correction
        Cf_b=input.frc.Cf(1).*ones(1,nx);              
    case 1 %Johnson (1942)
        Sf=Cf.*u.^2/g./h; %friction slope
        Cf_b=NaN(1,nx); %bed friction coefficient
        u_st_b=NaN(1,nx); %bed friction velocity
        for kx=1:nx
            input_i.grd.B=input.grd.B(kx); %from vector to component
            [~,Cf_b(kx),~,u_st_b(kx)]=side_wall_correction(input_i,u(kx),h(kx),Sf(kx));
        end
    case 3
        error('You must be running an old script. Set input.frc.wall_corr=0 and input.frc.Cfb_model=3')
    otherwise
        error('If nothing, set to 0')
end

%bed friction model
switch input.frc.Cfb_model %skin friction model
    case 0
%         Cf_b=Cf_b; %not necessary
    case 2 %2=Nikuradse (1933)
        Fak=Mak2Fak(Mak,La,input,fid_log);
        Dm=mean_grain_size(Fak,input,fid_log);
        Cf_b=1./(5.75*log10(12*h./(nk*Dm))).^2;
    case 3 %3=imposed bed friction coefficient
        Cf_b=repmat(input.frc.Cfb,nx,1); 
    case 4 %function of the active layer thickness
        Cf_b=input.frc.Cfb_param(1)*La+input.frc.Cfb_param(2);
    case 5 %Engelund-Hansen (1967)
        Fak=Mak2Fak(Mak,La,input,fid_log);
        Dm=mean_grain_size(Fak,input,fid_log);
        tau_b=rhow*Cf_b.*u.^2; %bed shear stress (tau_b) [N/m^2] ; double [nx,1] We use Cf_b to compute the total bed shear stress because here it may have been corrected for wall effects
        thetak=1/(rhow*g*R)*tau_b./Dm;  %Shields stress of mean grain size [-] ; double [nx,1]
        thetak_s=0.06+0.4.*thetak.^2; %skin Shields stress
        Cf_b=thetak_s*g*R*Dm/u^2; 
    case 6 %Wright and Parker (2004)
        Fak=Mak2Fak(Mak,La,input,fid_log);
        Dm=mean_grain_size(Fak,input,fid_log);  
        Fr=u./sqrt(g.*h);
        tau_b=rhow*Cf_b.*u.^2; %bed shear stress (tau_b) [N/m^2] ; double [nx,1] We use Cf_b to compute the total bed shear stress because here it may have been corrected for wall effects
        thetak=1/(rhow*g*R)*tau_b./Dm;  %Shields stress of mean grain size [-] ; double [nx,1]
        thetak_s=0.05+0.7.*(thetak*Fr.^0.7).^0.8; %skin Shields stress
        Cf_b=thetak_s*g*R*Dm/u^2; 
    case 7 %Smith and McLean (1977)
        for kx=1:nx
            switch input.frc.ripple_corr %ripple correction: 0=NO 
                case 1 %1=constant bedform heigh and length;

                case 2 %2=bedform height and length as a function of the active layer thickness
                    input.frc.H=input.frc.H_param(1)*La(kx)+input.frc.H_param(2);
                    input.frc.L=input.frc.L_param(1)*La(kx)+input.frc.L_param(2);
            end
            [Cf_b(kx),~,~,~]=bed_form_correction(input,u_st_b(kx),u(kx));
        end
    case 8 %Haque (1983)
        H=input.frc.H;
        L=input.frc.L;
        
        f_f=4.9*(H/L).^1.477*(H./h).^1.653;
        Cf_f=f_f/8;
        Cf_b=Cf-Cf_f;        
    otherwise 
        error('ehem.... What are you doing with your life?')
end

end %function
