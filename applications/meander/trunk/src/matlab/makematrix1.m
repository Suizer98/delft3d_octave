function [F] = makematrix2(s);
% MAKEMATRIX1 - Creates advection matrix in s direction.
%
% Coded: Willem Ottevanger, 02 October 2009

J   = length(s)-1;
ds  = diff(s);

%% Build advective matrix
F = spalloc(J,J,2*(J));

%    F(1,1)     =  f(1)/ds(1);
%    F(1,J+1)   = -f(1)/ds(1);  %periodic.
for i=2:J;
   F(i,i)  =  1/ds(i);
   F(i,i-1)= -1/ds(i);
end
%    F(1,:) = 0;     %Boundary conditions at start
