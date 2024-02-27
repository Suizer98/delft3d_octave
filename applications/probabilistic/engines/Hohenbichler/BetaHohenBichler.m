function [betaOR, betaAND] = BetaHohenBichler(alphas, betas, rhos, method)

% the Hohenbichler method for computing P(Z1<0 OR PZ2<0) and P(Z1<0 AND
% PZ2<0). both Z-functions are described by the same n random variables u1 ... un
% however, corresponing u-values of Z1 and Z2 are not fully correlated. The
% mutual correlation is described by random variable rho

% Input
%   - alphas: 2xn alpha-values
%   - betas: 2 beta-values
%   - rhos: n rho-values
%   - method: 'Numerical'(default) or 'FORM'
%
% Output
%   - betaOR:    beta for P[Z1<0 OR Z2<0] Serial system
%   - betaAND:   beta for P[Z1<0 AND Z2<0] Parallel system


%% dimensions and checks
if isequal(size(betas),[1,2])
    betas=betas';
    if size(alphas,2)==2
        alphas=alphas';
        warning('matrix with alphas has been inverted to match dimensions of vector with betas');
    end
end
if ~isequal(size(betas),[2,1])
    error('vector "betas" should be a 2 by 1 vector');
end
if size(alphas,1)~=2
    error('matrix with "alphas" should be a 2 by n vector');
end

%% computation of P(Z2<0 | Z1<0)

% make sure beta2 is the smallest beta value
if betas(2)>betas(1)
    betas=flipud(betas);
    alphas=flipud(alphas);
end
pf=1-normcdf(betas(1));

% correlation between the two Z-functions
rho = sum(alphas(1,:).*alphas(2,:).*rhos);

[betaOR, betaAND] = HohenBichler(betas(2), pf, rho, method);


