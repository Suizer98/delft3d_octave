function []= Mflat(rname,nrtides,slr,alshore,dredge,outint,dt,dx,xbd,zbd,mxslp,WM, etamp, bcs, ww, taucr, MM, gamma, kb, HH, Tpp, mormerge, MF, Ch, Cdeep, taudeep)

%MFLAT  Mflat models mudflat morphodynamics on a high resolution grid  
%
%   Mflat describes both cross-shore and alongshore tidal hydrodynamics as well as 
%   a stationary wave model on a high-resolution grid (dx=10m) and time period (dt=5s). 
%   An advection-diffusion equation solves sediment transport while bed level changes 
%   occur by the divergence of the sediment transport field.
%
%   Syntax:
%   varargout = Mflat(varargin)
%
%   Input   
%   varargin:
% rname    = name of run and output files
% nrtides  = number of 12hr tidal cycles ;
% slr      = sea level rise over nrtides*Morfac/2/365 years (assuming 2 tides a day), sine function
% alshore  = 1 switch on alongshore (y) flow component for tau_bed
% dredge   = 1 dredge the channel, slope and extrapolated slope to initial level
% outint   = outputinterval in min 
% dt       = timestep
% dx       = grid size
% xbd      = x position of zbd, vector
% zbd      = bed level at xbd, wrt MSL (under MSL = negative!)
% mxslp    = maximum slope in profile 1:mxslp, mxslp =vertical distance
% WM       = mudflat width, related to zbd, used to calculate if bed level change < eqlim
% etamp	   = tidal amplitude
% bcs      = sediment boundary concentration in kg/m3= g/l 
% ww       = fall velocity in m/s 
% taucr    = critical erosion shear stress in Pa
% MM       = erosion factor in kg/m^2/s
% gamma    = breaking index
% kb       = wave friction related, see Lacy(2014) for San Pablo Bay in winter: 0.0035 in summer= 0.011
% HH       = rms wave height; 1st col in min; 2nd col Hrms in m; in case of mormerge
% Tp       = peak period;  1st col in min; 2nd col Tp in sec
% mormerge = calc with different wave conditions per timestep
% MF       = morphological factor
% Ch       = Chezy friction factor on mudflat for zbd> mdep=max(zbd(ini))
% Cdeep    = Channel Chezy 
% taudeep  = channel critical shear stresss for erosion
%
%   Output:
%   varargout = *input.mat, *output.mat
%
%   See also runMflat.m Mflat_output.m balanceM.m waveparamsM.m

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 IHE 
%       mvw
%
%       m.vanderwegn@un-ihe.org
%
%       IHE Delft Institute for Water Education,
%       PO Box 3015, 2601 DA Delft
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
% Created: 15 Jul 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: $
% $Date: $
% $Author: Mick van der Wegen $
% $Revision: $
% $HeadURL: $
% $Keywords: mudflat morphodynamics$

%% Input

%%% Constants
gg		= 9.81;
rho     = 1025;
ddeep   = min(zbd);    % depth of max C(z) and max tau(z) and sed av

%%% Initial bed profile
XX        = xbd(end);
nx        = XX/dx+1;
x         = [0:dx:XX];
xbdata    = xbd;
zbdata    = zbd;
savdata   = zbd-ddeep;% sediment availability
mdep      = -3;
if dredge==1
    inizbdata = [zbd(1) zbd(2) zbd(3) zbd(2)+(xbd(4)-xbd(2))*((zbd(3))-zbd(2))/(xbd(3)-xbd(2))];
    inizb     = interp1(xbdata,inizbdata,x);
end
zb        = interp1(xbdata,zbdata,x);
sedavdata = interp1(xbdata,savdata,x);
pcor      = 0;% switch to have constant Qt through cross-section during every tide

