function [Xcen,Ycen] = det_cen(X,Y,icom)

% det_cen: Determine coordinates of cell centres (zeta points)

%
%  Determine coordinates of cell centres (zeta points)
%

Xcen(1:size(X,1),1:size(X,2)) = NaN;
Ycen(1:size(X,1),1:size(X,2)) = NaN;

for m = 1: size(X,1)
   for n = 1: size(X,2)
      if icom(m,n) == 1
         Xcen(m,n) = 0.25*(X(m  ,n  ) + X(m-1,n  ) + ...
                           X(m  ,n-1) + X(m-1,n-1) );
         Ycen(m,n) = 0.25*(Y(m  ,n  ) + Y(m-1,n  ) + ...
                           Y(m  ,n-1) + Y(m-1,n-1) );
      end
   end
end

