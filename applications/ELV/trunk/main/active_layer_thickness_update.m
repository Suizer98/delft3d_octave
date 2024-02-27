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
%$Id: active_layer_thickness_update.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/active_layer_thickness_update.m $
%
%active_layer_thickness_update is a function that updates the active layer thickness
%
%\texttt{La=active_layer_thickness_update(h,Mak,La_old,input,fid_log,kt)}
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%181104
%   -V. Add possibility of CFL based time step

function La=active_layer_thickness_update(~,~,La_old,eta_new,eta_old,psi,bc,input,~,kt,time_l)

%%
%% RENAME
%%

Struiksma=input.mor.Struiksma;
bc_interp_type=input.mdv.bc_interp_type;
nx=input.mdv.nx;

%%
%% UPDATE
%%

switch input.mor.Latype
    case 1 %constant active layer thickness
        La=La_old; %incorrect if it is changed due to ellipticity solution
%         La=repmat(input.mor.La,1,input.mdv.nx);   %this is slower but allows for gsd_update={2,3} (should not be used...)
    case 2 %active layer thickness related to grain size
        error('not yet implemented')
    case 3 %active layer thickness related to flow depth
        error('not yet implemented')      
    case 4 %active layer thickness growing with time
%         La=La_old+input.mor.La_t_growth*input.mdv.dt; %deprecated
        switch bc_interp_type 
            case 1
                Lact = mod(kt,bc.repLaT(2))+(mod(kt,bc.repLaT(2))==0)*bc.repLaT(2); 
                La=repmat(bc.La(Lact),1,nx); %[1,nx]
            case 2
                La_1=interp1(input.mor.timeLa,input.mor.La,time_l,'linear'); %[1,1]
                La=repmat(La_1,1,nx); %[1,nx]
        end %bc_interp_type
end %input.mor.Latype

if Struiksma==1
    La_psi=La+(eta_new-eta_old);
    La(psi<1)=La_psi(psi<1);
end

end %active_layer_thickness_update
        