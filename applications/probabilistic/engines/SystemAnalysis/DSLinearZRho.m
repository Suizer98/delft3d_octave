function [beta, Pf] = DSLinearZRho(alphas, betas, rhos, N)
% function for combining a series system of m linear Z-functions, that are functions of n
% variables u1.. un. Variables are differnt for each Z-function, i.e.
% Zi = betai+alpha_i1*u_i1+...+alpha_in*u_in
% Corresponding variables of different Z-functions (uij and ukj) are correlated
% the correlation between (uij and ukj) is equal to rho_j (input)
% The combining method is directional sampling with an exact (analytical) search
% function for crossings with Z=0

% dimensions: m Z-functions and n random variables per Z-function, which means
% there are in total mxn random variables

% Input
%   alphas:  alphas of all z-functions (dimension: m * n)
%   betas:   corresponding betas (dimension: m*1)
%   rhos:    vector with correlations (dimension: 1*n)
%   N:       number of samples 

% Output
%   reliability (beta) and failure probability (Pf) of the system

%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares 
%       F.L.M. Diermanse
%
%       Fedrinand.diermanse@Deltares.nl	
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------



%% sample directions
% dimensions of alpha
[m,n]=size(alphas);

% sample N matrices (mxn) of u-variables;
U = randn(N,m,n);

% derive norm of U
NormU = sqrt(sum(sum(U.*U,3),2));

%% apply with corelation; loop over n variables
Ucorr = NaN(size(U));  % memory allocation
for j=1:n
    
    % correlation matrix for current variable
    C = rhos(j)*ones(m)+(1-rhos(j))*eye(m);
    
    % apply correlation
    Ucorr(:,:,j) = ApplyCorrelation(U(:,:,j),C);
  
end 
clear U;  

% normalise the correlated U and multiply with alfas
A = NaN(size(Ucorr)); 
for j=1:n    
    A(:,:,j) = repmat(alphas(:,j)',N,1).*Ucorr(:,:,j)./repmat(NormU,1,m);
end
A = sum(A,3); % sum alphai*ui
clear Ucorr NormU

%% compute distance to failure area for each sampled direction
dist2Fail = -repmat(betas',N,1)./A; % distance per Z-function 
dist2Fail(dist2Fail<0)=inf;  % negative distance means: no failure in current direction
mindist2Fail = min(dist2Fail,[],2); % minimum over all Z-functions

%% compute failure probability
Pfdir = 1-chi2_cdf(mindist2Fail.^2,n*m);  % P(failure | sampled direction)
Pf = sum(Pfdir)/N;           % mean failure probability over all directions 
beta = -wnorminv(Pf);        % corresponding beta


% %% convergence plot
% figure; hold on; grid on;
% plot(1:N,-wnorminv(cumsum(Pfdir')./(1:N)),'b-');
% ylabel('beta');
% xlabel('nr. of samples');
% set(gca,'xscale','log');