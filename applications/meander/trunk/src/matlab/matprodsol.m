function [x] = matprodsol(a,b,c,d);
%%MATPRODSOL - Function solves Ad=x for x 
% Usage : [x] = matprodsol(a,b,c,d);
% a = off-left diagonal
% b = main diagonal 
% c = off-right diagonal
% d = vector.
% x = righthand side
%
% ------------------------------------
%    Willem Ottevanger, Delft University of Technology
%    30 december 2010
% ------------------------------------
n = length(d);
x = zeros(n,1);

x(1) =               b(1)*d(1) + c(1)*d(2);
for j = 2:n-1
x(j) = a(j)*d(j-1) + b(j)*d(j) + c(j)*d(j+1);
end
x(n) = a(n)*d(n-1) + b(n)*d(n);
