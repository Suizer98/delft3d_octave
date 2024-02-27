function [A] = makematrix2(s);
% MAKEMATRIX2 - Creates diffusion matrix in s direction.
%
% Coded: Willem Ottevanger, 02 October 2009

J   = length(s)-1;
ds  = [diff(s)];
f   = ones(size(s));  

%% Build diffusive matrix
A = spalloc(J,J,3*J);

%A(1,end)= 1./(0.5*(ds(2)+ds(1)))*1/ds(1);
%A(1,1)  =-1./(0.5*(ds(2)+ds(1)))*(1/ds(1)+1/ds(2));  %periodic
%A(1,2)  = 1./(0.5*(ds(2)+ds(1)))*1/ds(2);
for k=2:J-1;
    A(k,k-1)= 1./(0.5*(ds(k+1)+ds(k)))*1/ds(k);
    A(k,k)  =-1./(0.5*(ds(k+1)+ds(k)))*(1/ds(k)+1/ds(k+1));
    A(k,k+1)= 1./(0.5*(ds(k+1)+ds(k)))*1/ds(k+1);
end
%k = J;
%A(k,k-1)= 1./(0.5*(ds(1)+ds(k)))*1/ds(k);
%A(k,i)  =-1./(0.5*(ds(1)+ds(k)))*(1/ds(k)+1/ds(1));
%A(k,1)  = 1./(0.5*(ds(1)+ds(k)))*1/ds(1);
