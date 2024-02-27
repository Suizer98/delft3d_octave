function [P P_corr] = prob_is_x(P, ISF)
% PROB_IS_x  Importance sampling method based on sampling of
% actual (x) values instead of probabilities (P) or standardised
% normally distributed (u) values.
%
% input
%   P: probabilities (standard uniform random samples)
%   ISF: structure with distribution functions (explained below)
%
% output
%   P         = Modified vector with random draws
%   P_corr    = Correction factor for probability of failure computation
%
% This module uses the following four distribution functions:
%
% [1] inverse cdf H^(-1)(x) of the importance sampling distribution
% [2] cdf F(x) of the actual distribution
% [3] density h(x) of the importance sampling function
% [4] density f(x) of the actual distribution function
%
% This information is stored in ISF, a 4x1 structure with fields 'Distr'
% and 'Params', describing the names and parameters of the functions above.
% The user can define ISF in two ways: The first is to completely perpare the 
% make the 4x1 structure and fill the field. The second option is to make a 2x1
% structure with the names and parameters of the importance sampling function (H)
% and the actual distribution function (F). The module below will then turn
% it into the requested 4x1 structure, by adding strings like '_inv', '_cdf'
% and '_pdf'. This means the input structure initially has to contain names like 'norm'
% (normal distribution function) i.e. names without strings like '_inv', '_cdf'
%
% example input type 1:
% ISF(1).Distr = @norm_inv; ISF(1).Params = {2 3};  
% ISF(2).Distr = @gev_cdf;  ISF(2).Distr = {1 2 3};  
% ISF(3).Distr = @norm_pdf; ISF(3).Params = {2 3};  
% ISF(4).Distr = @gev_pdf;  ISF(4).Distr = {1 2 3};  
%
% example input option 2:
% ISF(1).Distr = @norm; ISF(1).Params = {2 3};  
% ISF(2).Distr = @gev;  ISF(2).Distr = {1 2 3};  

%% deal with input structure

% in case the input is 2x1, make it 4x1
if length(ISF) == 2
    ISF(3).Distr = str2func([func2str(ISF(1).Distr) '_pdf']);  ISF(3).Params = ISF(1).Params; 
    ISF(4).Distr = str2func([func2str(ISF(2).Distr) '_pdf']);  ISF(4).Params = ISF(2).Params;
    ISF(1).Distr = str2func([func2str(ISF(1).Distr) '_inv']);  
    ISF(2).Distr = str2func([func2str(ISF(2).Distr) '_cdf']);
end

% check if parameters are consistent
if ~isequal(ISF(3).Params, ISF(1).Params) || ~isequal(ISF(4).Params, ISF(2).Params)
    error('inconsistency in parameter values');
end
        
%% start computations

% Importance samples
X = feval(ISF(1).Distr, P, ISF(1).Params{:});

% Derive prob. of non-exceedance of X with actual cdf
P = feval(ISF(2).Distr, X, ISF(2).Params{:});

% Derive correction factors for importance sampling
P_corr = feval(ISF(4).Distr, X, ISF(4).Params{:})./feval(ISF(3).Distr, X, ISF(3).Params{:});

