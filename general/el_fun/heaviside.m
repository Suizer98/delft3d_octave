function H = heaviside(x)
%HEAVISIDE  The heaviside step function.
%
%   0 for x <  0
%   1 for x >= 0

H      = sign(x);
H(H<0) = 0;

% NOTE: The NEXT IS WRONG
% H      = .5 + sign(x)./2;
% BECAUSE THAT IS 0.5 for x=0, INSTREAD OF 1.0 !!
