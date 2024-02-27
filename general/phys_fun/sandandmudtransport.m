function [cmud, csand, z, qxmud1depthint, qymud1depthint, qxsand1depthint,...
    qysand1depthint] = sandandmudtransport(time,h,Ux,Uy,Hs,Tp, varargin)
%SANDANDMUDTRANSPORT variation of the depth-integrated sand and mud transport
%
% computes the variation of the depth-integrated sand 
% and mud transport. The suspended sand transport is included assuming 
% that the sediment bed (pmud+psand=1) behaves as a cohesive mixture.
%
% This function follows the relations presented on pages 3.70-3.75 in
% "Principles of sedimentation and erosion engineering in rivers, estuaries
% and coasal seas" by Van Rijn (2005).
% The sand concentration distribution is computed slightly
% differently.
%
% Many parameters have been set to default values to simplify first use of
% the model. However, the optional input parameters should be carefully
% chosen as well!
%
% Input:
%   time:   time array (s)
%   h:      water depth array (m)
%   Ux:     velocity in x direction array (m/s)
%   Uy:     velocity in y direction array (m/s)
%
% Optional input:
%   pmud:           fraction of mud (-), default is 0.6
%   wsmudmax:       maximum mud settling velocity (m/s), default is 0.001
%   wsmudmin:       minimum mud settling velocity (m/s), default is 0.0001
%   concdepwsmud:   selection of mud settling velocity; 0 = constant = ws,max, 1 = non-constant, default is 1
%   D50:            median sand grain size (m), default is 0.001
%   Hs:             significant wave height (m), default is 0
%   Tp:             wave spectrum peak period (s), default is 7
%   rhos:           sediment density (kg/m3), default is 2650
%   sal:            salinity (psu), default is 35
%   temp:           temperature (degrees Celcius), default is 10
%   a:              reference level (m), default is 0.25
%   dt:             time step (s), default is 300
%   cmud0:          background concentration for mud (kg/m^3), default is 0
%   mudscale:       scaling coefficient concentration mud (-), default is 0.001
%   turbdamp:       coefficient for turbulent damping (0-20), 0 means no damping, default is 10
%   gammarefconcmud:adjustment coefficient reference concentration mud (0.5-2), default is 1
%   ksc:            current-related bed roughness for shear stress and mixing (m), default is 0.0001
%   ksw:            wave-related bed roughness for shear stress and mixing (m), default is 0.0001
%   kscvel:         current-related roughness (effective roughness) for velocity profile (m), default is 1
%   taucr:          critical bed shear stress for sand-mud mixture (N/m^2), default is 0.1
%
% Output:
%   cmud:            mud concentration at height z (kg/m^3)
%   csand:           sand concentration at height z (kg/m^3)
%   qxmud1depthint:  depth-integrated mud transport in x direction (kg/m^2/s)
%   qymud1depthint:  depth-integrated mud transport in y direction (kg/m^2/s)
%   qxsand1depthint: depth-integrated sand transport in x direction (kg/m^2/s)
%   qysand1depthint: depth-integrated sand transport in y direction (kg/m^2/s)
%
% Example:
% time = [0:1:12.5*3600];
% h = 5+sin(time()./(12.5*2*pi))
% [cmud, csand, z, qxmud1depthint, qymud1depthint, qxsand1depthint,...
%    qysand1depthint] = tidalmudtransport03(time,h_180_low,ux_180_low./100,uy_180_low./100,...
%    H13_180_low./100,Tp_180_low,'pmud',pmud,'dt',3600,'cmud0',cmud0,'turbdamp',turbdamp,...
%    'taucr', taucr, 'a',a,'wsmudmax',wsmudmax, 'ksc',ksc,'ksw',ksw,'concdepwsmud',0);
%   
% See also: sedimentmixing, sedimentmixingparabolic, wavedispersion
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl	
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Sep 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: sandandmudtransport.m 13075 2016-12-27 23:43:38Z simon@X $
% $Date: 2016-12-28 07:43:38 +0800 (Wed, 28 Dec 2016) $
% $Author: simon@X $
% $Revision: 13075 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/sandandmudtransport.m $
% $Keywords: $

%%


