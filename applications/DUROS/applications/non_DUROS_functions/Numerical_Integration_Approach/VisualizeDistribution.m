function VisualizeDistribution(name)
%VISUALIZEDISTRIBUTION  routine to plot standard pdf and cdf function
%
%   Routine plots the pdf in the upper panel and the cdf of a figure using
%   the distribution specified by the input variable 'name'. Easy for
%   understanding and explanation purposes.
%   For the time being only the exponential and normal distributions are
%   included, more distributions can be added later.
%
%   syntax:
%   VisualizeDistribution(name)
%
%   input:
%       name            =   string containing distribution function
%                               specification
%
%   example:    VisualizeDistribution('Normal')
%
%
%   See also PDF, CDF, EXPINV, NORMINV
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics / TU Delft 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% -------------------------------------------------------------

%%
p = 0.0002:0.0004:0.9998;

%%
if strcmpi(name,'exp') || strcmpi(name,'Exponential')
    name = 'Exponential'; %#ok<NASGU>
    lambda = 3.01;
    epsilon = 2.2;
    beta = 1/lambda; % Matlab uses the alternate parameterization
    x = expinv(p, beta);
    ypdf = exppdf(x, beta);
    ycdf = expcdf(x, beta);
    x = x + epsilon;
    txt = ['\lambda = ',num2str(lambda),'; \epsilon = ',num2str(epsilon)];
elseif strcmpi(name,'norm') || strcmpi(name,'Normal')
    name = 'Normal'; %#ok<NASGU>
    mu = 0;
    sigma = 1;
    x = norminv(p, mu, sigma);
    ypdf = normpdf(x, mu, sigma);
    ycdf = normcdf(x, mu, sigma);
    txt = ['\mu = ',num2str(mu),'; \sigma = ',num2str(sigma)];
end

%% Visualize
figure('NumberTitle','off',...
    'Name',['Visualisation of ',name,' Distribution'],...
    'Color','w');


subplot(2,1,1)
plot(x, ypdf)
title('Probability Density Function (pdf)')
textposition = axis;
text(textposition(2), textposition(4), txt, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')
grid on

subplot(2,1,2)
plot(x, ycdf)
title('Cumulative Distribution Function (cdf)')
grid on