%%% general input
nomor      = 0;           % during this period (in min) no morphological change; better use integer nr of tidal cycles
outint     = outint*60;     % outputinterval in secs
itide      = 0;             % constant required for map output 
Dif        = 5;             % switch on diffusion, mind: Dif*Dt/dx^2<0.5
T          = 12*3600;       % tidal wave period
L	       = 10*T;          % tidal wave length
omega      = 2*pi/T;        % tidal omega
kk         = 2*pi/L;        % tidal wave number
Cd         = gg/Ch^2;       % drag coefficient shoal
Cddeep     = gg/Cdeep^2;    % drag coefficient channel
fcor	   = 1e-4;          % used for wave setup eta
nt	       = nrtides*12*3600/dt;%nr time steps
Dhuni      = 0;             % related to water level change for roller energy
fac        = 0.2;           % related to water level change for roller energy
corfacP    = 0.5;           % in case of pcor=1;corfac for Q across profile (to secure constant prism) shall not vary more than corfacP*100 percent
ttt        = 0:dt:nt*dt;    % for definition of time dependent inputvars 
visc       = 0;             % visc>0 for inducing artificially smoother v velocity profile 
eqlim      = -1;            % if bed level change becomes smaller that eqlim, no more calculations, in m

%%% sea level rise %%%
slron=0;
if size(slr,2)==2   % if slr is not 0
    slr(:,1)    = slr(:,1).*60;    % in seconds
    addslr      = interp1(slr(:,1),slr(:,2),ttt);
    slron       = 1;
end

%%% waves %%%
u10     = 0;% wind velocity , if u10=0 no wind is included
morcon  = 1;% nr wave conditions
htime   = 0;% no time dep. Hrms
if mormerge==1   % mormerge with more wave conditions in columns and weight in second row
    morcon  = length(HH);
    Hrms0   = HH(:,1);
    Tp      = Tpp(:,1);
    mmw     = HH(:,2);
elseif size(HH,1)>1 && size(HH,2)==2   % if Hs and/or Tp is not constant over time
    HH(:,1) = HH(:,1).*60;    % in seconds
    Tp(:,1) = Tpp(:,1).*60;    % in seconds
    Hrms0   = interp1(HH(:,1),HH(:,2),ttt);
    Tp      = interp1(Tp(:,1),Tp(:,2),ttt);
    htime   = 1;
    mmw     = 1;
else
    Hrms0   = HH;
    Tp      = Tpp;
    mmw     = 1;
end
dir0    = 0;
eta0    = 0;
omegaw  = 2*pi./Tp;
beta    = .1;
hmin    = .01;   % water depth threshold for wave computations
ks      = 0.05;
gammax  = 0.8;

%sediments
ccini   = 0;         %kg/m3=g/l
rhob    = 1200;      %bulk density in kg/m3
sedtr   = 0.001 ;     %threshold for sediment adv-diff computations
%%% taucr(t) %%%
taucrtime = 0;% no time dep. bcs
if size(taucr,1)>1 && size(taucr,2)==2   % if tau is not constant over time
    taucr(:,1) = taucr(:,1).*60;    % in seconds
    taucr      = interp1(taucr(:,1),taucr(:,2),ttt);
    taucrtime  = 1;
end
%%% bcs(t) %%%
bcstime   = 0;% no time dep. bcs
if size(bcs,1)>1 && size(bcs,2)==2   % if bcs is not constant over time
    bcs(:,1)   = bcs(:,1).*60;    % in seconds
    bcs        = interp1(bcs(:,1),bcs(:,2),ttt);
    bcstime    = 1;
end