%% default parameters
nrofsigmalevels = 50;
pmud = 0.6;                                                                 % fraction of mud (-)
wsmudmax = 0.001;                                                           % maximum mud settling velocity (m/s)
wsmudmin = 0.0001;                                                          % minimum mud settling velocity (m/s)
concdepwsmud = 1;                                                           % selection of mud settling velocity; 0 = constant = ws,max, 1 = non-constant
D50 = 0.0001;                                                               % median sand grain size (m)
% Hs = 0.0;                                                                   % significant wave height (m)
% Tp = 7;                                                                     % wave spectrum peak period (s)
rhos = 2650;                                                                % sediment density (kg/m3)
sal = 35;                                                                   % salinity (psu)
temp = 10;                                                                  % temperature (degrees Celcius)
a = 0.25;                                                                   % reference level (m)
dt = 300;                                                                   % time step (s)
cmud0 = 0;                                                                  % background concentration for mud (kg/m^3);
mudscale = 0.001;                                                           % scaling coefficient concentration mud (-)
turbdamp = 10;                                                              % coefficient for turbulent damping (0-20), 0 means no damping
gammarefconcmud = 1;                                                        % adjustment coefficient reference concentration mud (0.5-2), default = 1

ksc = 0.0001;                                                               % current-related bed roughness for shear stress and mixing (m)
ksw = 0.0001;                                                               % wave-related bed roughness for shear stress and mixing (m)
kscvel = 1;                                                                 % current-related roughness (effective roughness) for velocity profile (m)
taucr = 0.1;                                                                % critical bed shear stress for sand-mud mixture (N/m^2)

quiet = false;

g = 9.81;                                                                   % acceleration of gravity (m/s^2);

%% optional arguments
optvals = varargin;
if 2*round(length(optvals)/2)~=length(optvals),
    error('Invalid option-value pair');
else
    optvals=reshape(optvals,[2 length(optvals)/2]);
end;
OptionUsed=false(1,size(optvals,2));
for i=1:size(optvals,2),
    if ~ischar(optvals{1,i}),
        error('Invalid option'),
    end;
    switch lower(optvals{1,i}),
        case 'nrofsigmalevels',
            nrofsigmalevels = optvals{2,i};
            OptionUsed(i)=1;
        case 'concdepwsmud',
            concdepwsmud = optvals{2,i};
            OptionUsed(i)=1;
        case 'pmud',
            pmud = optvals{2,i};
            OptionUsed(i)=1;
        case 'wsmudmax',
            wsmudmax = optvals{2,i};
            OptionUsed(i)=1;
        case 'wsmudmin'
            wsmudmin = optvals{2,i};
            OptionUsed(i)=1;
        case 'd50'
            D50 = optvals{2,i};
            OptionUsed(i)=1;
        case 'hs'
            Hs = optvals{2,i};
            OptionUsed(i)=1;
        case 'tp'
            Tp = optvals{2,i};
            OptionUsed(i)=1;
        case 'rhos'
            rhos = optvals{2,i};
            OptionUsed(i)=1;
        case 'sal'
            sal = optvals{2,i};
            OptionUsed(i)=1;
        case 'temp'
            temp = optvals{2,i};
            OptionUsed(i)=1;
        case 'a'
            a = optvals{2,i};
            OptionUsed(i)=1;
        case 'dt'
            dt = optvals{2,i};
            OptionUsed(i)=1;
        case 'cmud0'
            cmud0 = optvals{2,i};
            OptionUsed(i)=1;
        case 'mudscale'
            mudscale = optvals{2,i};
            OptionUsed(i)=1;
        case 'turbdamp'
            turbdamp = optvals{2,i};
            OptionUsed(i)=1;
        case 'gammarefconcmud'
            gammarefconcmud = optvals{2,i};
            OptionUsed(i)=1;
        case 'ksc'
            ksc = optvals{2,i};
            OptionUsed(i)=1;
        case 'ksw'
            ksw = optvals{2,i};
            OptionUsed(i)=1;
        case 'ksvel'
            ksvel = optvals{2,i};
            OptionUsed(i)=1;
        case 'taucr'
            taucr = optvals{2,i};
            OptionUsed(i)=1;
        case 'quiet'
            quiet = optvals{2,i};
            OptionUsed(i)=1;
    end
end;
optvals(:,OptionUsed)=[];                                                   % delete used options
optvals = optvals(:);

%% run computations
U = sqrt(Ux.^2+Uy.^2);                                                      % velocity magnitude (m/s)
rhow = waterdensity0(sal,temp);                                             % water density
psand = 1-pmud;                                                             % fraction of sand (-)
wssand = fallvelocity(D50,rhos, sal, temp);                                 % sand settling velocity
[thetacrsandZanke,thetacrsandBrownlie, ThetaCrVanRijn, Ddim] = ...
    criticalbedshearstress(D50, rhos, rhow);                                % non-dimensional critical bed shear stress for sand alone, I prefer the function from Brownlie (1981)
taucrsand = thetacrsandBrownlie.*(g .* (rhos - rhow) .* D50);               % critical bed shear stress (N/m^2);
nu = kinviscwater(sal,temp,0);                                              % kinematic viscosity of seawater (m^2/s)

