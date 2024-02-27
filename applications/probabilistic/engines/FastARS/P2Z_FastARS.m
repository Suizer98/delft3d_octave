function Z = P2Z_FastARS(varargin)

% input
%    structure with samples (probabilities)
%    structure with parameters of the Z-function 
%
% output
%    Z-value(s)


U = cell2mat(varargin(2:2:end-2));
Z = polyvaln(varargin{end}.fit,U);