%% Ini flow calculation 4 equal Qflow(t) leading to constant prism
outinttide = 12*3600;
ttidal     = 0;
if pcor==1 
    v    = zeros(size(x));
    Dh   = zeros(size(x));% water level setup by wave action
    vt   = zeros([nx 2]);
    ht   = zeros([nx 2]);
    etat = zeros([nx 2]);
    zbt  = zeros([nx 3]);

    %% depth corrected roughness Cd
    Cdz  = Cd+(-zbt(:,tt)+mdep)./(-ddeep+mdep).*(Cddeep-Cd);
    Cdz(zbt(:,tt)>=mdep)=Cd;% cd above mdep always has Cd 
    %
    % Time loop
    %    
    tt          = 2;% actual point in time in sec: it
    imap        = 0;
    t           = 0;
    zbt(:,tt)   = zb;
    zbt(:,tt+1) = zb;
    etat(:,tt)  = etamp*cos(omega*t);
    ht(:,tt)    = etat(:,tt)-zbt(:,tt);
    ht(ht(:,tt)<=0,tt)=0;
    ntini       = 36*3600/dt;%run for 3 tides 
    for it=1:ntini+1
        etat(:,tt-1)   = etat(:,tt);
        vt(:,tt-1)     = vt(:,tt);    
        ht(:,tt-1)     = ht(:,tt); 
        zbt(:,tt-1:tt) = zbt(:,tt:tt+1); 
        etat(:,tt)     = 0;
        vt(:,tt)       = 0;
        ht(:,tt)       = 0;   
        t              = (it-1)*dt;%in secs
        etat(:,tt)     = etamp*cos(omega*t);
        ht(:,tt)       = etat(:,tt)-zbt(:,tt);
        %% Solve water level
        ht(:,tt)       = max(etat(:,tt)-zbt(:,tt),hmin); % water depth is always >= hmin 
        detady         = kk*etamp*sin(omega*t);
        %% alongshore velocity v from Neumann; cross shore velocity u from mass equation only
        wet            = find(ht(:,tt)<=hmin);%find first dry cell
        if isempty(wet)==1
            wet=length(ht(:,tt));
        end
        Xwet           = (wet(1))*dx;% calculate wet length from BC    
        wwet           = [ones(1,wet(1)) zeros(1,(length(ht(:,tt))-wet(1)))];% wet filter; not wet behind shoal
        tauby          = rho*Cdz*v.*abs(v);% neglect tau_x
        for ix=1:nx
            ixm1       = max(ix-1,1);
            ixp1       = min(ix+1,nx);
            v(ix)      = v(ix)+dt*(-gg*detady+(-tauby(ix))/rho./ht(ix,tt)...
                          +((Dh(ix)+Dh(ixp1))*(v(ixp1)-v(ix))-(Dh(ixm1)+Dh(ix))*(v(ix)-v(ixm1)))/2/dx^2);
        end
        % no water motion in area behind shoal
        v(wwet==0)     = 0;
        vt(:,tt)       = -v;         
        %calculate Q_alongshore for every timestep
        if it>=24*3600/dt  
            pxtini(it-24*3600/dt+1) = sum(ht(:,tt).*vt(:,tt));
        end
    end
end



%% let's start !       

%%% initialisation
u        = zeros(size(x));
v        = zeros(size(x));
eta      = zeros(size(x));
Dh       = zeros(size(x));
taubyt   = zeros(size(x));
Fx       = zeros(size(x));
Fy       = zeros(size(x));
tau_w    = zeros(size(x));
tottau   = zeros(size(x));
corfacx  = zeros(size(x));

vt       = zeros([nx 2]);
ut       = zeros([nx 2]);
ht       = zeros([nx 2]);
etat     = zeros([nx 2]);
ero      = zeros([nx 2 morcon]);
depo     = zeros([nx 2 morcon]);

cct      = zeros([nx 3 morcon]);
zbt      = zeros([nx 3]);
sedav    = zeros([nx 3]);
%
% Time loop
%    
tt            = 2;% actual point in time in sec: it
imap          = 0;
t             = 0;
zbt(:,tt)     = zb;
zbt(:,tt+1)   = zb;
sedav(:,tt)   = sedavdata;
sedav(:,tt+1) = sedavdata;
if slron==1
    etat(:,tt) = etamp*cos(omega*t)+addslr(1);
else
    etat(:,tt) = etamp*cos(omega*t);
end
ht(:,tt)      = etat(:,tt)-zbt(:,tt);
ht(ht(:,tt)<=0,tt)=0;

