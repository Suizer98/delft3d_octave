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
%$Id: sediment_transport_4.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/sediment_transport_4.m $
%
%sediment transport calculation 
%
%[qbk,Qbk]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,fid_log,kt)
%
%% INPUT
%Symbols used in the size definition:
    %-nx is the number of points in streamwise directions
    %-nf is the number of size fractions
    
    % flg = flags ; structure
        % flg.sed_trans = sediment transport relation
            % 1 = Meyer-Peter, Muller (1948)    
            % 2 = Engelund-Hansen (1967)
            % 3 = Ashida-Michiue (1972)
            % 4 = Wilcock-Crowe (2003)
            %
            % 6 = Parker (1990)
            % 7 = Ribberink (1987)
        % flg.friction_closure = friction closure relation
            % 1 = Chezy | Darcy-Weisbach
            % 2 = Manning 
        % flg.hiding = hiding-exposure effects
            % 0 = no hiding-exposure 
            % 1 = Egiazaroff (1965)
            % 2 = Power law
            % 3 = Ashida-Michiue (1972)
        % flg.Dm = mean grain size
            % 1 = geometric
            % 2 = arithmetic 
    % cnt = constans ; structure
        % cnt.g         = gravity [m^2/s] ; double [1,1]
        % cnt.rho_s     = sediment density [kg/m^3] ; double [1,1]
        % cnt.rho_w     = water density [kg/m^3] ; double [1,1]
        % cnt.p         = porosity [-] ; double [1,1]
    % h               = flow depth [m] ; double [nx,1] | double [1,nx] ; e.g. [0.5,0.1,0.6];
    % q               = specific water discharge [m^2/s] ; double [nx,1] | double [1,nx] ; e.g. [5;2;2];
    % cf              = dimensionless friction coefficient (u_{*}^{2}=cf*u^2) [-] ; double [nx,1] | double [1,nx] ; e.g. [0.011,0.011,0.011];
    % La              = active layer thickness [m] ; double [nx,1] | double [1,nx] ; e.g. [0.01,0.015,0.017];
    % Mak             = effective mass matrix ; double [nx,nf-1] ; e.g. [0.2,0.3;0.8,0.1;0.9,0] ;
    % dk              = characteristic grain sizes [m] ; double [1,nf] | double [nf,1] ; e.g. [0.003,0.005]
    % sed_trans_param = parameters of the sediment transport relation choosen 
            % MPM48    = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; MPM = [8,1.5,0.047], FLvB = [5.7,1.5,0.047] ; Ribberink = [15.85,1.5,0.0307]
            % EH67     = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
            % AM72     = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
            % GL       = [r,w,tau_ref]
            % Ribb     = [m_r,n_r,l_r] [s^5/m^(2.5),-,-] ; double [2,1] ; original = [2.7e-8,6,1.5]
    % hiding_param    = parameter of the power law hiding function [-] ; double [1,1] ; e.g. [-0.8]
    % mor_fac         = morphological acceleration factor [-] ; double [1,1] ; e.g. [10]
        
%% OUTPUT
    % qbk = sediment transport per grain size and node including pores and morphodynamic acceleration factor [m^2/s] ; double [nx,nf]
    % Qbk = sediment transport capacity per grain size and node including pores and morphodynamic acceleration factor [m^2/s] ; double [nx,nf]
   
%% NOTES
    %-The morphodynamic accelerator factor is included in the sediment
    % transport relations. If you want to compute is outside, set it equal
    % to 1. 
    %-The porosity is included in the sediment transport relations. If you
    % want to copute it without pores, set it equal to 0.
    %-In the Hirano model, 'mass' (Mak) refers to the product of the volume
    % fractions per the active layer thickness (Mak=La*Fak). It is done in
    % this way to be able to easily calculate the derivatives respect to
    % the mass, which is what matters. 
    %-The terms 'effective' refers to nf-1 fractions. It is done in this
    % minimize mass issues and to be able to compute the derivatives respect
    % to mass. 
    %-It is thought as a 1D computation of a multi-fraction mixture in the
    % Hirano model. You can compute unisize transport by setting La equal to
    % 1 and Mak equal to an empty matrix.
    %-All input needs to be specified. The parse needs to be before the
    % function calling. This is done in this way because parameters (e.g.
    % gravity) are used outside the sediment transport. This means that
    % before calling this function there needs to be a parse and a check to,
    % for example, the sediment transport parameteres. 
    