C = 18.*log10(12.*h./ksc);
fc = 8.*g./C.^2;
tauc = rhow.*g.*U.^2./C.^2;
ustarc = sqrt(tauc./rhow);

L_deep = g.*Tp.^2./(2.*pi);
k_deep = 2.*pi./L_deep;
del_L = 0.001;  % meters!
del_k = 1./L_deep - 1./(L_deep+del_L);

% kinit = 2.*pi./40;
for i=1:length(h),
    L(i) = wavedispersion(Tp(i),h(i));
    k(1,i) = 2.*pi./L(i);
%     k(1,i) = lwt_wavenumber(1./Tp(i),h(i), del_k, kinit);
end

Adelta = Hs./(2.*sinh(k.*h));                                               % peak wave orbital excursion
Udelta = pi.*Hs./(Tp.*sinh(k.*h));                                          % peak wave orbital velocity
fw = exp(-6+5.2.*(Adelta./ksw).^-0.19);                                     % method Van Rijn
fw = min(fw,0.3);
tauw = 0.25 * rhow .* fw .* (Udelta).^2;
ustarw = sqrt(tauw./rhow);
taucw = sqrt(tauc.^2+tauw.^2);
ustarcw = sqrt(ustarc.^2+ustarw.^2);
i = find(ustarcw==0);
ustarcw(i) = 0.0001;
epsmax = 0.1.*ustarcw.*h;
i = find(epsmax<0.02);                                                      % assuming there's always a minimum amount of mixing
epsmax(i) = 0.02;
taustir = (tauc+tauw-taucr)/taucr;
taustir(taustir<0.00000001)=0.00000001;
Tsand = (tauc+tauw-taucrsand)/taucrsand;                                    % transport parameter sand
Tsand(Tsand<0.001)=0.001;
ceqmudtmp = cmud0./rhos+mudscale.*taustir.^1.5;
ceqmudtmp(ceqmudtmp>0.1) = 0.1;
ceqmudtmp(ceqmudtmp<0.00000189) = 0.00000189;
ceqmud = pmud.*ceqmudtmp;
ceqmud1 = rhos.*ceqmud;
Arefmud = gammarefconcmud.*0.1.*1./h.*wsmudmax./ustarcw.*(1+2.*wsmudmax./ustarcw).*(1+Hs./h).^2;
camudt(1) = ceqmud(1);
for i = 2:length(h);
    camudt(i) = 1./(1+Arefmud(i).*dt).*(camudt(i-1)+Arefmud(i).*dt.*ceqmud(i));
end;
camudt1 = camudt.*rhos;
ceqsand1 = rhos*min(0.015.*D50./a.*Tsand.^1.5./Ddim.^0.3,0.1);
ceqsand = ceqsand1./rhos;

DeltaW = ustarw ./ (2 .* pi ./ Tp);                                             % wave boundary layer thickness from Nielsen (1992), page 30
ls = 0.1;
zi = 1:1:nrofsigmalevels;                                                       % sigma levels
z = NaN(length(time),nrofsigmalevels);
for i = 1:length(h),
    z(i,1) = a;
    z(i,2:end) = a.*(h(i)./a).^(zi(2:end)./(length(zi)));
    dz(i,:) = gradient(z(i,:));
end
wsmud = NaN(length(time),length(z(i,:)));
wsmud(:,:) = wsmudmax;
epsilon = NaN(length(time),length(z(i,:)));
epsilon(:,1) = sedimentmixingparabolic(epsmax, z(i,1), h);                  % mixing at reference level
Ri(1:length(h),length(z(i,:))) = 0.01;
Ri(1,2) = 0.01;
gammad = NaN(length(time),length(z(i,:)));
gammad(:,1) = 1;                                                            % damping at reference level
cmudvol = NaN(length(time),length(z(i,:)));
cmudvol(:,1) = camudt;                                                      % conc is equal to reference concentration for all time steps
cmud(:,1) = camudt.*rhos;
qmud = NaN(length(time),length(z(i,:)));
csandvol = zeros(length(time),length(z(i,:)));
csandvol(:,1) = ceqsand;                                                    % conc is equal to reference concentration for all time steps

% qmud1 = NaN(size(qmud));
%     wsmud = NaN(length(time),length(z(i,:)));

if ~quiet
    mywaitbar = waitbar(0,'sandandmudtransport running, please wait...');
end

if concdepwsmud == 1,
    i = find(cmudvol(:,1) > 0.0025);
    wsmud(i,1) = wsmudmax.*(1-cmudvol(i,1)).^4;
    i = find(cmudvol(:,1) <= 0.0025);
    wsmud(i,1) = exp((0.182.*log(wsmudmax./wsmudmin)).*log(cmudvol(i,1))+2.09.*log(wsmudmax)-1.09.*log(wsmudmin));
    %         blup = isreal(wsmud);
    %         if blup == 0,
    %             floep;
    %         end
