function [alphas, betas] = HohenbichlerMultiElement(alphasIn, betasIn, rhos, system, method, varargin)
%Hohenbichler routine (combined probability of failure)
%
% function for combining Z-functions of n elements in Series or Parallel
%   P(Z2<0 AND Z1<0) = P(Z2<0 && Z1<0) = Parallel system
%   P(Z2<0 OR Z1<0) = P(Z2<0 || Z1<0) = Serial system
% and subsequent processing of alpha's and beta's (i.e. replacing the old 
% values with the new values)

%dimensions: m elements and n random variables

% alphasIn:  alphas of all z-functions (dimension: m * n)
% betasIn:   corresponding betas (dimension: m*1)
% rhos:      correlation coefficients of u-valuues (dimensions: 1*n)
% system:    type of system ('parallel' or 'series') string
% method:    'Numerical'(default) or 'FORM'
%
%%
[alphas, betas] = deal(alphasIn, betasIn);

% dimensions
Ne = size(alphasIn,1);

%% start combining elements, two at the time

while Ne>1

    % select elements to be combined
    %Rhomatrix = (repmat(rhos,Ne,1).*alphas)*alphas';
    Rhomatrix = alphas*alphas';
    Rhomatrix = Rhomatrix - 10*eye(Ne);
    maxcorr = max(max(Rhomatrix));
    [n1,n2] = find(Rhomatrix==maxcorr,1,'first');

    % combine two Z-functions (highest rho) and derive asociated alpha's and beta
    if isempty(varargin)
        [alphasNew, betaNew] = AlphaHohenBichler(alphas([n1 n2],:), betas([n1 n2]), rhos , system, method);
    else
        [alphasNew, betaNew] = AlphaHohenBichler(alphas([n1 n2],:), betas([n1 n2]), rhos, system, method, 1);
    end
    % remove old alphas and betas, include new ones
    alphas(n1,:)=alphasNew;
    betas(n1)=betaNew;
    alphas(n2,:)=[];
    betas(n2)=[];
    Ne = size(alphas,1);
    


end
