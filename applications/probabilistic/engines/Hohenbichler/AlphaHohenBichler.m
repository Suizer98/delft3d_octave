function [alphaNew, betaNew] = AlphaHohenBichler(alphas, betas, rhos, system, method, varargin)

% the Hohenbichler method for computing P(Z2<0 OR/AND Z1<0) and the equivalent
% alpha-values of the variables of the new Z-function

% Z1 and Z2 are both described by the same n random variables u1 ... un
% however, corresponing u-values of Z1 and Z2 are not fully correlated. The
% mutual correlation is described by random variable rho

% Input
%   - alphas: 2xn alpha-values
%   - betas: 2 beta-values
%   - rhos: n rho-values
%   - system: type of system ('parallel' or 'series') string
%   - method: 'Numerical'(default) or 'FORM'
%   - Nomryn: yes/no (1/0) normalisation of alpha-values
%
% Output
%   - alphaNew: alpha of the combined Z-function
%   - betaNew:  beta of the combined Z-function


% number of variables and Z-functions involved
[nZ,nVar] = size(alphas);
if nZ~=2
    error('method only works with two Z-functions variables')
end
[alphaNew, alpha1, alpha2]=deal(NaN(1,nVar));

% derive beta of [Z1 OR Z2]
if strcmp(system,'series')
        betaNew = BetaHohenBichler(alphas, betas, rhos, method);
elseif strcmp(system,'parallel')
        [~,betaNew] = BetaHohenBichler(alphas, betas, rhos, method);
else
     disp('Invalid value (1/3)')
end

epsilon=0.01;

for j=1:nVar

    % perturbation of ui and its effect on beta.
    betasTemp=betas;

    % [1] determine alpha-value for correlated part

    % [1a] perturbation of beta-values
    betasTemp(1)= betas(1)+alphas(1,j)*epsilon;
    betasTemp(2)= betas(2)+alphas(2,j)*epsilon*rhos(j);

    % [1b] Hohenbichler computation with perturbed beta-values
if strcmp(system,'series')
         betaj1 = BetaHohenBichler(alphas, betasTemp, rhos, method);
elseif strcmp(system,'parallel')
        [~,betaj1] = BetaHohenBichler(alphas, betasTemp, rhos, method);
else
     disp('Invalid value (2/3)')
     break
end

    % [1c] compute equivalent alpha-value for correlated part
    alpha1(j) = (betaj1-betaNew)/epsilon;

    % [2] determine alpha-value for uncorrelated part

    % [2a] pertutbation of beta-values
    betasTemp(1)= betas(1);
    betasTemp(2)= betas(2)+alphas(2,j)*epsilon*sqrt(1-rhos(j)^2);

    % [2b] Hohenbichler computation with perturbed beta-values
if strcmp(system,'series')
         betaj2 = BetaHohenBichler(alphas, betasTemp, rhos, method);
elseif strcmp(system,'parallel')
        [~,betaj2] = BetaHohenBichler(alphas, betasTemp, rhos, method);
else
     disp('Invalid value (3/3)')
     break
end

    % [2c] compute equivalent alpha-value for correlated part
    alpha2(j) = (betaj2-betaNew)/epsilon;

end

% combine alpha-values of correlated and uncorrelated part
% make sure the sign is the same as the original alphas!!!!!!
alphaNew = sign(alpha1).*sqrt(alpha1.^2 + alpha2.^2);

% normalisation
alphaNew = alphaNew/sqrt(sum(alphaNew.^2));

