function [Ur, Us, zz] = stokes_return_flow(Hm0 ,Tp ,h, Hdir, varargin)
%UNDERTOW Computes the wave-related Stokes drift and return flow velocities
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

% $Id: stokes_return_flow.m 14799 2018-11-09 12:49:43Z bartgrasmeijer.x $
% $Date: 2018-11-09 20:49:43 +0800 (Fri, 09 Nov 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14799 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/stokes_return_flow.m $
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
Qb = exp(-(Hmax./Hrms).^2);%fraction of breaking waves according to Rayleigh distribution
% Rayleigh wave distribution
for it = 1:length(Hm0)
    %fraction of breaking waves according to Unbest-TC model
    %Rayleigh distribution with truncated at maximum wave height, Battjes & Janssen (1978) model
%     Qb(it) = fractionbreakingwaves(Hrms(it),Hmax(it));
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
Er = 0.5*rhow*c.*Ar./Tp.*Qb; %roller energy [J/m]=[kg/s2], Eq. 4.3, fraction of breaking waves added, following Uchiyama et al. (2010), see Schnitlzer (2015)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Mass fluxes and drift velocities
Ms = Ew./c;             %mass flux due to Stokes drift, Boers (2005), Eq. (4.19)
Mr = 2*Er./c;           %mass flux due to roller, Boers (2005), Eq. (5.12), why a factor 2*Er?
us_da = Ms/rhow./h;     %depth-averaged Stokes drift velocity [m/s], USING TOTAL WATER DEPTH
ur_da = Mr/rhow./h;     %depth-averaged "roller drift" velocity [m/s], USING TOTAL WATER DEPTH
uda = us_da + ur_da;    %total depth-average drift velocity [m/s]
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
zz = NaN(length(h),OPT.nrofsigmalevels+1);
dz = h./nrofsigmalevels;
Ur1 = NaN(length(h),OPT.nrofsigmalevels+1);
Ur2 = NaN(length(h),OPT.nrofsigmalevels+1);
Ur3 = NaN(length(h),OPT.nrofsigmalevels+1);
Ur = NaN(length(h),OPT.nrofsigmalevels+1);
Us = NaN(length(h),OPT.nrofsigmalevels+1);

for it = 1:length(h)
    zz(it,:) = 0:dz(it):h(it);
    Ur1(it,:) = ar(it).*Urd(it)./log(dm(it)./z0(it)).*log(zz(it,:)./z0(it));
    Ur2(it,:) = ar(it).*-uda(it)./(-1+log(h(it)./za(it)))*log(zz(it,:)./za(it));
    Ur3(it,:) = Urmid(it).*(1-((zz(it,:)-0.5.*h(it))/(0.5.*h(it))).^3);
    id1 = max(find(zz(it,:) <= dm(it)));
    id2 = max(find(zz(it,:) <= (0.5.*h(it))));
    Ur(it,:) = Ur3(it,:);
    Ur(it,1:id1) = Ur1(it,1:id1);
    Ur(it,id1+1:id2) = Ur2(it,id1+1:id2);
    Ur(it,1) = 0;
    Us(it,:) = 1/8*omega(it)*k(it)*Hrms(it)^2*cosh(2*k(it)*((zz(it,:)-h(it))+h(it)))/(sinh(k(it)*h(it))^2);
end

% figure
% plot(Ur{1},zz{1},'k-','LineWidth',1.5)
% hold on
% grid on
% plot([-uda(1) -uda(1)],[0 h(1)],'r-','LineWidth',1.5)
% xlabel('U_r (m/s)')
% ylabel('z (m)')
% title(['H_s = ',num2str(Hm0(1)),' m, T_p = ',num2str(Tp(1)),' s'])
% legend('Van Rijn (2013)','depth-uniform','location','southeast');
% print('-dpng','-r300',['undertow_example']);


% figure
% plot(Ur{1},zz{1},'k-','LineWidth',1.5)
% hold on
% grid on
% plot(Us{1},zz{1},'r-','LineWidth',1.5)
% plot(Us{1} + Ur{1},zz{1},'b-','LineWidth',1.5)
% plot([0 0],[0 h(1)],'k-','LineWidth',1)
% xlabel('U (m/s)')
% ylabel('z (m)')
% title(['H_s = ',num2str(Hm0(1)),' m, T_p = ',num2str(Tp(1)),' s'])
% legend('U_r(z)','U_s(z)','U_s + U_r(z)','location','southeast');
%  print('-dpng','-r300',['undertow_example2']);
%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % ANALYTICAL MODEL RENIERS ET AL. (2004) to compute velocity profileok
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Input settings
% % fdelta = 1;         %multiplication factor wave boundary layer thickness [-]
% % fv = 0.101;         %calibration factor wave-breaking induced eddy viscosity, value taken from Reniers et al. (2004), based on calibration against Duck data
% % ks = 0.0082;        %roughness length [m], value taken from Reniers et al. (2004), based on calibration against Duck data
% % beta = 0.1;         %roller slope [-]
% % ht = h;             %water depth below wave trough [m] (total water depth taken here for now)
% % cd = 0.002;         %drag coefficent to compute wind stress [-]
% % vtide = [0.5,0.5,0.5];    %depth-mean tidal velocity in alongshore direction [m/s] (postive = flood current to the north/east)
% % unet = [0,0,0];% -uda_vec(1,:);           %target depth-mean crosshore current velocity [m/s]
% % vnet = vtide;% - uda_vec(2,:);             %target depth-mean alongshore current velocity [m/s]
% % uacc = [1e-3];            %accuracy depth-averaged cross-schore velocity [m/s]
% % vacc = [5e-3];            %accuracy depth-averaged alongsore velocity [m/s]
% % %%%
% % for i = 1:length(Hm0)
% %     [uxz(:,i),uyz(:,i),sigma(:,i)] = wdc_reniers(wnd_facx(i),wnd_facy(i),wav_facx(i),wav_facy(i),Hrms(i),T(i),kh(i),omega(i),ks,ht(i),rhow,fdelta,beta,Er(i),c(i),fv,cd,rhoa,Vwind(i),kappa,vtide(i),k,unet(i),vnet(i),uacc,vacc);
% % end
% % %near-bed currents [m/s]
% % uxnb_005 = mean(uxz(1:500,:));
% % uynb_005 = mean(uyz(1:500,:));
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %WBBL STREAMINIG [m/s]
% % %Orginal expression Longuet-Higgins (1953)
% % ulh = 0.75*uorb.^2./c;
% % ulh_vec = [wav_facx.*ulh;wav_facy.*ulh];
% % %Van Rijn (2007), includes offshore streaming for rough beds
% % rr = aorb./ks;%relative roughness [-]
% % for i = 1:length(rr)
% %     if rr(i) <= 1
% %         param(i) = -1;
% %     elseif rr(i) >= 100
% %         param(i) = 0.75;
% %     else
% %         param(i) = (-1+0.875*log10(rr(i)));
% %     end
% % end
% % uvr = param.*uorb.^2./c;
% % uvr_vec = [wav_facx.*uvr;wav_facy.*uvr];
% % %Expression streaming (m/s), Kraneburg et al. (2012), Eq. (23), includes effects of roughness and wave shape
% % uk = uorb.^2./c.*(0.345 + 0.7*(aorb./ks).^(-0.9) - 0.25./sinh(kh).^2);
% % uk_vec = [wav_facx.*uk;wav_facy.*uk];
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % save('waveheight.mat','Hm0','T','h','theta_wav','Vwind','theta_wnd','uxz','uyz','sigma','uxnb_005','uynb_005','uda_vec','ulh_vec','uvr_vec','uk_vec');
% %
% % %Plots
% % % lin_col = {'b','r','g'};
% % % % Effect wave height
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uxz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_x> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['H_{m0} = ',num2str(Hm0(1),'%0.1f'),' m'],['H_{m0} = ',num2str(Hm0(2),'%0.1f'),' m'],['H_{m0} = ',num2str(Hm0(3),'%0.1f'),' m'],'location','northwest');
% % % title(['Effect of wave height: \theta_{wav} = ',num2str(theta_wav(1),'%0.0f'),'^o, V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(1),'%0.0f'),'^o, h = ',num2str(h(1),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/ux_Hm0']);
% % % %%
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uyz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_y> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['H_{m0} = ',num2str(Hm0(1),'%0.1f'),' m'],['H_{m0} = ',num2str(Hm0(2),'%0.1f'),' m'],['H_{m0} = ',num2str(Hm0(3),'%0.1f'),' m'],'location','northwest');
% % % title(['Effect of wave height: \theta_{wav} = ',num2str(theta_wav(1),'%0.0f'),'^o, V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(1),'%0.0f'),'^o, h = ',num2str(h(1),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/uy_Hm0']);
% %
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %Effect water depth
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uxz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_x> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['h = ',num2str(h(1),'%0.0f'),' m'],['h = ',num2str(h(2),'%0.0f'),' m'],['h = ',num2str(h(3),'%0.0f'),' m'],'location','northwest');
% % % title(['Effect of water depth: H_{m0} = ',num2str(Hm0(1),'%0.1f'),' m, \theta_{wav} = ',num2str(theta_wav(1),'%0.0f'),'^o, V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(1),'%0.0f'),'^o'])
% % % print('-dpng','-r300',['figures/ux_h']);
% % % %%
% % % figure
% % % for i = 1:length(h)
% % % plot(uyz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_y> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['h = ',num2str(h(1),'%0.0f'),' m'],['h = ',num2str(h(2),'%0.0f'),' m'],['h = ',num2str(h(3),'%0.0f'),' m'],'location','northwest');
% % % title(['Effect of water depth: H_{m0} = ',num2str(Hm0(1),'%0.1f'),' m, \theta_{wav} = ',num2str(theta_wav(1),'%0.0f'),'^o, V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(1),'%0.0f'),'^o'])
% % % print('-dpng','-r300',['figures/uy_h']);
% %
% % % %Effect wave direction
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uxz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_x> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['\theta_{wav} = ',num2str(theta_wav(1),'%0.0f'),'^o'],['\theta_{wav} = ',num2str(theta_wav(2),'%0.0f'),'^o'],['\theta_{wav} = ',num2str(theta_wav(3),'%0.0f'),' ^oN'],'location','northwest');
% % % title(['Effect of wave direction: H_{m0} = ',num2str(Hm0(1),'%0.1f'),' m, V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(1),'%0.0f'),' ^oN, h = ',num2str(h(1),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/ux_wavdir']);
% % %
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uyz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_y> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['\theta_{wav} = ',num2str(theta_wav(1),'%0.0f'),'^o'],['\theta_{wav} = ',num2str(theta_wav(2),'%0.0f'),'^o'],['\theta_{wav} = ',num2str(theta_wav(3),'%0.0f'),' ^oN'],'location','northwest');
% % % title(['Effect of wave direction: H_{m0} = ',num2str(Hm0(1),'%0.1f'),' m, V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(1),'%0.0f'),' ^oN, h = ',num2str(h(1),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/uy_wavdir']);
% % % %
% % %Effect wind speed
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uxz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_x> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s'],['V_{wnd} = ',num2str(Vwind(2),'%0.0f'),' m/s'],['V_{wnd} = ',num2str(Vwind(3),'%0.0f'),' m/s'],'location','northwest');
% % % title(['Effect of wind speed: H_{m0} = ',num2str(Hm0(i),'%0.1f'),' m, \theta_{wav} = ',num2str(theta_wav(i),'%0.0f'),'^o, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(i),'%0.0f'),'^o, h = ',num2str(h(i),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/ux_vwind']);
% % %
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uyz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_y> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['V_{wnd} = ',num2str(Vwind(1),'%0.0f'),' m/s'],['V_{wnd} = ',num2str(Vwind(2),'%0.0f'),' m/s'],['V_{wnd} = ',num2str(Vwind(3),'%0.0f'),' m/s'],'location','northwest');
% % % title(['Effect of wind speed: H_{m0} = ',num2str(Hm0(i),'%0.1f'),' m, \theta_{wav} = ',num2str(theta_wav(i),'%0.0f'),'^o, \theta_{wnd} = ',...
% % %      num2str(theta_wnd(i),'%0.0f'),'^o, h = ',num2str(h(i),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/uy_vwind']);
% % % %
% % %Effect wind direction
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uxz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_x> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['\theta_{wnd} = ',num2str(theta_wnd(1),'%0.0f'),'^o'],['\theta_{wnd} = ',num2str(theta_wnd(2),'%0.0f'),'^o'],['\theta_{wnd} = ',num2str(theta_wnd(3),'%0.0f'),' ^oN'],'location','northwest');
% % % title(['Effect of wind direction: H_{m0} = ',num2str(Hm0(i),'%0.1f'),' m, \theta_{wav} = ',num2str(theta_wav(i),'%0.0f'),' ^oN, V_{wnd} = ',...
% % %      num2str(Vwind(1),'%0.0f'),' m/s, h = ',num2str(h(i),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/ux_wnddir']);
% % %
% % % figure
% % % for i = 1:length(Hm0)
% % % plot(uyz(:,i),sigma(:,i),'-','LineWidth',1.5,'color',lin_col{i});
% % %     if i == 1
% % %         hold on
% % %         grid on
% % %     end
% % % end
% % % xlabel('<u_y> (m/s)')
% % % ylabel('z/h (-)')
% % % plot([0 0],[0 1],'k-')
% % % legend(['\theta_{wnd} = ',num2str(theta_wnd(1),'%0.0f'),'^o'],['\theta_{wnd} = ',num2str(theta_wnd(2),'%0.0f'),' ^oN'],['\theta_{wnd} = ',num2str(theta_wnd(3),'%0.0f'),' ^oN'],'location','northwest');
% % % title(['Effect of wind direction: H_{m0} = ',num2str(Hm0(i),'%0.1f'),' m, \theta_{wav} = ',num2str(theta_wav(i),'%0.0f'),'^o, V_{wnd} = ',...
% % %      num2str(Vwind(1),'%0.0f'),' m/s, h = ',num2str(h(i),'%0.0f'),' m'])
% % % print('-dpng','-r300',['figures/uy_wnddir']);