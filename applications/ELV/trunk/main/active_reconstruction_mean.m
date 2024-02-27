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
%$Id: active_reconstruction_mean.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/active_reconstruction_mean.m $
%
%active_reconstruction_mean ...
%
%\texttt{[eta, Fak] = active_reconstruction_mean(Qb_down,Qb_up,eta_mean,Fak_mean,input,dx,dT,B)}
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170613
%   -V. Forced Liselot to add a header

function [eta, Fak] = active_reconstruction_mean(Qb_down,Qb_up,eta_mean,Fak_mean,input,dx,dT,B,ic)   
    if numel(input.sed.dk)<2
        Fak = NaN;
        eta_t0 = eta_mean;
        
        % Construct time series bed elevation
        %dqbdx = -(Qb_up-Qb_down)/dx;        
        %detadt = -1/(1-input.mor.porosity)*dqbdx*dT;
        
        % Construct time series bed elevation
        dQbdx = -(Qb_up-Qb_down)/dx;
        detadt = -1/(B*(1-input.mor.porosity))*dQbdx*dT;
        
        
        % Get full series
        detadt = detadt(ic);        
        
        % Reconstruct
        %eta = [eta_t0; eta_t0+cumsum(detadt)];
        
        eta = [0; cumsum(detadt)];                   
        mean_eta = mean(eta);
        eta = eta_mean + eta - mean_eta;
        
        
        
    else
        % Total transport
        Qb_downt = sum(Qb_down,2); 
        Qb_upt = sum(Qb_up,2); 

        % Construct time series bed elevation
        dQbdx = -(Qb_upt-Qb_downt)/dx;
        detadt = -1/(B*(1-input.mor.porosity))*dQbdx*dT;

        % Get full series
        dQbdx = dQbdx(ic);
        detadt = detadt(ic);
        
        for j=1:numel(Fak_mean)
            fkI = Fak_mean(j);
            dQbkdx = -(Qb_up(:,j)-Qb_down(:,j))/dx;
            % Get full series
            dQbkdx = dQbkdx(ic);

            dFakdt = -fkI./input.mor.La(1,1).*detadt-1/(B*(1-input.mor.porosity))*dQbkdx*dT;
            Faktemp = [0; cumsum(dFakdt)];
            mean_Fak = mean(Faktemp);
            Fak(:,j) = Fak_mean(j) + Faktemp - mean_Fak;
        end
        eta = [0; cumsum(detadt)];                   
        mean_eta = mean(eta);
        eta = eta_mean + eta - mean_eta;

    end
end