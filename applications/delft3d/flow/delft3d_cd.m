function Cd = delft3d_cd(U10,varargin)
%DELFT3D_CD   wind drag as function 4 coefficients
%
%   Cd = delft3d_cd(U10)
%   Cd = delft3d_cd(U10,<U10a,<U10b,<Cda,<Cdb>>>>)
%
%   where the Delt3D-FLOW-GUI defaults are used:
%
%   U10a = 0;
%   U10b = 100;
%   Cda  = 0.00063;
%   Cdb  = 0.00723;
% 
%   vectorized for U10
%
%See also: 

Cd = nan.*zeros(size(U10));

% test
U10a = 20;
U10b = 50;
Cda  = 1;
Cdb  = 2;

% Delft3d default
U10a = 0;
U10b = 100;
Cda  = 0.00063;
Cdb  = 0.00723;

if nargin > 2
   U10a = varargin{1};
end
if nargin > 3
   U10b = varargin{2};
end
if nargin > 4
   Cda  = varargin{3};
end
if nargin > 5
   Cdb  = varargin{4};
end

maska     = (U10 < U10a);
maskb     = (U10 > U10b);
mask      = ~(maska | maskb);

Cd(maska) = Cda;
Cd(maskb) = Cdb;
Cd(mask)  = Cda + (Cdb - Cda).*(U10(mask) - U10a)./(U10b - U10a);
