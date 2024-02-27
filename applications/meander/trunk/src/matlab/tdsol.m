function [x] = tdsol(a,b,c,d);
%%TDSOL - Function solves Ax=d for x using Thomas algorithm 
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
%Modify the coefficients
c(1) = c(1)/b(1); %Division by zero risk -> would imply a singular matrix.
d(1) = d(1)/b(1); 
for j = 2:n
    id   = b(j)-c(j-1)*a(j);
    c(j) = c(j)/id;
    d(j) =(d(j)-d(j-1)*a(j))/id;
end
%Now back substitution
x(n) = d(n);
for j = n-1:-1:1
    x(j) = d(j) - c(j)*x(j+1);
end
x = x(:);