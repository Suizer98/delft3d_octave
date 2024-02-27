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
%$Id: get_hydrodynamic_modes.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_hydrodynamic_modes.m $
%
%ini_spacem approximates the alternating steady equilibrium profile using the space marching algorithm
%
%[u,h,etab,qb,Fak] = ini_spacem(input,fid_log,bc)
%
%INPUT:
%
%OUTPUT:
%   
%         K [1x1 double] [-]: number of hydrodynamic modes
%         dq [Kx1 double] [m2/s]: discharges per mode
%         dH [Kx1 double] [m]: downstream water surface elevation per mode
%         pq [Kx1 double] [-]: mode probabilities
% 
%         ia [Kx1 double] 
%         ic [yx1 double]
% 
%         qw: [yx1 double] [m2/s] time series of discharges (for reconstruction; basically the bcs
%         but with different temporal resolution)
%         H: [yx1 double] [m2/s] time series of discharges (for reconstruction; basically the bcs
%         but with different temporal resolution)
%
%HISTORY:
%170727
%   -L. Created for the first time; modulization of ini_spacem and consistency checks for good! 

function [dq,dH,pq,K,ia,ic,qw, H] = get_hydrodynamic_modes(input,bc)
%% Set time resolution
try
    dT = input.ini.sp.dT;
catch
    dT = 3600*24; %default value for timestep in time-reconstruction 
end
ratiodt = dT/input.mdv.dt;


%% CONSTRUCTION
% Upstream BCS
qw = bc.q0;             % [m2/s]

% Downstream BCS
switch input.bch.dotype
    case 3 %Normal flow boundary condition
        t_end = numel(qw);
        qw = qw(1:ratiodt:t_end); 

        bcmat = qw;
        [C, ia,ic] = unique(bcmat, 'rows');

        dq = C(:,1);
        K = numel(dq);

        [pq, ~] = hist(ic,numel(ia));
        pq = pq'./numel(ic);
        dH = [];
        H = [];

    otherwise % User defined downstream condition
        % Downstream BCS: Check whether downstream flow depth should be considered as the boundary
        % condition or not..
        if isfield(input.ini,'sp')
            if isfield(input.ini.sp,'etaw0')
                bc.etaw0 = [input.ini.sp.etaw0; input.ini.sp.etaw0];
            end
        end

        repfac =round(numel(bc.q0)./numel(bc.etaw0));
        if repfac>1
            H = repmat(bc.etaw0,ceil(repfac),1);
        else
            H = bc.etaw0;
            qw = repmat(qw,ceil(1/repfac),1);
        end

        t_end = min(numel(H),numel(qw));
        H = H(1:ratiodt:t_end); 
        qw = qw(1:ratiodt:t_end); 

        bcmat = [qw, H];
        [C, ia,ic] = unique(bcmat, 'rows');

        dq = C(:,1);
        dH = C(:,2);  
        K = numel(dq);

        [pq, ~] = hist(ic,numel(ia));
        pq = pq'./numel(ic);
end
end