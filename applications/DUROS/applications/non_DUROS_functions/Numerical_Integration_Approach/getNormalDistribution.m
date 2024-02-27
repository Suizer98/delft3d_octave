function distribution = getNormalDistribution(mu, sigma, steps)
%GETNORMALDISTRIBUTION  routine to get a normal distribution in discrete steps
% 
% This routine returns a specified number of discrete steps of a normal
% distribution. Each step corresponds with a probability of 1/steps
%
% Syntax:       distribution = getNormalDistribution(mu, sigma, steps)
%
% Input:
%   mu      =   mean of normal distribution
%   sigma   =   standard deviation of normal distribution
%   steps   =   number of discrete steps to express the normal distribution in
%
% Output:       Eventual output is row array containing the discrete steps
%                   of the normal distribution
%
% Examples:     getNormalDistribution(0, 1, 5)
%               ans =
%                   -1.2816   -0.5244         0    0.5244    1.2816
%
%   See also norminv
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------
%%
P = 1/(2*steps) : 1/steps : 1;

distribution = norminv(P, mu, sigma);

% distribution = icdf('Normal',P, mu, sigma);