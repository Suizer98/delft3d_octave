function [B] = makematrix0(s);
% MAKEMATRIX0 - creates the identity matrix with dimension of s.   
%
% Coded: Willem Ottevanger, 02 October 2009
J = length(s);

B = spalloc(J,J,J);
for i=1:J;
   B(i,i)  = 1;
end 
