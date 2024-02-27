function [L,e,c] = wavelength(T,d,alpha,U,delta,tol)
%WAVELENGTH Solves the dispersion relation for ocean surface waves numerically
%
% USAGE:
%   [L,e,c] = wavelength(T,d,U,delta,alpha,tol)
%
% DESCRIPTION:
%   Simple program that solves the 
%   dispersion relation for ocean
%   surface waves using the
%   Newton-Raphson method
%   It can also account for wave-current
%   interaction by solving a modified form
%   of the dispersion relation proposed be
%   Jonsson (1970)
%
% INPUT VARIABLES:
%   T = Wave Period, (seconds)
%   d = Water Depth, (m)
%   U = Current Velocity, (m/s)
%   delta = direction of current (rad) with 
%       respect to the cross-shore direction
%   alpha = direction of waves (rad) with
%       respect to the cross-shore direction      
%   tol = Maximum tolerance allowed for L
%       the default is 1e-6 (Generally 3 iterations)
%
% OUTPUT VARIABLES:
%   L = Wave length, (m)
%   e = Relative error of L
%   c = Iteratios
%
% NOTES:
%   For deep water - L = g*T^2/2/pi
%   For shallow water - L = T*sqrt(gd)
%
% REFERENCES
% Eckart, C. (1952) The Propagation of Gravity 
%   Waves From Deep to Shallow Water, Natl. Bur. Standards,
%   Circular 521, Washington, DC, pp 165-173.
%
% Jonsson, I.G., Skougaard, C., and Wang, J.D. (1970)
%   Interaction between waves and currents, Preceedings 
%   of the 12th Coastal Engineering Conference,
%   ASCE, 489-507
%
% wavelength comes from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/10557">Mathworks download central</a>, for copyright: edit plotc.
%
% nargin==0 runs a demo
%
% See also: GADE1958, WAVEDISPERSION

%% Version
% 2009 jun 22: downloaded from: http://www.mathworks.com/matlabcentral/fileexchange/10557
% 2009 jun 22: improved documentation to OpenEarth standard

%% Copyright:
%  Copy-Left, Alejandro Sanchez

%% Input
g = 9.81; %gravity
if nargin==0
    T = 15:0.01:18; 
    d = 8;
    U = 0.5; %m/s
    delta = 90*pi/180; %rad
    alpha = 10*pi/180; %rad
end
if nargin<5
    delta = 0.5*pi; %90 deg
end
if nargin<6
    tol = 1e-6;
end

%This is useful only in some cases
% if any(size(T)~=size(d))
%     if nargin==2
%         [T,d] = meshgrid(T,d);
%     else
%         [T,d,alpha,U,delta] = ndgrid(T,d,alpha,U,delta);
%     end
% end


%% First approximation is made with the 
%  eq. given by Eckart (1952) which gives ~10% error

Lo =                         g*T.^2./2./pi; %deep water wave length
L  = Lo.*sqrt(tanh(4*pi.^2.*d./T.^2./g));
e  = L; %Initialize error
c  = 0; %counter

%% Newton-Raphson method
if nargin==2
    while any(e>tol)
        c  = c + 1;
        k  = 2*pi./L;
        a  =    Lo.*   tanh(k.*d) - L;
        b  = -2*Lo.*(1-tanh(k.*d).^2)*pi./L.^2.*d-1;
        L2 = L - a./b;
        e  = abs(L2-L);
        L  = L2;
    end
else
    while any(e>tol)
        c  = c + 1;
        k  = 2*pi./L;
        a  =             Lo.*tanh(k.*d)./sqrt(1-U.*cos(delta-alpha).*T./L) - L;
        b  = -1/2*(-4*Lo.*pi.*d.*L+4*Lo.*pi.*d.*U.*cos(delta-alpha).*T ...
                               -Lo.*sinh(k.*d).*U.*cos(delta-alpha).*T         .*L.*cosh(k.*d) ...
                                 -2*L.^3.*(-(-L+U.*cos(delta-alpha).*T)./L).^(1/2).*cosh(k.*d).^2 ...
                                 +2*L.^2.*(-(-L+U.*cos(delta-alpha).*T)./L).^(1/2).*cosh(k.*d).^2 ...
                                              .*U.*cos(delta-alpha).*T)./...
                                            (-L+U.*cos(delta-alpha).*T)./L.^2 ...
                                        ./(-(-L+U.*cos(delta-alpha).*T)./L).^(1/2)./cosh(k.*d).^2;
        L2 = L - a./b;
        e  = abs(L2-L);
        L  = L2;
    end
end
