function s = sampleDG(gamma, rho, nsamples)

% Code from the paper: 'Generating spike-trains with specified
% correlations', Macke et al., submitted to Neural Computation
%
% www.kyb.mpg.de/bethgegroup/code/efficientsampling

% sample Gaussian
t = mvnrnd(gamma,rho,nsamples)';

% apply dichotomization
s = (t>0);







