function [f1 S1 f2 S2] = xb_plot_klopman(varargin)
%XB_PLOT_KLOPMAN  Plots LF spectrum based on HF spectrum
%
%   Implementation of the Klopman and Dingemans (2000) paper based on the
%   original secspecorg function made by Ap van Dongeren in 2001. The
%   function computes a low-frequency spectrum from a JONSWAP spectrum.
%
%   Syntax:
%   varargout = xb_plot_klopman(varargin)
%
%   Input:
%   varargin  = Hm0:        significant wave height
%               fp:         peak frequency
%               df:         frequency resolution
%               gamma:      peak-enhancement factor
%               h:          water depth
%               s:          directional spreading
%               K:          number of wave components
%               ntheta:     number of directions
%               g:          gravitational acceleration
%               plot:       boolean flag to enable plotting
%
%   Output:
%   f1        = LF frequencies
%   S1        = LF energy density
%   f2        = HF frequencies
%   S2        = HF energy density
%
%   Example
%   xb_plot_klopman;
%   xb_plot_klopman('Hm0', 9, 'fp', 14);
%
%   See also xb_plot_spectrum

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_plot_klopman.m 5345 2011-10-17 13:53:29Z hoonhout $
% $Date: 2011-10-17 21:53:29 +0800 (Mon, 17 Oct 2011) $
% $Author: hoonhout $
% $Revision: 5345 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_plot_klopman.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'Hm0',      4, ...
    'fp',       0.091,      ...
    'df',       0.0016,     ...
    'fnyq',     0.3,        ...
    'gamma',    3.3,        ...
    'h',        8,          ...
    's',        256,        ...
    'K',        400,        ...
    'ntheta',   100,        ...
    'g',        9.81,       ...
    'plot',     true        ...
);

OPT = setproperty(OPT, varargin{:});

%% prepare computation

fin     = OPT.df:OPT.df:OPT.fnyq;
y       = jonswap(fin/OPT.fp, OPT.gamma);
hm0     = 4*sqrt(sum(y)*OPT.df);
y       = (OPT.Hm0/hm0)^2*y;

ang     = -pi:pi/OPT.ntheta:pi-pi/OPT.ntheta;
noang   = length(ang);
dang    = ang(2)-ang(1);

Dd      = cos((ang)/2).^(2*OPT.s);
Dint    = sum(Dd)*dang;
Dd      = Dd/Dint;

Sin     = y'*Dd;                                                           % dimension [length(f), noang]
Hm01    = 4*sqrt(sum(y)*OPT.df);
Hm0     = 4*sqrt(sum(sum(Sin))*OPT.df*dang);

K       = OPT.K;

%% start computation

% integrate S over angles
Sf      = sum(Sin,2)*dang;                                                   % dimension [length f]

% find frequency range around peak.
peakf   = find(Sf>0.08*max(Sf));
M       = length(peakf);

% frequency array of generated waves
fgen    = fin(peakf(1)):(fin(peakf(M))-fin(peakf(1)))/(K-1):fin(peakf(M)); % dimension K

% resolution
df      = fgen(2)-fgen(1);

% interpolate S on grid of fgen and ang
S       = interp2(ang,fin',Sin,ang,fgen');                                 % dimension [K noang]

% energy density
Sn      = sum(S,2)*dang;                                                   % dimension K

for i = 1:K
    Dd(i,:) = S(i,:)/(sum(S(i,:))*dang);
end   

% pick K wave directions
rng('default');
rng(0);
P0      = 0.99*rand(K,1)+0.01/2;

% determine probability density function
theta   = zeros(1,K);
for i = 1:K

    for j = 1:length(ang)
        P(j)    = sum(Dd(i,1:j))*dang+0.00001*j;
    end

    P1          = [0 P P(length(ang))+0.0001];
    ang1        = [min(ang)-dang ang max(ang)+dang];

    % find the angle for each frequency component
    theta(i)    = interp1(P1,ang1,P0(i));                                  % dimension K
end

% long crested waves
if OPT.s>=1000
    theta   = zeros(1,K);
end

% for interpolation purposes
Snew        = [S(:,noang) S S(:,1)];
i           = find(theta<min(ang1));
theta(i)    = theta(i) + 2*pi;
i           = find(theta>max(ang1));
theta(i)    = theta(i)-2*pi;

% check
Sontheta    = sum(S,1)*df;                                                 % dimension noang

