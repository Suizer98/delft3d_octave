%sediment_transport_2D computes the sediment transport rate in x and y
%direction.
%
%% INPUT
%
    % flg = flags ; structure
        % flg.sed_trans = sediment transport relation
            % 1 = Meyer-Peter, Muller (1948)    
            % 2 = Engelund-Hansen (1967)
            % 3 = Ashida-Michiue (1972)
            % 4 = Wilcock-Crowe (2003)
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
        % cnt.k         = Von Karman constant [-] ; double [1,1]
    % h               = flow depth [m] ; double [nx,1] | double [1,nx] ; e.g. [0.5,0.1,0.6];
    % q               = specific water discharge [m^2/s] ; double [nx,1] | double [1,nx] ; e.g. [5;2;2];
    % cf              = dimensionless friction coefficient (u_{*}^{2}=cf*u^2) [-] ; double [nx,1] | double [1,nx] ; e.g. [0.011,0.011,0.011];
    % La              = active layer thickness [m] ; double [nx,1] | double [1,nx] ; e.g. [0.01,0.015,0.017];
    % Mak             = effective mass matrix ; double [nx,nf-1] ; e.g. [0.2,0.3;0.8,0.1;0.9,0] ;
    % dk              = characteristic grain sizes [m] ; double [1,nf] | double [nf,1] ; e.g. [0.003,0.005]
    % sed_trans_param = parameters of the sediment transport relation choosen 
            % MPM48    = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; original = [8,1.5,0.047]
            % EH67     = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
            % AM72     = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
    % hiding_param    = parameter of the power law hiding function [-] ; double [1,1] ; e.g. [-0.8]
    % mor_fac         = morphological acceleration factor [-] ; double [1,1] ; e.g. [10]
    % I               = secondary flow intensity [m/s] ; double [1,1] ; e.g. [??]
    % E_s             = calibration parameter of the secondary flow [-] ; double [1,1] ; e.g. [??]
%        
%% OUTPUT
    % qbk = sediment transport per grain size and node including pores and morphodynamic acceleration factor [m^2/s] ; double [nx,nf]
    % Qbk = sediment transport capacity per grain size and node including pores and morphodynamic acceleration factor [m^2/s] ; double [nx,nf]

%Symbols used in the size definition:
    %-nx is the number of points in streamwise directions
    %-nf is the number of size fractions

%% HISTORY
%   -161024 V created it

function [qbkx,qbky,Qbkx,Qbky,thetak]=sediment_transport_2D(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s,sx,sy,E_param,vp_param,Gammak,gsk_param)

%% RENAME

calib_s=flg.calib_s; %to desactivate bed slope effects

%% MODULE

q_m=norm(q); %module of the specific water discharge [m^2/s] 

[qbk,Qbk,thetak,~,~,~,~,~,~,~,~,~,~,~,~,~,~,Dm]=sediment_transport(flg,cnt,h,q_m,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);

%% DIRECTION


% alpha_I=2/cnt.k^2*E_s*(1-sqrt(cf)/(2*cnt.k)); %D3D (error?) contant [-]
alpha_I=2/cnt.k^2*E_s*(1-sqrt(cf)/(1*cnt.k)); % contant [-]

% varphi_tau=atan((q(2)-h*alpha_I*q(1)/q_m*I)/(q(1)-h*alpha_I*q(2)/q_m*I)); %direction of the sediment transport modified due to secondary flow [rad]
% varphi_tau=atan2(q(2)-h*alpha_I*q(1)/q_m*I,q(1)-h*alpha_I*q(2)/q_m*I); %direction of the sediment transport modified due to secondary flow [rad]
%ATTENTION! I think that the Delft3D manual is wrong and below there should be a plus sign
varphi_tau=atan2(q(2)-h*alpha_I*q(1)/q_m*I,q(1)+h*alpha_I*q(2)/q_m*I); %direction of the sediment transport modified due to secondary flow [rad]

gsk=gsk_param(1).*thetak.^gsk_param(2).*(dk./h).^gsk_param(3).*(dk./Dm).^gsk_param(4);

varphi_sk=atan2(sin(varphi_tau)-calib_s./gsk*sy,cos(varphi_tau)-calib_s./gsk*sx); %Delft3D %direction of sediment transport modified due to secondary flow and bed slope
% varphi_sk=atan(-1./gsk*(-sin(varphi_tau)*sx+cos(varphi_tau)*sy)); %Siviglia13 %direction of sediment transport modified due to secondary flow and bed slope

%for computational purposes consider the fact that:
%cos(atan(x))=1/sqrt(1+x^2)
%sin(atan(x))=x/sqrt(1+x^2)

varphi_tot=varphi_sk; %D3D
% varphi_tot=varphi_tau+varphi_sk; %Siviglia13

qbkx=qbk.*cos(varphi_tot);
qbky=qbk.*sin(varphi_tot);

Qbkx=Qbk.*cos(varphi_tot);
Qbky=Qbk.*sin(varphi_tot);

%without secondary flow
% qbkx=qbk*q(1)/q_m;
% qbky=qbk*q(2)/q_m;
% 
% Qbkx=Qbk*q(1)/q_m;
% Qbky=Qbk*q(2)/q_m;

end