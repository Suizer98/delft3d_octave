function [kcs] = detkcs(x ,y , mv)
%
% Bepaalt kcs op basis van x,y en missingvalue

nmax = size(x,1);
mmax = size(x,2);

kcs(1:nmax,1:mmax) = 0;

for n = 2 : nmax
   for m = 2 : mmax
      if x(n,m) ~= mv && x(n-1,m) ~=mv && x(n,m-1)~= mv && x(n-1,m-1)~=mv
         kcs(n,m) = 1;
      end
   end;
end;

