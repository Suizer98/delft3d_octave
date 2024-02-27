function [WL_t, P] = getWaterlevel(alfa, lambda, Pmin, Pmax, steps)
%GETWATERLEVEL  generate waterlevels based on exponential distribution
%
%   Routine generates a series of waterlevels based on a exponential
%   distribution, to be used in a numerical integration. The exponential
%   distribution is defined by alfa and beta. The probability is confined
%   by Pmin and Pmax and distributed over the predefined number of steps
%   (waterlevel steps are evenly distributed, probability steps non-evenly)
%
%   syntax:
%   [WL_t, P] = getWaterlevel(alfa, lambda, Pmin, Pmax, steps)
%
%   input:
%       alfa    =   coefficient for exponential distribution
%                       (=e^(lambda*epsilon))
%       lambda  =   rate parameter of the exponential distribution (=1/beta)
%       Pmin    =   lower boundary of probability space
%       Pmax    =   upper boundary of probability space
%       steps   =   number of waterlevels in series
%
%
%   See also GETWATERLEVEL_TEST
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.1, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% -------------------------------------------------------------

%% check input
if nargin ~= 5
    error('GETWATERLEVEL:NotEnoughInputs', 'Wrong number of input arguments.');
end
variables = getInputVariables;
inputSize  = getInputSize(variables);
for i = [1 2 5]
    if sum(inputSize(i,:)) == 0 || sum(inputSize(i,:)) > 2 % empty variable or non-single value
        error('GETWATERLEVEL:WrongInputs', ['Variable "',variables{i},'" must be a single value.']);
    end
end
for i = 3:4
    if min(inputSize(i,:)) ~= 1 % Pmin or Pmax is empty or has more than 1 row AND more than 1 column
        error('GETWATERLEVEL:WrongInputs', ['Variable "',variables{i},'" must be either a single value, row array or column array.']);
    end
end
if sum(inputSize(3,:) == inputSize(4,:)) ~= 2 % sizes of Pmin and Pmax are different
    error('GETWATERLEVEL:WrongInputs', ['Size of variable "',variables{3},'" must be equal to size of variable "',variables{4},'".']);
end
if sum(Pmin > Pmax)>0
    error('GETWATERLEVEL:WrongInputs', ['Elements of "',variables{4},'" must be equal or larger than corresponding elements of "',variables{3},'".']);
end
if steps>1 && sum(Pmin == Pmax)>0
    warning('GETWATERLEVEL:VariableAdjust',['Variable "steps" is set to 1 because one or more elements in "',variables{3},'" are equal to the corresponding elements of "',variables{4},'.'])
    steps = 1; % results in WL_t corresponding with Pmin
end

%% characteristics of exponential distribution
epsilon = log(alfa)/lambda; % offset of exponential function
beta = 1/lambda; % Alternate parameterization is used in matlab functions 

%%
WL_tmin = icdf('exp', 1-Pmax, beta) + epsilon; % minimum WL_t (corresponding with Pmax)
WL_tmax = icdf('exp', 1-Pmin, beta) + epsilon; % maximum WL_t (corresponding with Pmin)
deltaWL_t = (WL_tmax-WL_tmin)/steps; % waterlevel difference between two successive steps
if steps == 1
    [WL_t, P] = deal(zeros(size(Pmin))); % preallocation
else
    [WL_t, P] = deal(zeros(steps, length(Pmin))); % preallocation
end
for id = 1:length(Pmin)
    if WL_tmin(id) ~= WL_tmax(id) && steps > 1
        WL_tInterval = WL_tmin(id) : deltaWL_t(id) : WL_tmax(id); % outer boundaries of the waterlevel intervals
        P_Exc = 1-expcdf(WL_tInterval-epsilon, beta); % probability of exceedance for each waterlevel (= 1 - cdf)
        WL_t(:,id) = icdf('exp', 1-(diff(P_Exc)/2+P_Exc(1:end-1)), beta) + epsilon; % waterlevels corresponding with the middle of the probability space of each waterlevel interval
        P(:,id) = -diff(P_Exc); % probability of occurence for each step separatelly
    else
        WL_t(id) = WL_tmin(id); % waterlevel corresponding to the probability of exceendance Pmin
        P(id) = 0; % in case of only on step, probability of occurence is not applicable, or in fact zero
    end
end