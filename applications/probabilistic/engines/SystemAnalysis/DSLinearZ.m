function [beta, Pf] = DSLinearZ(alphas, betas, N)
% function for combining a series system of m linear Z-functions, that are functions of n
% variables u1.. un. Variables are the same for each Z-function, i.e.
% Zi = betai+alpha_i1*u_1+...+alpha_in*u_n
% This means correlation between variable ui of function Zj and variable ui of function Zk =1
% The combining method is directional sampling with an exact (analytical) search
% function for crossings with Z=0

% assumed form of z-function: Zi = betai+alphai1*u1+...+alphain*un
% dimensions: m Z-functions and n random variables

% Input
%   alphas:  alphas of all z-functions (dimension: m * n)
%   betas:   corresponding betas (dimension: m*1)
%   N:       number of samples 

% Output
%   reliability (beta) and failure probability (Pf) of the system

%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares 
%       F.L.M. Diermanse
%
%       Ferdinand.diermanse@Deltares.nl	
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
[~,n]=size(alphas);

% deal with memory issues
if n*N<=1e8
    [beta, Pf] = DSLinearZ2(alphas, betas, N);
else
   % carry out DS several times for smaller values of N
   nbatch = ceil(n*N/1e8);
   batchsize = round(N/nbatch);
   Pfj = NaN(1,nbatch);
   for j = 1:nbatch
       [~, Pfj(j)] = DSLinearZ2(alphas, betas, batchsize);
   end
   Pf = mean(Pfj);
   beta = -wnorminv(Pf);        % corresponding beta
   
end

%% function where the actual DS takes place
function [beta, Pf] = DSLinearZ2(alphas, betas, N)

% sample N vectors of u-variables;
[~,n]=size(alphas);
U = randn(N,n);

% normalise the N vectors
% each normalised vector represents a sampled direction
Norm = sqrt(sum(U.*U,2));
Unorm = U./repmat(Norm,1,n);

%% compute distance to failure area for each sampled direction
dist2Fail = -repmat(betas',N,1)./(Unorm*alphas'); % distance per Z-function
dist2Fail(dist2Fail<0)=inf;  % negative distance means: no failure in current direction
mindist2Fail = min(dist2Fail,[],2); % minimum over all Z-functions

%% compute failure probability
Pfdir = 1-chi2_cdf(mindist2Fail.^2,n);  % P(failure | sampled direction)
Pf = sum(Pfdir)/N;           % mean failure probability over all directions 
beta = -wnorminv(Pf);        % corresponding beta

% %% compare with MC
% % compute Crude MC beta
% Z = repmat(betas',N,1)+(U*alphas');  % Z-values for each u-vector
% fail = any(Z<0,2);       % for each u-vector: check if Z<0 for any Z-fucntion 
% PfMC = sum(fail)/N;      % percentage of u-vectors in failure area
% betaMC = -wnorminv(PfMC);  % corresponding beta
% 
% % convergence plot
% figure; hold on; grid on;
% plot(1:N,-wnorminv(cumsum(fail')./(1:N)),'r-');
% plot(1:N,-wnorminv(cumsum(Pfdir')./(1:N)),'b-');
% legend('crude MC', 'DS');
% ylabel('beta');
% xlabel('nr. of samples');
% set(gca,'xscale','log');