end

for i = 1:length(h),                                                            % i is the i'th time step
    if ~quiet
        waitbar(i/length(h),mywaitbar);
    end
    Uz(i,:) = U(i)./(-1+log(h(i)/(0.033*kscvel))).*log(z(i,:)./(0.033.*kscvel));
    Uzx(i,:) = Ux(i)./(-1+log(h(i)/(0.033*kscvel))).*log(z(i,:)./(0.033.*kscvel));
    Uzy(i,:) = Uy(i)./(-1+log(h(i)/(0.033*kscvel))).*log(z(i,:)./(0.033.*kscvel));
    dudz(i,:) = gradient(Uz(i,:))./dz(i,:);
    c1 = csandvol(i,1);
    for j = 2:length(z(i,:)),                                                   % j is the j'th height above bed
        epsilon(i,j) = sedimentmixingparabolic(epsmax(i), z(i,j), h(i));
        if concdepwsmud == 1,
            if cmudvol(i,j-1) > 0.0025,
                wsmud(i,j) = wsmudmax.*(1-cmudvol(i,j-1)).^4;
            else
                wsmud(i,j) = exp((0.182.*log(wsmudmax./wsmudmin)).*log(cmudvol(i,j-1))+2.09.*log(wsmudmax)-1.09.*log(wsmudmin));
            end
        end
        if i > 1 && j == 2,
            Ri(i,j) = max((Ri(i-1,1)+Ri(i-1,2)+Ri(i-1,3))./3,0.01);         % Richardson number
        end
        if j > 2,
            if dudz(i,j) ~= 0,
                Ri(i,j) = min(max(-(rhos-rhow).*g./((rhow+(rhos-rhow).*cmud(i,j-1)./rhos)).*((cmud(i,j-2)/rhos-cmud(i,j-1)/rhos)/(z(i,j-2)-z(i,j-1)))./(dudz(i,j).^2),0.01),10);
            else
                Ri(i,j) = 0.01;
            end
        end
        if j > 1,
            gammad(i,j) = (1+turbdamp*sqrt(Ri(i,j)))^-1;
        end
        if epsilon(i,j) > 0,
            cmudvol(i,j) = max(cmudvol(i,j-1)*(1-dz(i,j)*wsmud(i,j)/(gammad(i,j-1)*epsilon(i,j))),cmudvol(i,1)*0.00001);
            %dcdz = sedimentdcdz(gammad(i,j-1)*epsilon(i,j), wssand, c1);
            %-- not found in openearthtools ----
            %But see equation 2 of VanRijn et al. 2007 - Part II suspended transport
            %C*ws+epsilon*(dC/dz)=0
            %dC/dz=-(ws/epsilon)*C
            % to be solved numerically so C=c1 at the start/bottom of
            % profile
            
            dcdz=-(wssand./[gammad(i,j-1)*epsilon(i,j)]).*c1;
            
            %then work out the concentration profile upwards
            
            c2 = c1 + dcdz * dz(i,j);
            if(c2<0),
                c2=0;
            end
            csandvol(i,j) = c2;
            c1 = c2;
        else
            cmudvol(i,j) = cmudvol(i,1)*0.00001;
            c1 = 0;
            c2 = 0;
            csandvol(i,j) = 0;
        end
        cmud(i,j) = cmudvol(i,j) .* rhos;

        %         cmuddepthav(m) = mean(cmud(i,:));
        qxmud(i,j) = cmudvol(i,j) .* Uzx(i,j);
        qymud(i,j) = cmudvol(i,j) .* Uzy(i,j);
        qxmud1(i,j) = qxmud(i,j) .* rhos;
        qymud1(i,j) = qymud(i,j) .* rhos;

        qxsand(i,j) = csandvol(i,j) .* Uzx(i,j);
        qysand(i,j) = csandvol(i,j) .* Uzy(i,j);
        qxsand1(i,j) = qxsand(i,j) .* rhos;
        qysand1(i,j) = qysand(i,j) .* rhos;

    end
    qxmud1depthint(i) = trapz(z(i,:),qxmud1(i,:));
    qymud1depthint(i) = trapz(z(i,:),qymud1(i,:));
    qxsand1depthint(i) = trapz(z(i,:),qxsand1(i,:));
    qysand1depthint(i) = trapz(z(i,:),qysand1(i,:));
end
csand = csandvol.*rhos;
if ~quiet
    close(mywaitbar);
end