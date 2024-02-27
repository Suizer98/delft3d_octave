function [Ur, Us] = stokes_return_flow_z(Hm0 ,Tp ,h, Hdir, zz, varargin)
%STOKES_RETURN_FLOW_Z Computes the wave-related Stokes drift and return flow velocities
% at user defined z levels
%
%   Syntax:
%   [Ur, Us, zz] = undertow(Hm0 ,Tp ,h, Hdir)
%
%   Input:
%   Hm0  = significant wave height [m]
%   Tp = wwave spectrum peak period [s]
%   h = water depth [m]
%   Hdir = wave direction [degrees]
%
%   Optional input:
%   ksw = wave-related roughness height [m]
%   ksc = current-related roughness height [m]
%   ka = apparent roughness [m]
%
%   Output:
%   Ur = return flow velocity [m/s]
%   Us = Stokes drift velocity [m/s]
%   zz = height above the bed [m]
%
%   Example
%   Hm0 = [5,5,5];
%   Tp = [10,10,10];
%   h = [15,15,15];
%   Hdir = [0,0,0];
%   [Ur, Us, zz] = undertow(Hm0 ,Tp ,h, Hdir);
%
%   See also disper, fractionbreakingwaves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       grasmeij
%
%       bartgrasmeijer@deltares.nl
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
% Created: 06 Nov 2018
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: stokes_return_flow_z.m 14802 2018-11-09 15:11:27Z bartgrasmeijer.x $
% $Date: 2018-11-09 23:11:27 +0800 (Fri, 09 Nov 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14802 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/stokes_return_flow_z.m $
% $Keywords: undertow, dispersion, breaking waves, Van Rijn, Stokes, return flow, drift$

%%
OPT.g = 9.81;
OPT.rhow = 1000;
OPT.ksw = 0.02;
OPT.ksc = 0.02;
OPT.ka = 0.08;
OPT.nrofsigmalevels = 200;
% return defaults (aka introspection)
if nargin==0
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

rhow = OPT.rhow;
g = OPT.g;
nrofsigmalevels = OPT.nrofsigmalevels;
ksw = ones(size(Hm0)).*OPT.ksw;
ksc = ones(size(Hm0)).*OPT.ksc;
ka = ones(size(Hm0)).*OPT.ka;

%% INPUT
%% PREPARATIONS
wav_facx = cos(Hdir/180*pi);%factor to compute x-component waves from magnitude [-]
wav_facy = sin(Hdir/180*pi);%factor to compute y-component waves from magnitude [-]
Hrms = Hm0/sqrt(2);         %root-mean-square wave height [m]
Ew = 1/8*rhow*9.81*Hrms.^2; %wave energy [J/m2]
L0 = 9.81*Tp.^2/(2*pi);      %deep water wave length [m]
omega = 2*pi./Tp;            %angular frequency [rad/s]
% htr = h-0.5*Hrms;           %water depth beneath wave trough [m]
k = disper(2.*pi./Tp, h, g);   %wave number [rad/m]
L = 2.*pi./k;               %wave length [m]
kh = k.*h;
uorb = pi*Hrms./(Tp.*sinh(kh));%near-bed orbital velocity [m/s], using linear wave theory and using Hrms
aorb = uorb./omega;                              %orbital velocity amplitude [m]
c = L./Tp;                               %wave celerity vector [m/s]
s0 = Hrms./L0;                          %deepwater wave steepness [-]
% gamma = 0.5 + 0.4*tanh(33*s0);          %breaker param, Bosboom et al. (2000), Eq. 3.5
gamma = 0.75*kh+0.29;
Hmax = 0.88./k.*tanh(gamma.*k.*h/0.88); %maximum wave height, Bosboom et al. (2000), Eq. 3.4
Qb = NaN(size(Hrms));
dH = 0.01;
H = 0:dH:12;
% Qb = exp(-(Hmax./Hrms).^2);%fraction of breaking waves according to Rayleigh distribution
% Rayleigh wave distribution
for it = 1:length(Hm0)
    %fraction of breaking waves according to Unbest-TC model
    %Rayleigh distribution with truncated at maximum wave height, Battjes & Janssen (1978) model
    Qb(it) = fractionbreakingwaves(Hrms(it),Hmax(it));
    %%
    P = 2*H/Hrms(it)^2.*exp(-(H/Hrms(it)).^2);
    Pcum=cumsum(P);
    %Clipped Rayleigh distribution , Boers (2005), Eq. (3.4)
    PH = 1 - exp(-(1-Qb(it))*H.^2/Hrms(it)^2);
    PH(find(H>Hmax(it))) = 1;
    % % %%
    % % % figure
    % % % plot(H,Pcum*dH,'k-')
    % % % hold on
    % % % grid on
    % % % plot(H,PH,'k--')
    % % % xlabel('H (m)')
    % % % plot([Hrms(i) Hrms(i)],[0 1],'b-')
    % % % plot([Hm0(i) Hm0(i)],[0 1],'r-')
    % % % plot([Hmax(i) Hmax(i)],[0 1],'g-')
    % % % ylabel('P(H < H) (-)')
    % % % title(['Hm0 = ',num2str(Hm0(i),'%0.1f'),' m, h = ',num2str(h(i),'%0.1f'),' m'])
    % % % legend('Rayleigh','clipped Rayleigh','location','northwest');
    % % % print('-dpng','-r300',['figures/waveheightdist_',num2str(10*Hm0(i),'%0.0f'),'_',num2str(h(i),'%0.0f')]);
end
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%roller energy, equations from Boers (2005), based on Svensen (1984)
Ar = 0.9*Hmax.^2;           %roller area [m2], Eq. 4.1
% if Qb>1e-5
    Er = 0.5*rhow*c.*Ar./Tp.*Qb; %roller energy [J/m]=[kg/s2], Eq. 4.3, fraction of breaking waves added, following Uchiyama et al. (2010), see Schnitlzer (2015)
% else
%     Er =0;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mass fluxes and drift velocities
Ms = Ew./c;             %mass flux due to Stokes drift, Boers (2005), Eq. (4.19)
Mr = 2*Er./c;           %mass flux due to roller, Boers (2005), Eq. (5.12), why a factor 2*Er?
us_da = Ms/rhow./h;     %depth-averaged Stokes drift velocity [m/s], USING TOTAL WATER DEPTH
ur_da = Mr/rhow./h;     %depth-averaged "roller drift" velocity [m/s], USING TOTAL WATER DEPTH
uda = us_da + ur_da;    %total depth-average drift velocity [m/s]
% uda = ur_da;    %depth-average return flow velocity [m/s]
uda_vec = [wav_facx.*uda;wav_facy.*uda];

%Van Rijn (2013) undertow model
%
z0=ksc/30;
za=ka/30;
%
dm = 0.216.*aorb.*(aorb./ksw).^-0.25;
C1 = -1+log(h./za);
C2 = log(0.5.*h./za);
C3 = (dm./h - 0.5) + 0.5*log(0.5.*h./za) - (dm./h.*log(dm./za));
ar = C1./(C3 + 0.375.*C2);
Urd = -uda./(-1+log(30.*h./ka)).*log(30.*dm./ka);
Urmid = ar.*-uda./(-1+log(h./za)).*log(0.5.*h./za);

% initialize matrices
% zz = NaN(length(h),OPT.nrofsigmalevels+1);
% dz = h./nrofsigmalevels;
%     zz(it,:) = 0:dz(it):h(it);
Ur1 = ar.*Urd./log(dm./z0).*log(zz./z0);
Ur2 = ar.*-uda./(-1+log(h./za))*log(zz./za);
Ur3 = Urmid.*(1-((zz-0.5.*h)/(0.5.*h)).^3);
id1 = max(find(zz <= dm)); 
if isempty(id1) 
    id1=1; 
end
id2 = max(find(zz <= (0.5.*h)));
Ur = Ur3;
Ur(1:id1) = Ur1(1:id1);
Ur(id1+1:id2) = Ur2(id1+1:id2);
% Ur(1) = 0;
Us = 1/8*omega*k*Hrms^2*cosh(2*k*((zz-h)+h))/(sinh(k*h)^2);