for it=1:nt+1
    % all shifts one dt into the past
    etat(:,tt-1)     = etat(:,tt);
    ero(:,tt-1,:)      = ero(:,tt,:);
    depo(:,tt-1,:)     = depo(:,tt,:);
    ut(:,tt-1)       = ut(:,tt);
    vt(:,tt-1)       = vt(:,tt);    
    ht(:,tt-1)       = ht(:,tt); 
    sedav(:,tt-1:tt) = sedav(:,tt:tt+1);
    zbt(:,tt-1:tt)   = zbt(:,tt:tt+1);
    cct(:,tt-1:tt,:)   = cct(:,tt:tt+1,:);       
    etat(:,tt)       = 0;
    ero(:,tt,:)        = 0;
    depo(:,tt,:)       = 0;
    ut(:,tt)         = 0;
    vt(:,tt)         = 0;
    ht(:,tt)         = 0;
    cct(:,tt+1,:)    = 0;      
    t                = (it-1)*dt;%in secs
    if slron==1
        if t==0
            etat(:,tt) = etamp*cos(omega*t)+addslr(1);
        else
            etat(:,tt) = etamp*cos(omega*t)+addslr(it);
        end
    else
        etat(:,tt)     = etamp*cos(omega*t);
    end
    ht(:,tt)         = etat(:,tt)-zbt(:,tt);
    Dbed_mm          = zeros(size(x))';
  
    %% depth corrected roughness Cd
    Cdz              = Cd+(-zbt(:,tt)+mdep)./(-ddeep+mdep).*(Cddeep-Cd);
    Cdz(zbt(:,tt)>=mdep)=Cd;% cd above mdep always has cd 
    %%% define area behind shoal
    wet              = find(ht(:,tt)<=hmin);%find first dry cell
    if isempty(wet)==1
        wet = length(ht(:,tt));
    end
    Xwet             = (wet(1))*dx;% calculate wet length from BC    
    wwet             = [ones(1,wet(1)) zeros(1,(length(ht(:,tt))-wet(1)))];% 
    
    %%% no water level change for area behind shoal
    for ix=1:nx
        if wwet(ix)==0 
            etat(ix,tt) = etat(ix,tt-1);
            if ht(ix,tt)==hmin
                etat(ix,tt) = 0; %no eta at shoal, but it is allowed behind shoal
            end
        end
    end 
    %%% no water depth change for area behind shoal and h>=hmin
    ht(:,tt)         = max(etat(:,tt)-zbt(:,tt),hmin);   

    %% alongshore velocity v from Neumann; cross shore velocity u from mass equation only
    detady   = kk*etamp*sin(omega*t);
    tauby    = rho*Cdz'.*v.*abs(v);% neglect impact of tau_x and waves
    for ix=1:nx
        ixm1  = max(ix-1,1);
        ixp1  = min(ix+1,nx);
        v(ix) = v(ix)+dt*(-gg*detady+(Fy(ix)-tauby(ix))/rho./ht(ix,tt)...
                   +((Dh(ix)+Dh(ixp1))*(v(ixp1)-v(ix))-(Dh(ixm1)+Dh(ix))*(v(ix)-v(ixm1)))/2/dx^2);       
        u(ix) = ((ht(1,tt)-ht(1,tt-1))/dt)*(Xwet-ix*dx)/(ht(ix,tt));% assuming flat with no x-friction or x-inertia
    end
    %% smooth v velocity profile as kind of artificial viscosity
    if visc>0
        windowSize = visc;
        b          = (1/windowSize)*ones(1,windowSize);
        v          = filter(b,1,v);
        for ii=1:visc
            v(ii)  = v(visc);
        end
    end
    if alshore==0
        v = v.*0;
    end

    %%% no flow in area behind shoal
    v        = v.*wwet;% no y flow at dry cells
    u        = u.*wwet;% no x flow at dry cells
    vt(:,tt) = -v;
    ut(:,tt) = u;

    % if pcor=1: correction to secure constant flow through entire cross-section per dt during a single tide
    if mod(t,outinttide)==0
        ttidal = 0;
        itide  = itide+1;
    end 
    if itide >=2
        ttidal = ttidal+1;
        if pcor==1
            ll     = 0.1;
            hxmean = mean(ht(:,tt));
            corfac(tt)=1;
            if sum(v(:))~=0
                corfac(tt) = pxtini(ttidal)./(sum(ht(:,tt).*vt(:,tt))); % correction for entire profile   
            end
            if corfac(tt)>=(1+corfacP) %eg for v=0
                corfac(tt) = (1+corfacP);
            end 
            if corfac(tt)<=(1-corfacP)  %eg for v=0
                corfac(tt) = (1-corfacP);
            end 
            meanh        = mean(ht(find(wwet==1),tt));% no y flow at dry cells
            corfacx(:)   = corfac(tt)*(1+ll*(ht(:,tt)-meanh)./meanh);
            vt(:,tt)     = vt(:,tt).*corfacx(:);   % no correction for v(:)! since that is the 'correct' one for y momentum!
        end 
    end
      
