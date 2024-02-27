function [gamma rho] = initDG (mu,Sigma,acc)

% Code from the paper: 'Generating spike-trains with specified
% correlations', Macke et al., submitted to Neural Computation
%
% www.kyb.mpg.de/bethgegroup/code/efficientsampling

if ~exist('acc','var')
    acc=10^-8;
end

mu=mu(:);
Sigma=nearestSPD(Sigma);
[gamma, rho] = findLatentGaussian(mu,Sigma,acc);

end