S0          = interp2(fgen,ang1,(Snew)',fgen,theta)';                      % dimension K
                                          
dthetafin   = Sn./S0;						
Hm0temp     = 4*sqrt(sum(Sn)*df);
Hm0old      = 4*sqrt(sum(sum(S))*df*dang);
Hm0new      = 4*sqrt(sum(S0.*dthetafin*df));

thetafin    = theta;

% determine energy for EVERY difference frequency.
% K is number of primary wave components.
Eforc       = zeros(K-1,K);                                                % Herbers et al. (1994) eq. 1
                                                                           % dimension [df interaction]

D           = zeros(K-1,K);                                                % Herbers et al. (1994) eq. A5

% difference angle between two primary wave components
deltheta    = zeros(K-1,K);

% wavenumber of differnce wave
k3          = zeros(K-1,K);

% radial frequency and wavenumber of primary waves
w1          = 2*pi*fgen;
k1          = disper(w1,OPT.h,OPT.g);

for m = 1:K-1 
    
    % difference frequency
    deltaf              = m*df;

    deltheta(m,1:K-m)   = abs(thetafin(m+1:K)-thetafin(1:K-m))+pi;

    k3(m,1:K-m)         = sqrt(k1(1:K-m).^2 + k1(m+1:K).^2 + ...
                            2*k1(1:K-m).*k1(m+1:K).*cos(deltheta(m,1:K-m)));


    % build transferfunction D
    term1               = (-w1(1:K-m)).*w1(m+1:K);
    term2               = (-w1(1:K-m))+w1(m+1:K);
    chk1                = cosh(k1(1:K-m)*OPT.h);
    chk2                = cosh(k1(m+1:K)*OPT.h);

	D(m,1:K-m)          = -OPT.g*k1(1:K-m).*k1(m+1:K).*cos(deltheta(m,1:K-m))./2./term1 + ...
                           OPT.g*term2.*(chk1.*chk2)./((OPT.g*k3(m,1:K-m).*tanh(k3(m,1:K-m)*OPT.h)-(term2).^2) .* ...
                           term1.*cosh(k3(m,1:K-m)*OPT.h)) .* ...
                           (term2.*((term1).^2./OPT.g./OPT.g - ...
                           k1(1:K-m).*k1(m+1:K).*cos(deltheta(m,1:K-m))) - ...
                           0.5*((-w1(1:K-m)).*k1(m+1:K).^2./(chk2.^2) + ...
                           w1(m+1:K).*k1(1:K-m).^2./(chk1.^2)));           % Herbers et al. (1994) eq. A5


    % correction for surface elevation input and output instead of bottom pressure
    D(m,1:K-m)          = D(m,1:K-m).*cosh(k3(m,1:K-m)*OPT.h) ./ ...
                            (cosh(k1(1:K-m)*OPT.h).*cosh(k1(m+1:K)*OPT.h));

    % exclude interactions where f<deltaf
    [i,j]               = find(fgen<=m*df);
    D(m,j)              = D(m,j)*0;                                        % lower limit Herbers et al. (1994) eq. 1

    % S0 is energy density of the surface elevation, as measured
    % by bottom pressure sensors in FRF array. 
    Eforc(m,1:K-m) = 2*D(m,1:K-m).^2.* ...
       S0(1:K-m)'.*S0(m+1:K)'.*dthetafin(1:K-m)'.*dthetafin(m+1:K)'*df;    % Herbers et al. (1994) eq. 1

end

%% prepare output

Ebnd        = sum(Eforc,2);
Hm0low      = 4*sqrt(sum(Ebnd)*df);
Ebndsmooth  = zeros(K-1,1);
for i = 2:K-2
    Ebndsmooth(i) = (0.5*Ebnd(i-1)+Ebnd(i)+0.5*Ebnd(i+1))/2;
end
Hm0low2     = 4*sqrt(sum(Ebndsmooth)*df);

f1 = (1:K-1)*df;
S1 = Ebndsmooth;

f2 = fin;
S2 = Sf;
    
%% make plots

if OPT.plot
    
    % figure #1
    figure;

    subplot(211); hold on; box on;
    
    plot(f1,S1,'b');
    
    xlabel('\Delta f (Hz)');
    ylabel('E (m^2/Hz)');
    title('Low frequency wave spectrum');
    grid on;
    
    subplot(212); hold on; box on;
    
    plot(f2,S2,'r');
    
    xlabel('f (Hz)');
    ylabel('E (m^2/Hz)');
    title('High frequency wave spectrum');
    grid on;

    % figure #2
    figure; hold on; box on;
    
    plot((1:K-1)*df,Ebnd,'r')
    plot(f1,S1,'b')
    plot(fin,Sf,'r');
    
    xlabel('f (Hz)');
    ylabel('E (m^2/Hz)');
    title('High and low frequency wave spectrum');
    grid on;

    % figure #3
    figure;
    
    subplot(211);
    colormap([0 0 0]);
    
    kd = 3;
    mesh(fin(1:kd:end),ang(1:kd:end),Sin(1:kd:end,1:kd:end)');
    view(30,30);
    
    xlabel('f (Hz)');
    ylabel('\theta (rad)');
    zlabel('S (m^2/Hz/rad)');
    title('frequency-directional spectrum');
    
    vv = axis;
    axis([0.01 max(fin) min(ang) max(ang) vv(5) vv(6)]);
    
    subplot(212); box on;
    colormap([0 0 0]);
    
    [c,hh] = contour(fin,ang,Sin');
    clabel(c,hh);
    
    xlabel('f (Hz)');
    ylabel('\theta (rad)');
    grid on;
    
end