%% start morloop for morcon different wave conditions
    for imor=1:morcon
        %% Solve wave, roller energy balance and setup
%         if mod(it,1)==0
        if htime==0 % constant wave, possibly mormerge
            [E,Hrms,Er,Qb,Dw,Dr,k,C,Cg,dir,Fx,Fy,fw,tau_w] = balanceM(Hrms0(imor),dir0*pi/180,eta0,Tp(imor),x,zbt(:,tt),gamma,gammax,beta,hmin,ht(:,tt),kb,u10);  
        else %time varying wave 
            [E,Hrms,Er,Qb,Dw,Dr,k,C,Cg,dir,Fx,Fy,fw,tau_w] = balanceM(Hrms0(it),dir0*pi/180,eta0,Tp(it),x,zbt(:,tt),gamma,gammax,beta,hmin,ht(:,tt),kb,u10);  
        end
%         Dh  = ht(:,tt).*fac.*(Dr./rho)'.^(1/3)+Dhuni;
        Dh  = zeros(size(ht(:,tt)));% negelect Dh
%         Fmax=.25*rho*gg/Tp(it)*gammax^2*ht(:,tt).^2./sqrt(gg*ht(:,tt));
%         Fx=min(Fx,Fmax');
%         Fy=min(Fy,Fmax');

        %%% no wave action area behind shoal
        for ix=1:nx 
            if wwet(ix)==0
                E(ix)    = 0;
                Hrms(ix) = 0;
%                 Fx(ix)=0;
%                 Fy(ix)=0;
            end
        end

        %% shear stress (wave and u-v-flow) for sediment suspension
        tau_w     = tau_w.*wwet;% no wave shear stress at dry cells
        uv        = (u.^2+(squeeze(vt(:,tt))').^2).^0.5;
        tauby     = rho*Cdz.*squeeze(vt(:,tt)).*abs(squeeze(vt(:,tt)));
        taubuv    = rho*Cdz'.*uv.*abs(uv);
        taubx     = rho*Cdz'.*u.*abs(u);
        tottau_uv = tau_w+abs(taubuv).*(1+1.2*(tau_w./(abs(taubuv)+tau_w)).^3.2);
        tottau_x  = tau_w+abs(taubx).*(1+1.2*(tau_w./(abs(taubx)+tau_w)).^(3.2));
        tottau_uv(isnan(tottau_uv)) = 0;% in case of zero tau
        tottau_x(isnan(tottau_x))   = 0;% in case of zero tau
        tottau_uv = tottau_uv.*wwet;% no shear stress at dry cells
        tottau_x  = tottau_x.*wwet;% no shear stress at dry cells

        if alshore == 1
            tau = tottau_uv;
        else
            tau = tottau_x;
        end

        %% concentration 
        if it>=2 % in first timestep: all is zero
            for ix =2:(length(u))% interpolate u and h to velocity points 
                u_mid(ix,1) = (ut(ix,tt-1)+ut(ix-1,tt-1))/2;% calculate midcell u-flow and h in previous timestep
                h_mid(ix,1) = (ht(ix,tt-1)+ht(ix-1,tt-1))/2;
            end
            u_mid(1,1)            = ut(1,tt-1);%bc sea
            h_mid(1,1)            = ht(1,tt-1);%bc sea
            u_mid(length(ut)+1,1) = ut(length(ut),tt-1);%bc land
            h_mid(length(ut)+1,1) = ht(length(ut),tt-1);%bc land
            if u_mid(1)<=0
                c_up(1:(length(cct(:,tt-1,imor)))) = cct(:,tt-1,imor);% in previous timestep
                c_up(length(cct(:,tt-1,imor))+1)   = 0; % no sediment from land   wrong:c_upwp(length(cct(:,tt-1))-1);
            else
                if bcstime==1
                    c_up(1) = bcs(it);
                else
                    c_up(1) = bcs;
                end
                c_up(2:length(cct(:,tt-1,imor))+1) = cct(:,tt-1,imor);% in previous timestep
            end
            for ix =1:length(u)% diffusion
                ixm1     = max(1,ix-1);% no transport gradients at sea BC
                ixp1     = min(length(u),ix+1);
                cdif(ix) = h_mid(ix+1).*(cct(ixp1,tt-1,imor)-cct(ix,tt-1,imor))./dx-...
                              h_mid(ix).*(cct(ix,tt-1,imor)-cct(ixm1,tt-1,imor))./dx;
            end
            if u_mid(1)<=0 % ebb
                for ix=1:length(u)
                    cct(ix,tt,imor) = (cct(ix,tt-1,imor).*ht(ix,tt-1)./dt-...
                        (u_mid(ix+1).*h_mid(ix+1).*c_up(ix+1)-u_mid(ix).*h_mid(ix).*c_up(ix))./dx+...% advection
                        cdif(ix).*Dif./(dx)+...%diffusion
                        ero(ix,tt-1,imor))./...%erosion
                        (ht(ix,tt)./dt+ww);            %kg/m3=g/l, ww=deposition term
                    if ht(ix,tt)==hmin
                        cct(ix,tt,imor) = 0;% no concentration in drycells
                    end
                end
                clear c_upwp;
                clear c_upwm;
                clear cdif;
            else %flood
                if bcstime==1
                    cct(1,tt,imor) = bcs(it); 
                else
                    cct(1,tt,imor) = bcs; 
                end  
                for ix=2:length(u)
                    cct(ix,tt,imor) = (cct(ix,tt-1,imor).*ht(ix,tt-1)./dt-...
                        (u_mid(ix+1).*h_mid(ix+1).*c_up(ix+1)-u_mid(ix).*h_mid(ix).*c_up(ix))./dx+...% advection
                        cdif(ix).*Dif./(dx)+...%diffusion
                        ero(ix,tt-1,imor))./...%erosion
                        (ht(ix,tt)./dt+ww);            %kg/m3=g/l, ww=deposition term
                    if ht(ix,tt)==hmin
                        cct(ix,tt,imor) = 0;% no concentration in drycells
                    end
                end
                clear c_upwp;
                clear c_upwm;
                clear cdif;
            end    
        end

        %% critical shear stress correction for depth
        if taucrtime==1
            taucrd  = taucr(1)+(-zbt(:,tt)+mdep)./(-ddeep+mdep).*(taudeep-taucr(1));
            taucrd(zbt(:,tt)>=mdep)   = taucr(1);% depo above mdep always has taucr ini value
            taucrd(zbt(:,tt)>=-etamp) = taucr(it);% only varying tau at intertidal area
        else
            taucrd=taucr+(-zbt(:,tt)+mdep)./(-ddeep+mdep).*(taudeep-taucr);
            taucrd(zbt(:,tt)>=mdep)   = taucr;% depo above mdep always has taucr 
        end 
       
        %% morphodynamics
        depo(:,tt,imor) = ww*cct(:,tt,imor);%kg/m2/s positive= supply to bed
        ero(:,tt,imor)  = MM*(tau./taucrd'-1); ero(ero<=0)=0;%kg/m2/s, positive=supply to water   
        for ix=1:length(sedav(:,tt))
            if sedav(ix,tt)<=((ero(ix,tt,imor)-depo(ix,tt)).*dt./rhob)*MF;
                ero(ix,tt,imor) = depo(ix,tt,imor)+sedav(ix,tt).*rhob./dt/MF;% not more erosion than availabble sediment+deposition
            end
        end
        ero(ero<=0) = 0;
        for ix=1:length(ht(:,tt))
            if ht(ix,tt)<=sedtr
                ero(ix,tt,imor) = 0;% no erosion if h<=sedtr
            end
        end
        for ix=1:length(ht(:,tt))
            if ht(ix,tt)<=sedtr
                depo(ix,tt,imor) = cct(ix,tt,imor)*ht(ix,tt)./rhob;% kg/m3*m/ kg/m3; all deposits if h<=sedtr
                cct(ix,tt,imor)  = 0;
            end
        end 
        Dbed(:,imor)=(depo(:,tt,imor)-ero(:,tt,imor)).*dt./rhob;%kg/m2/s  *s*m3/kg
        if t<=nomor*60
            Dbed(:,imor)= zeros(size(depo,1),1);% no bed level change durings  hydro spinup
        end
        Dbed(:,imor)=Dbed(:,imor).*mmw(imor);
        
    end
    
    %% end morloop
    if morcon>=2
        zbt(:,tt+1) = zbt(:,tt)+(sum(Dbed').*MF)';
    else 
        zbt(:,tt+1) = zbt(:,tt)+Dbed.*MF;
    end
    
    smoothslope = 0;%remove steep slopes>mxslp 
    itmax       = 10;
    ind         = 0;
    while smoothslope~=1 
        while ind<=itmax;
            ind      = ind+1;
            slopemax = 0;
            for ix=1:nx-2 % remove negative steep slopes from landward side onwards
                if (-zbt(nx-ix-1,tt+1)+zbt(nx-ix,tt+1))/dx>(mxslp)
                    slopemax = 1;
                end
            end
            if slopemax==1
                for ix= 1:nx-3 
                    if (-zbt(nx-ix-2,tt+1)+zbt(nx-ix-1,tt+1))/dx>=(mxslp)
                            zbt(nx-ix-1,tt+1)=(0.5*zbt(nx-ix-1,tt+1)+0.5*zbt(nx-ix-2,tt+1)+0.5*0.8*mxslp*dx);
                            zbt(nx-ix-2,tt+1)=zbt(nx-ix-1,tt+1)-0.8*mxslp*dx;
                    end
                end
            end
            for ix=2:nx % remove negative steep slopes from seaward side onwards
                if (zbt(ix-1,tt+1)-zbt(ix,tt+1))/dx>(mxslp/5)
                    slopemax = 1;
                end
            end
            if slopemax==1
                for ix= 2:nx 
                    if ((zbt(ix-1,tt+1)-zbt(ix,tt+1))/dx)>=mxslp/5
                            zbt(ix-1,tt+1) = (0.5*zbt(ix-1,tt+1)+0.5*zbt(ix,tt+1)+0.5*0.8*mxslp/5*dx);
                            zbt(ix,tt+1)   = zbt(ix-1,tt+1)-0.8*mxslp/5*dx;
                    end
                end
            end
            if slopemax==0
                    smoothslope = 1;
                    ind         = itmax+2;
            end
        end
        smoothslope = 1; 
    end
    sedav(:,tt+1) = sedav(:,tt)+zbt(:,tt+1)-zbt(:,tt);
    sedav(find(sedav(:,tt+1)<=0),tt+1) = 0;

    for ix =1:length(zbt(:,tt))% correct for presumed truncation errors O(-6) 
        if zbt(ix,tt+1)<ddeep
            zbt(ix,tt+1)   = ddeep;
            sedav(ix,tt+1) = 0;
        end
    end

    if dredge==1 % dredge channel and slope to initial profile
         for ix=1:nx
            if zbt(ix,tt+1)>=inizb(ix)
                zbt(ix,tt+1)    = inizb(ix);
                sedav(ix,tt+1)  = sedavdata(ix);% maximise depth at channel depth 
            end
         end
    end
    
    celt(:,tt)    = (ht(:,tt).*gg).^0.5;
    courant(:,tt) = celt(:,tt).*dt./dt;

    %% mapfile 
    if mod(t,outint)==0
        imap            = imap+1;
        fprintf('percentagetime=%2.2i\n',t/(nt*dt)*100);
        zbxt(:,imap)    = zbt(:,tt);
        sedavt(:,imap)  = sedav(:,tt);
        if  morcon>=2
            cxt(:,imap,:)     = cct(:,tt,:);
            eroxt(:,imap,:)   = ero(:,tt,:);
            depoxt(:,imap,:)  = depo(:,tt,:);
        else
            cxt(:,imap)     = cct(:,tt);
            eroxt(:,imap)   = ero(:,tt);
            depoxt(:,imap)  = depo(:,tt);
        end
        hxt(:,imap)     = ht(:,tt);
        uxt(:,imap)     = ut(:,tt);
        vxt(:,imap)     = vt(:,tt);
        tauxt(:,imap)   = tau;
        tauw_xt(:,imap) = tau_w;
        if alshore==1
            tauc_xt(:,imap) = taubuv;
        else
            tauc_xt(:,imap) = taubx;
        end
        hrmsxt(:,imap)    = Hrms;
        courantxt(:,imap) = courant(:,tt);
        corfacxt(:,imap)  = corfacx(:);
        fwxt(:,imap)      = fw(:);
    end
    if imap>24*3600/outint
        if sqrt(mean((zbxt((end+1-WM/dx)+1:end,imap)-zbxt((end+1-WM/dx)+1:end,imap-12*3600/outint)).^2))<=eqlim
            break;
        end
    end
end

if Dif*dt/dx^2>=0.5
    fprintf(' Dif*dt/dx^2>=0.5; not stable4diffusion');
end

for ii=1:size(zbxt,2)
    cumerosed(:,ii) = zbxt(:,ii)-zbxt(:,1);
end

%
% save data
%
input.etamp    = etamp;
input.nrtides  = nrtides;
input.dt       = dt;
input.dx       = dx;
input.mdep     = mdep;
input.mxslp    = mxslp;
input.alshore  = alshore;
input.dredge   = dredge;
input.pcor     = pcor;
input.XX       = XX;
input.WM       = WM;
input.bcs      = bcs;
input.ww       = ww;
input.MM       = MM;
input.taucr    = taucr;
input.outint   = outint;
input.Dif      = Dif;
input.MF       = MF;
input.T        = T;
input.Hrms0    = Hrms0;
input.gamma    = gamma;
input.kb       = kb;
input.Hrms0    = Hrms0;
input.Tp       = Tp;
input.mormerge = mormerge;
input.MF       = MF;
input.Ch       = Ch;
input.eqlim    = eqlim;
input.Dif      = Dif;
input.XX       = XX;
input.ddeep    = ddeep;
input.Cdeep    = Cdeep;
input.taudeep  = taudeep;
input.sedtr    = sedtr;

output.hxt       = hxt;
output.zbxt      = zbxt;
output.eroxt     = eroxt;
output.depoxt    = depoxt;
output.sedavt    = sedavt;
output.cxt       = cxt;
output.uxt       = uxt;
output.vxt       = vxt;
output.tauxt     = tauxt;
output.tauw_xt   = tauw_xt;
output.tauc_xt   = tauc_xt;
output.hrmsxt    = hrmsxt;
output.courantxt = courantxt;
output.corfacxt  = corfacxt;
output.fwxt      = fwxt;

save([rname 'input.mat'], 'input');
save([rname 'output.mat'], 'output');
