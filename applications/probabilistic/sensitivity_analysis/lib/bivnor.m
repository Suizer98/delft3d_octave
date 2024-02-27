function [y]=bivnor(a,b,rho)
%function [y]=bivnor(a,b,rho)
%
% This function gives an approximation of 
% cumulative bivariate normal probabilities

y = 1-(sum(normcdf([a b])) - mvncdf([a b],[0 0],[1 rho; rho 1]));