%%
%HISTORY:
%151104
%   -V. bug in reshape La solved
%
%160418
%   -V. change of check for unisize 
%
%160517
%   -V. bug in EH for multisize
%
%160702
%   -V. tiny improvements in performance
%
%160825
%   -V. Generalized load relation
%
%170621
%   -adapted to new Matlab arithmetics (after R2016b)

%% FUNCTION 

function [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport_4(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log,kt)

%%

%reshape h, q, dk, cf, La and at the same time check that they are vectors
nx=length(h); %number of points in streamwise direction
nf=length(dk); %number of size fractions

% if nx~=length(q) || nx~=size(Mak,1) || nx~= length(cf); error('h and q need to have the same length and needs to be equal to the number of rows in Mak, check your input'); end %check line, comment for improved performance

h=reshape(h,nx,1);
q=reshape(q,nx,1);
cf=reshape(cf,nx,1);
dk=reshape(dk,1,nf);
La=reshape(La,nx,1);

%volume fractions (Fak) [-] ; double [nx,nf]
% if isnan(Mak) %unisize calculation (treated differently due to effective fractions)
if nf==1 %unisize calculation (treated differently due to effective fractions)
%     if nf-1~=0; error('the mass matrix does not match the characteristic grains sizes, check your input'); end %check input
    Fak=ones(nx,1);
else %multisize calculation
%     if nf-1~=size(Mak,2); error('the mass matrix does not match the characteristic grains sizes, check your input'); end %check input
    Fak=NaN(nx,nf); %preallocate volume fractions
    Fak(:,1:nf-1)=Mak./La; %effective fractions (for version<2016b)
    Fak(:,nf)=ones(nx,1)-sum(Fak(:,1:nf-1),2); %all fractions
end %isempty(Mak)

%bed shear stress (tau_b) [N/m^2] ; double [nx,1]
switch flg.friction_closure
    case 1 %Darcy-Weisbach
        tau_b=cnt.rho_w*cf.*(q./h).^2;
    case 2 %Manning
        n=sqrt(cf.*h.^(1/3)/cnt.g); %reconversion
        tau_b=cnt.rho_w*cnt.g*n.^2.*(q./h).^2./h.^(1/3); 
    otherwise
        error('check friction input')
end

%Shields stress (thetak) [-] ; double [nx,nf]
thetak=1/(cnt.rho_w*cnt.g*cnt.R)*tau_b./dk; 

%mean grain size (Dm) [m] ; double [nx,1]
% if exist_str(flg,'Dm')
switch flg.Dm
    case 1 %geometric
        Dm=2.^sum(Fak.*log2(dk),2);
    case 2 %arithmetic
        Dm=sum(Fak.*dk,2);
    otherwise
        if nf == 1
            Dm = dk;
        else
            error('check kind of Dm')
        end
end
% end

%hiding function (xik) [-] ; double [nx,nf]
switch flg.hiding
    case 0 %no hiding-exposure
        xik=ones(nx,nf); 
    case 1 %Egiazaroff
        xik=(log10(19)./log10(19*dk./Dm)).^2;
    case 2 %power-law
        xik=(dk./Dm).^hiding_param;
    case 3 %Ashida-Michiue
        xik_br1_idx=dk./Dm<0.38889; %indeces of xik in branch 1 ; boolean [nx,nf]
        xik_br1=0.8426*Dm./dk; %all as 1st branch (br 1)
        xik=(log10(19)./log10(19*dk./Dm)).^2; %all as 2nd branch (Egiazaroff) (br 0)
        xik(xik_br1_idx)=xik_br1(xik_br1_idx); %compose
    otherwise
        error('check hiding')
end

%ripple factor
switch flg.mu
    case 0 %unspecified
        mu=ones(nx,nf);
    case 1 %specified constant
        mu=flg.mu_param.*ones(nx,nf); %this is crap, I need to parse the input to properly do this
    otherwise
        error('not implemented')        
end

%sediment transport capacity including pores (Qbk) [m^2/s] ; double [nx,nf]
switch flg.sed_trans
    case 1 %MPM48
        a_mpm=sed_trans_param(1);
        b_mpm=sed_trans_param(2);
        theta_c=sed_trans_param(3);
        no_trans_idx=(mu.*thetak-xik.*theta_c)<0; %indexes of fractions below threshold ; boolean [nx,nf]
        Qbk_st=a_mpm.*(mu.*thetak-xik.*theta_c).^b_mpm; %MPM relation
        Qbk_st(no_trans_idx)=0; %the transport capacity of those fractions below threshold is 0
    case 2 %EH67
        m_eh=sed_trans_param(1);
        n_eh=sed_trans_param(2);
        theta_c=0;
        u=q./h; %depth averaged flow velocity [m/s]
        Qbk_st=cf.^(3/2).*(cnt.g*cnt.R*dk).^(-5/2).*m_eh.*(u.^n_eh); %EH relation
        no_trans_idx=false(nx,nf);
    case 3 %AM72
        a_am=sed_trans_param(1);
        theta_c=sed_trans_param(2);
        no_trans_idx=(thetak-xik.*theta_c)<0; %indexes of fractions below threshold
        Qbk_st=a_am.*(thetak-xik.*theta_c).*(sqrt(thetak)-sqrt(xik.*theta_c));
        Qbk_st(no_trans_idx)=0; %the transport capacity of those fractions below threshold is 0
    case 4 %WC03 
        theta_c=0;
        dk_sand_idx=dk<0.002; %size fractions indeces considered as sand ; boolean [1,nf]
        Fs=sum(dk_sand_idx.*Fak,2); %sand fraction (Fs) [-] ; double [nx,1]
        tau_st_rm=0.021+0.015*exp(-20*Fs); %reference Shields stress for the mixture (tau_st_rm) [-] ; double [nx,1]
        tau_rm=(cnt.R*cnt.rho_w*cnt.g).*tau_st_rm.*Dm; %reference bed shear stress for the mixture (tau_rm) [N/m^2] ; double [nx,1]
        dk_Dm=dk./Dm; %dk/Dm [-] ; double [nx,nf]
        b=0.67./(1+exp(1.5-dk_Dm)); %hiding power [-] ; double [nx,nf]
        tau_rk=tau_rm.*(dk_Dm).^b; %reference shear stress for each grain size [N/m^2] ; double [nx,nf]
        phi_k=tau_b./tau_rk; %parameter phi in WC [-] ; double [nx,nf]
        phi_k_br1_idx=phi_k<1.35; %indeces of phi_i in branch 1 ; boolean [nx,nf]
        Wk_st_br1=0.002*phi_k.^(7.5); %dimensionsless transport W as if all values were in branch 1 [-] ; double [nx,nf] 
        Wk_st=14.*(1-0.894./(phi_k.^(1/2))).^(4.5); %dimensionsless transport W as if all values were in branch 2 [-] ; double [nx,nf] 
        Wk_st(phi_k_br1_idx)=Wk_st_br1(phi_k_br1_idx); %compose
%         Qbk=Wk_st.*(cf.^(3/2).*(q./h).^3)./cnt.R./cnt.g./(1-cnt.p); %transform Wk into Qbk   
        Qbk_st=Wk_st.*thetak.^(3/2);
        no_trans_idx=false(nx,nf);
    case 5 %Generalized load relation
        theta_c=0;
        r = sed_trans_param(1);
        w = sed_trans_param(2);
        tau_ref = sed_trans_param(3);
        D_ref = 0.001;
        G = cf.^(w+3/2)/(tau_ref^w*(cnt.R*cnt.g)^(w+1));
        Qbk_st = (1-cnt.p)./sqrt(cnt.g*cnt.R*dk.^3).*(dk/D_ref).^r.*G.*1./dk.^w.*(q./h).^(2*w+3);
        no_trans_idx=false(nx,nf);
    case 6 %Parker
        a_park=0.00218;
        theta_c=0.0386;
        chi=thetak./theta_c;
        G=exp(14.2*(chi-1)-9.28*(chi-1).^2); %all in branch 2
        G_1=5474*(1-0.853./chi).^(4.5); %branch 1
        G_3=chi.^(14.2); %branch 3
        G_1_idx=chi>=1.59; %branch 1 identifier
        G_3_idx=chi< 1.00; %branch 3 identifier
        G(G_1_idx)=G_1(G_1_idx);
        G(G_3_idx)=G_3(G_3_idx);
        Qbk_st=a_park.*thetak.^(3/2).*G;
        no_trans_idx=false(nx,nf);
    case 7 %Ribberink      
        m_r=sed_trans_param(1);
        n_r=sed_trans_param(2);
        l_r=sed_trans_param(3);
        theta_c=0;
        u=q./h; %depth averaged flow velocity [m/s]
        %the calibrated formula of Ribberink is already including pores. Here we substract them to later add the in Exner
        Qbk_st=1./sqrt(cnt.g*cnt.R*dk.^3).*(1-0.40)*m_r.*(u.^n_r)./(Dm.^l_r); %Ribberink
        no_trans_idx=false(nx,nf);
    otherwise 
        error('sediment transport formulation')
end

%entrainment
switch flg.E
    case 0 %do not compute
        Ek_st=NaN;
    case 1 %FLvB 
        a_E=E_param(1);
        b_E=E_param(2);
        
        no_E_idx=thetak-xik.*theta_c<0; %indexes of fractions below threshold ; boolean [nx,nf]
        Ek_st=a_E.*(thetak-xik.*theta_c).^b_E;
        Ek_st(no_E_idx)=0; %the transport capacity of those fractions below threshold is 0
    case 3 %AM-type
        a_E=E_param(1);
        
        no_E_idx=thetak-xik.*theta_c<0; %indexes of fractions below threshold ; boolean [nx,nf]
        Ek_st=a_E.*(thetak-xik.*theta_c).*(sqrt(thetak)-sqrt(xik.*theta_c));
        Ek_st(no_E_idx)=0; %the transport capacity of those fractions below threshold is 0
    otherwise
        
end

%velocity
switch flg.vp
    case 0 %do not compute
        vpk_st=NaN;
    case 1
        a_vpk=vp_param(1);
        b_vpk=vp_param(2);
        
        no_vpk_idx=sqrt(thetak)-b_vpk.*sqrt(xik.*theta_c)<0; %indexes of fractions below threshold ; boolean [nx,nf]
        vpk_st=a_vpk.*(sqrt(thetak)-b_vpk.*sqrt(xik.*theta_c));
        vpk_st(no_vpk_idx)=0; %the transport capacity of those fractions below threshold is 0
    otherwise
        
end

%dependencies of entrainment deposition
if flg.E~=0
    %deposition
    switch flg.sed_trans
        case 1
            Dk_st=a_E/a_mpm*vpk_st;
        case 3
            Dk_st=a_E/a_am*vpk_st;
        otherwise
            %ATT! this does not work! It creates a discontinuity in Dk because it is 0 when Qbk_st is 0 but it should not because the term (thetak-theta_c) in Qbk_st cancels with the one in Ek_st
            Dk_st=Ek_st.*vpk_st./Qbk_st; 
            Dk_st(no_trans_idx)=0;
    %         Dk_st(no_vpk_idx)=0;
    end
    
    %equilibrium particle activity
    Gammak_eq_st=Fak.*Qbk_st./vpk_st;
    Gammak_eq=Gammak_eq_st.*dk; %without pores
    % Gammak_eq=Gammak_eq_st./(1-cnt.p); %with pores
    
    %dimensionalize
    Ek_g=Ek_st.*sqrt(cnt.g*cnt.R*dk)./La;
    Ek=(Fak.*La).*Ek_g; %do not use Mak due to dimensions

    Dk_g=Dk_st.*sqrt(cnt.g*cnt.R*dk)./dk;
    Dk=Gammak.*Dk_g; 

    vpk=vpk_st.*sqrt(cnt.g*cnt.R*dk);

else
    Dk_st=NaN;
    Gammak_eq=NaN;
    Ek_g=NaN;
    Ek=NaN;
    Dk_g=NaN;
    Dk=NaN;
    vpk=NaN;
end

Qbk=Qbk_st.*sqrt(cnt.g*cnt.R*dk.^3)./(1-cnt.p); %sediment transport capacity

%sediment transport including pores and morphodynamic acceleration factor (qbk) [m^2/s] ; double [nx,nf]
if flg.particle_activity==0
    qbk=mor_fac.*Fak.*Qbk; 
else
    dGammak=diff(Gammak,1);
    dGammak_dx=[dGammak;dGammak(end,:)]/cnt.dx;
    qbk=vpk.*Gammak-cnt.kappa'.*dGammak_dx;
end

%other dependencies
if flg.extra
    qbk_st=qbk./sqrt(cnt.g*cnt.R*dk.^3).*(1-cnt.p)./Fak;
    Wk_st=qbk_st./thetak.^(3/2);
    u_st=sqrt(tau_b/cnt.rho_w);
else
    qbk_st=NaN;
    Wk_st=NaN;
    u_st=NaN;
end

end %sediment_transport
    
