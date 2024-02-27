function [gsqs] = detare(x ,y , varargin)
%
% Bepaalt oppervlakken

if nargin == 3
   new = varargin{1};
else
   new = false;
end

nmax = size(x,1);
mmax = size(x,2);

for n = 2 : nmax
   for m = 2 : mmax
      if ~new
         %
         % Delft3d-Flow
         %
         a1x = x(n-1,m-1);
         a3x = x(n  ,m-1);
         a2x = x(n-1,m  );
         a4x = x(n  ,m  );

         a1y = y(n-1,m-1);
         a3y = y(n  ,m-1);
         a2y = y(n-1,m  );
         a4y = y(n  ,m  );

         l1 = sqrt((a1x-a2x).^2+(a1y-a2y).^2); l2 = sqrt((a3x-a4x).^2+(a3y-a4y).^2);
         l3 = sqrt((a1x-a3x).^2+(a1y-a3y).^2); l4 = sqrt((a2x-a4x).^2+(a2y-a4y).^2);

         gsqs(n,m) = ((l1+l2)/2)*((l3+l4)/2);

         clear a1x a2x a3x a4x a1y a2y a3y a4y l1 l2 l3 l4;
      else
         %
         % Oppervlak volgens schoenveter (shoelace) formule
         %
         xx(1) = x(n-1,m-1);yy(1) = y(n-1,m-1);
         xx(2) = x(n  ,m-1);yy(2) = y(n  ,m-1);
         xx(3) = x(n  ,m  );yy(3) = y(n  ,m  );
         xx(4) = x(n-1,m  );yy(4) = y(n-1,m  );
         gsqs(n,m) = shoelace (xx,yy);
      end
   end
end

function [gsqs] = shoelace(x,y)

gsqs    = 0.0;
npoints = length(x);


%
% Original (quasi fortran)
%
%
%for ipoint = 1: npoints
%   gsqs = gsqs + x(ipoint)*y(mod(ipoint,npoints)+1) - x(mod(ipoint,npoints)+1)*y(ipoint);
%end
%
%
% More matlab like
%

x(npoints+1) = x(1);
y(npoints+1) = y(1);

gsqs = sum(x(1:npoints).*y(2:npoints+1)) - sum(x(2:npoints+1).*y(1:npoints));

gsqs = abs(0.5*gsqs);

function [gsqs] = hk      (x,y)

gsqs    = 0.0;
npoints = length(x);

%
% Uit unstruc (alleen cartesische coordinaten)
%

x(npoints+1) = x(1);
y(npoints+1) = y(1);

y0 = min(y);

for ipoint = 1: npoints
   dx   = x(ipoint + 1) - x(ipoint);
   yy    = 0.5*(y(ipoint + 1) + y(ipoint)) - y0;
   gsqs = gsqs + dx*yy;
end
